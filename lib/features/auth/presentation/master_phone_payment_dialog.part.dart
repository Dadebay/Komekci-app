part of '../../../app/komekci_app.dart';

/// Pay by transferring mobile balance. Steps:
///
/// 1. rules the operator applies (shown first),
/// 2. `POST /me/billing/topup` hands out the receiving number; the SMS
///    composer opens with it, and the number can be copied,
/// 3. `GET /me/billing/phone` is polled until the transfer shows up. Only the
///    server decides when money has arrived — the app never marks it paid.
class _PhonePaymentDialog extends StatefulWidget {
  const _PhonePaymentDialog({required this.amount});
  final int amount;

  @override
  State<_PhonePaymentDialog> createState() => _PhonePaymentDialogState();
}

class _PhonePaymentDialogState extends State<_PhonePaymentDialog> {
  static const _pollEvery = Duration(seconds: 5);

  MobileTopup? _topup;
  _PaymentOutcome? _outcome;
  String? _pendingMessage;
  bool _starting = false;
  bool _checking = false;
  String? _error;
  Timer? _poll;

  /// Transfers that existed before this attempt, so an older one is never
  /// mistaken for the payment being waited on.
  Set<int> _knownPayments = {};

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final billing = context.read<BillingProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final before = await billing.checkPhonePayments();
      _knownPayments = {for (final p in before.payments) p.id};
      final topup = await billing.startMobilePayment(widget.amount);
      if (!mounted) return;
      setState(() {
        _topup = topup;
        _starting = false;
      });
      _poll = Timer.periodic(_pollEvery, (_) => _check(silent: true));
      await _openSms(topup);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _error = apiErrorMessage(error, language);
      });
    }
  }

  Future<void> _openSms(MobileTopup topup) async {
    final body = Uri.encodeComponent('${topup.phone} ${widget.amount}');
    try {
      await launchUrl(Uri.parse('sms:$_topUpShortCode?body=$body'));
    } catch (_) {
      // No SMS app: the number is shown on screen to pay another way.
    }
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking || !mounted) return;
    final billing = context.read<BillingProvider>();
    final language = context.read<LanguageProvider>().language;
    if (!silent) setState(() => _checking = true);
    _checking = true;
    try {
      final result = await billing.checkPhonePayments();
      if (!mounted) return;
      final fresh = [
        for (final p in result.payments)
          if (!_knownPayments.contains(p.id)) p,
      ];
      final completed = fresh.where((p) => p.status == PhonePaymentStatus.completed);
      final rejected = fresh.where((p) => p.status == PhonePaymentStatus.rejected);
      final tooLow = fresh.where((p) => p.pendingReason == 'amount_too_low');
      if (completed.isNotEmpty) {
        _poll?.cancel();
        setState(() => _outcome = _PaymentOutcome.success);
      } else if (rejected.isNotEmpty) {
        _poll?.cancel();
        setState(() => _outcome = _PaymentOutcome.failed);
      } else if (tooLow.isNotEmpty) {
        final min = formatMoney(_topup?.phoneMinAmount ?? 20);
        final cur = context.read<AppSettingsProvider>().currencyLabel(language);
        setState(() => _pendingMessage = pickTr(
          language,
          tk: 'Tölegiňiz gelip ýetdi, emma bir geçirimde iň az $min $cur bolmaly. Balansa goşulmady.',
          ru: 'Перевод пришёл, но один перевод должен быть не меньше $min $cur. На баланс он не зачислен.',
          en: 'Your transfer arrived, but a single transfer must be at least $min $cur. It was not added to your balance.',
        ));
      } else if (!silent) {
        setState(() => _pendingMessage = null);
      }
    } catch (error) {
      if (!mounted) return;
      if (!silent) setState(() => _error = apiErrorMessage(error, language));
    } finally {
      _checking = false;
      if (mounted && !silent) setState(() {});
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
    final settings = context.watch<AppSettingsProvider>();
    final cur = settings.currencyLabel(language);
    final amount = widget.amount;

    if (_outcome != null) {
      return Dialog(
        backgroundColor: tokens.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: _PaymentResultPanel(
          outcome: _outcome!,
          amount: '$amount',
          onContinue: _finish,
          onRetry: () => setState(() => _outcome = null),
        ),
      );
    }

    final topup = _topup;
    final fee = settings.monthlyFee;
    final minAmount = formatMoney(topup?.phoneMinAmount ?? fee.toDouble());
    final notes = [
      (
        Icons.savings_outlined,
        t(tk: 'Iň az möçber', ru: 'Минимальная сумма', en: 'Minimum amount'),
        t(
          tk: 'Bir geçirimde iň az $minAmount $cur bolmaly.',
          ru: 'Один перевод должен быть не меньше $minAmount $cur.',
          en: 'A single transfer must be at least $minAmount $cur.',
        ),
      ),
      (
        Icons.phone_android_outlined,
        t(tk: 'Haýsy belgiden', ru: 'С какого номера', en: 'From which number'),
        t(
          tk: 'Töleg hasaba alnan telefon belgiňizden (${displayPhone(context.read<MasterProfileProvider>().phone)}) geçirilmeli.',
          ru: 'Перевод нужно делать с вашего номера (${displayPhone(context.read<MasterProfileProvider>().phone)}).',
          en: 'Send it from your registered number (${displayPhone(context.read<MasterProfileProvider>().phone)}).',
        ),
      ),
      (
        Icons.atm_outlined,
        t(tk: 'Bankomat we terminal', ru: 'Банкомат и терминал', en: 'ATM and terminal'),
        t(
          tk: 'Bankomat ýa-da terminal arkaly töleg kabul edilmeýär.',
          ru: 'Оплата через банкомат или терминал не принимается.',
          en: 'Payment via ATM or terminal is not accepted.',
        ),
      ),
      (
        Icons.chat_bubble_outline,
        t(tk: 'Soraglaryňyz barmy?', ru: 'Есть вопросы?', en: 'Have questions?'),
        t(
          tk: 'Habarlaşmak bölüminden bize ýazyp bilersiňiz.',
          ru: 'Напишите нам в разделе поддержки.',
          en: 'You can reach us through the support section.',
        ),
      ),
    ];

    return Dialog(
      backgroundColor: tokens.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: BoxDecoration(
              color: tokens.surfaceElevated,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.surface,
                    border: Border.all(color: tokens.accent.withValues(alpha: .35)),
                  ),
                  child: AppIcon(Icons.smartphone_outlined, color: tokens.accent, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  t(tk: 'Telefon arkaly töleg', ru: 'Оплата с телефона', en: 'Pay by phone'),
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  t(
                    tk: 'SIM kartyňyzyň balansyndan $amount $cur tutulýar.',
                    ru: 'С баланса SIM-карты спишется $amount $cur.',
                    en: '$amount $cur will be deducted from your SIM card balance.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: topup == null
                  ? _NotesList(notes: notes, heading: t(tk: 'ÜNS BERIŇ', ru: 'ВНИМАНИЕ', en: 'NOTE'))
                  : _TransferInstructions(
                      topup: topup,
                      amount: amount,
                      cur: cur,
                      pendingMessage: _pendingMessage,
                      onResendSms: () => _openSms(topup),
                    ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _FieldError(_error!),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Column(
              children: [
                if (topup == null)
                  _MasterActionButton(
                    label: _starting
                        ? t(tk: 'Garaşyň...', ru: 'Подождите...', en: 'Please wait...')
                        : t(tk: 'Tölegi tassykla', ru: 'Подтвердить оплату', en: 'Confirm payment'),
                    enabled: !_starting,
                    trailingArrow: true,
                    onTap: _start,
                  )
                else
                  _MasterActionButton(
                    label: _checking
                        ? t(tk: 'Barlanýar...', ru: 'Проверяем...', en: 'Checking...')
                        : t(tk: 'Tölegi barla', ru: 'Проверить оплату', en: 'Check payment'),
                    enabled: !_checking,
                    trailingArrow: true,
                    onTap: _check,
                  ),
                const SizedBox(height: 6),
                _DialogCancelButton(label: t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({required this.notes, required this.heading});
  final List<(IconData, String, String)> notes;
  final String heading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIcon(Icons.warning_amber_rounded, color: tokens.accent, size: 18),
            const SizedBox(width: 8),
            Text(
              heading,
              style: TextStyle(
                fontSize: 12.5,
                letterSpacing: .8,
                fontWeight: FontWeight.w700,
                color: tokens.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final note in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: tokens.surfaceElevated,
                  ),
                  child: AppIcon(note.$1, color: tokens.textPrimary, size: 19),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.$2, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        note.$3,
                        style: TextStyle(fontSize: 12.5, color: tokens.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Where to send the money, plus a live status line while waiting.
class _TransferInstructions extends StatelessWidget {
  const _TransferInstructions({
    required this.topup,
    required this.amount,
    required this.cur,
    required this.onResendSms,
    this.pendingMessage,
  });
  final MobileTopup topup;
  final int amount;
  final String cur;
  final String? pendingMessage;
  final VoidCallback onResendSms;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(tk: 'Pul geçirilmeli belgi', ru: 'Номер для перевода', en: 'Number to send to'),
          style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayPhone(topup.phone),
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: .4),
                ),
              ),
              IconButton(
                tooltip: t(tk: 'Göçür', ru: 'Копировать', en: 'Copy'),
                icon: AppIcon(Icons.copy_outlined, color: tokens.accent, size: 19),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: topup.phone));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t(tk: 'Göçürildi', ru: 'Скопировано', en: 'Copied'))),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t(
            tk: 'Bu belgä bir geçirimde $amount $cur iberiň (iň az ${formatMoney(topup.phoneMinAmount)} $cur). SMS programmasy açyldy: "$_topUpShortCode" belgisine ugradyň.',
            ru: 'Переведите на этот номер $amount $cur одним переводом (минимум ${formatMoney(topup.phoneMinAmount)} $cur). Откроется SMS на номер "$_topUpShortCode" — отправьте его.',
            en: 'Send $amount $cur to this number in a single transfer (minimum ${formatMoney(topup.phoneMinAmount)} $cur). The SMS to "$_topUpShortCode" opens pre-filled — just send it.',
          ),
          style: TextStyle(color: tokens.textSecondary, fontSize: 12.5, height: 1.45),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: onResendSms,
          icon: AppIcon(Icons.sms_outlined, size: 17, color: tokens.accent),
          label: Text(t(tk: 'SMS-i täzeden aç', ru: 'Открыть SMS снова', en: 'Open the SMS again')),
        ),
        if (pendingMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.warning.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(pendingMessage!, style: const TextStyle(fontSize: 12.5, height: 1.4)),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t(
                    tk: 'Töleg garaşylýar. Ýagdaý özi täzelener.',
                    ru: 'Ждём перевод. Статус обновится сам.',
                    en: 'Waiting for your transfer. This updates by itself.',
                  ),
                  style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
