part of '../../../app/komekci_app.dart';

/// Pay by bank card. `POST /me/billing/topup` opens a bank order; the bank's
/// page is shown in a WebView; when the bank sends the browser back to our
/// server we close it and ask `GET /me/billing/cards/{id}` how the order
/// ended. Landing back on our page is *not* proof of payment — only
/// `status: success` from the API is.
class _CardPaymentDialog extends StatefulWidget {
  const _CardPaymentDialog({required this.amount});
  final int amount;

  @override
  State<_CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<_CardPaymentDialog> {
  /// How long to keep asking while the bank has not settled the order.
  static const _maxChecks = 8;
  static const _checkEvery = Duration(seconds: 2);

  CardTopup? _topup;
  _PaymentOutcome? _outcome;
  bool _busy = false;
  String? _error;

  Future<void> _start() async {
    final billing = context.read<BillingProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _busy = true;
      _error = null;
    });
    final CardTopup topup;
    try {
      topup = await billing.startCardPayment(widget.amount);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = apiErrorMessage(error, language);
      });
      return;
    }
    if (!mounted) return;
    _topup = topup;
    await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => _CardPaymentPage(topup: topup)),
    );
    if (!mounted) return;
    await _verify();
  }

  /// Asks the server for the order's outcome, repeating while it is still
  /// `unfinished`/`unknown`.
  Future<void> _verify() async {
    final topup = _topup;
    if (topup == null) return;
    final billing = context.read<BillingProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      CardPaymentResult result;
      var checks = 0;
      do {
        result = await billing.checkCardPayment(cardTransactionId: topup.cardTransactionId);
        if (!result.status.isPending || ++checks >= _maxChecks) break;
        await Future<void>.delayed(_checkEvery);
        if (!mounted) return;
      } while (true);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _outcome = switch (result.status) {
          CardPaymentStatus.success => _PaymentOutcome.success,
          CardPaymentStatus.failed => _PaymentOutcome.failed,
          _ => _PaymentOutcome.pending,
        };
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = apiErrorMessage(error, language);
      });
    }
  }

  void _finish() {
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(pageRoute(const MasterHome()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final cur = context.watch<AppSettingsProvider>().currencyLabel(language);

    if (_outcome != null) {
      return Dialog(
        backgroundColor: tokens.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: _PaymentResultPanel(
          outcome: _outcome!,
          amount: '${widget.amount}',
          onContinue: _finish,
          // Still pending: ask again. Failed: start a fresh order.
          onRetry: () {
            if (_outcome == _PaymentOutcome.pending) {
              _verify();
            } else {
              setState(() {
                _outcome = null;
                _topup = null;
              });
            }
          },
        ),
      );
    }

    return Dialog(
      backgroundColor: tokens.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.surfaceElevated,
              ),
              child: AppIcon(Icons.credit_card_outlined, color: tokens.accent, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              t(tk: 'Bank kartasy bilen töleg', ru: 'Оплата банковской картой', en: 'Pay by bank card'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                tk: '${widget.amount} $cur tölemek üçin howpsuz bank sahypasy açylar. Halkbank, Rysgal ýa-da Senagat kartasyny ulanyp bilersiňiz.',
                ru: 'Откроется защищённая страница банка для оплаты ${widget.amount} $cur. Подойдёт карта Halkbank, Rysgal или Senagat.',
                en: 'A secure bank page opens to pay ${widget.amount} $cur. Halkbank, Rysgal and Senagat cards work.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.textSecondary, fontSize: 12.5, height: 1.45),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              _FieldError(_error!),
            ],
            const SizedBox(height: 18),
            _MasterActionButton(
              label: _busy
                  ? t(tk: 'Garaşyň...', ru: 'Подождите...', en: 'Please wait...')
                  : _topup != null
                  ? t(tk: 'Tölegi barla', ru: 'Проверить оплату', en: 'Check payment')
                  : t(tk: 'Tölemäge geç', ru: 'Перейти к оплате', en: 'Continue to payment'),
              enabled: !_busy,
              trailingArrow: true,
              onTap: _topup != null ? _verify : _start,
            ),
            const SizedBox(height: 6),
            _DialogCancelButton(label: t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel')),
          ],
        ),
      ),
    );
  }
}

/// The bank's payment page. Pops with the `orderId` once the bank redirects
/// to our server, or with null if the user closes it.
class _CardPaymentPage extends StatefulWidget {
  const _CardPaymentPage({required this.topup});
  final CardTopup topup;

  @override
  State<_CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<_CardPaymentPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _returned = false;

  @override
  void initState() {
    super.initState();
    final serverHost = Uri.parse(apiBaseUrl).host;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            // Back on our server = the bank is done with the customer.
            if (uri != null && uri.host == serverHost && !_returned) {
              _returned = true;
              String? orderId;
              for (final entry in uri.queryParameters.entries) {
                if (entry.key.toLowerCase() == 'orderid') orderId = entry.value;
              }
              Navigator.of(context).pop(orderId ?? widget.topup.bankOrderId);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.topup.formUrl));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        title: Text(
          pickTr(language, tk: 'Töleg', ru: 'Оплата', en: 'Payment'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const AppIcon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
