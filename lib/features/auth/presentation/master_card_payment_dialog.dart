part of '../../../app/komekci_app.dart';

String _bankLogoAsset(CardBank bank) => switch (bank) {
  CardBank.halk => 'assets/images/banks/halk.png',
  CardBank.senagat => 'assets/images/banks/senagat.jpeg',
  CardBank.rysgal => 'assets/images/banks/rysgal.png',
};

class _BankChoiceTile extends StatelessWidget {
  const _BankChoiceTile({
    required this.bank,
    required this.selected,
    required this.enabled,
  });

  final CardBank bank;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return RadioListTile<CardBank>(
      value: bank,
      controlAffinity: ListTileControlAffinity.trailing,
      enabled: enabled,
      selected: selected,
      activeColor: tokens.accent,
      tileColor: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected
              ? tokens.accent.withValues(alpha: enabled ? 1 : .55)
              : tokens.border,
          width: selected ? 1.8 : 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      secondary: Opacity(
        opacity: enabled ? 1 : .55,
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(_bankLogoAsset(bank), fit: BoxFit.contain),
          ),
        ),
      ),
      title: Text(
        bank.label,
        style: TextStyle(
          color: enabled ? tokens.textPrimary : tokens.textSecondary,
          fontSize: 14.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );
  }
}

/// Pay by bank card. `POST /me/billing/topup` opens a bank order; the bank's
/// page is shown in a WebView and the order is checked while it is open.
/// Only `status: success` from the API is proof of payment.
class _CardPaymentDialog extends StatefulWidget {
  const _CardPaymentDialog({required this.amount});
  final int amount;

  @override
  State<_CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<_CardPaymentDialog> {
  CardTopup? _topup;
  _PaymentOutcome? _outcome;
  CardBank _bank = CardBank.halk;
  bool _busy = false;
  String? _error;

  Future<void> _start() async {
    final billing = context.read<BillingProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _busy = true;
      _outcome = null;
      _error = null;
    });
    final CardTopup topup;
    try {
      topup = await billing.startCardPayment(widget.amount, _bank);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        final bankDetail =
            error is ApiException && error.code == ApiErrors.paymentUnavailable
            ? error.details['bank']
            : null;
        _error = bankDetail is String && bankDetail.isNotEmpty
            ? bankDetail
            : apiErrorMessage(error, language);
      });
      return;
    }
    if (!mounted) return;
    _topup = topup;
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(builder: (_) => _CardPaymentPage(topup: topup)),
    );
    if (!mounted) return;
    if (result is ApiException) {
      setState(() {
        _busy = false;
        _topup = null;
        _error = apiErrorMessage(result, language);
      });
      return;
    }
    if (result == CardPaymentStatus.success ||
        result == CardPaymentStatus.failed) {
      setState(() {
        _busy = false;
        _outcome = result == CardPaymentStatus.success
            ? _PaymentOutcome.success
            : _PaymentOutcome.failed;
      });
      return;
    }
    await _verify();
  }

  /// A manual check after the WebView is closed or a pending result is shown.
  Future<void> _verify() async {
    final topup = _topup;
    if (topup == null) return;
    final billing = context.read<BillingProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _busy = true;
      _outcome = null;
      _error = null;
    });
    try {
      final result = await billing.checkCardPayment(
        cardTransactionId: topup.cardTransactionId,
      );
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
        if (error is ApiException &&
            error.statusCode == 404 &&
            error.code == ApiErrors.notFound) {
          _topup = null;
        }
        _error = apiErrorMessage(error, language);
      });
    }
  }

  void _finish() {
    final me = context.read<AuthProvider>().me;
    final navigator = Navigator.of(context);
    navigator.pop();
    if (me != null) {
      navigator.pushAndRemoveUntil(pageRoute(homeForAccount(me)), (_) => false);
    }
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
              child: AppIcon(
                Icons.credit_card_outlined,
                color: tokens.accent,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t(
                tk: 'Bank kartasy bilen töleg',
                ru: 'Оплата банковской картой',
                en: 'Pay by bank card',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                tk: '${widget.amount} $cur tölemek üçin banky saýlaň.',
                ru: 'Выберите банк для оплаты ${widget.amount} $cur.',
                en: 'Choose a bank to pay ${widget.amount} $cur.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            RadioGroup<CardBank>(
              groupValue: _bank,
              onChanged: (value) {
                if (!_busy && _topup == null && value != null) {
                  setState(() => _bank = value);
                }
              },
              child: Column(
                children: [
                  for (final bank in CardBank.values) ...[
                    _BankChoiceTile(
                      bank: bank,
                      selected: _bank == bank,
                      enabled: !_busy && _topup == null,
                    ),
                    if (bank != CardBank.values.last) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              _FieldError(_error!),
            ],
            const SizedBox(height: 18),
            MasterActionButton(
              label: _busy
                  ? t(
                      tk: 'Garaşyň...',
                      ru: 'Подождите...',
                      en: 'Please wait...',
                    )
                  : _topup != null
                  ? t(
                      tk: 'Tölegi barla',
                      ru: 'Проверить оплату',
                      en: 'Check payment',
                    )
                  : t(
                      tk: 'Tölemäge geç',
                      ru: 'Перейти к оплате',
                      en: 'Continue to payment',
                    ),
              enabled: !_busy,
              trailingArrow: true,
              onTap: _topup != null ? _verify : _start,
            ),
            const SizedBox(height: 6),
            _DialogCancelButton(
              label: t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Polls the authenticated card transaction even when the bank never redirects.
/// Pops only after the server reports success or failure, or the user closes it.
class _CardPaymentPage extends StatefulWidget {
  const _CardPaymentPage({required this.topup});
  final CardTopup topup;

  @override
  State<_CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<_CardPaymentPage> {
  static const _checkEvery = Duration(seconds: 4);
  late final WebViewController _controller;
  Timer? _poll;
  bool _loading = true;
  bool _checking = false;
  bool _finished = false;
  String? _statusError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.topup.formUrl));
    _poll = Timer.periodic(_checkEvery, (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_checking || _finished) return;
    _checking = true;
    try {
      final result = await context.read<BillingProvider>().checkCardPayment(
        cardTransactionId: widget.topup.cardTransactionId,
      );
      if (!mounted || _finished) return;
      if (!result.status.isPending) {
        _finished = true;
        _poll?.cancel();
        Navigator.of(context).pop(result.status);
      } else if (_statusError != null) {
        setState(() => _statusError = null);
      }
    } catch (error) {
      if (mounted &&
          !_finished &&
          error is ApiException &&
          error.statusCode == 404 &&
          error.code == ApiErrors.notFound) {
        _finished = true;
        _poll?.cancel();
        Navigator.of(context).pop(error);
        return;
      }
      if (mounted && !_finished) {
        final language = context.read<LanguageProvider>().language;
        setState(() => _statusError = apiErrorMessage(error, language));
      }
    } finally {
      _checking = false;
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
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
          if (_statusError != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: tokens.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_statusError!, textAlign: TextAlign.center),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
