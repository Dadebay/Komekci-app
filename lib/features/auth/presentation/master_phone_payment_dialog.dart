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
      final completed = fresh.where(
        (p) => p.status == PhonePaymentStatus.completed,
      );
      final rejected = fresh.where(
        (p) => p.status == PhonePaymentStatus.rejected,
      );
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
        setState(
          () => _pendingMessage = AppStrings.authYourTransferArrivedButA(min, cur).select(language),
        );
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
        AppStrings.authMinimumAmount.select(language),
        AppStrings.authASingleTransferMustBe(minAmount, cur).select(language),
      ),
      (
        Icons.phone_android_outlined,
        AppStrings.authFromWhichNumber.select(language),
        AppStrings.authSendItFromYourRegistered(displayPhone(context.read<MasterProfileProvider>().phone)).select(language),
      ),
      (
        Icons.atm_outlined,
        AppStrings.authAtmAndTerminal.select(language),
        AppStrings.authPaymentViaAtmOrTerminal.select(language),
      ),
      (
        Icons.chat_bubble_outline,
        AppStrings.authHaveQuestions.select(language),
        AppStrings.authYouCanReachUsThrough.select(language),
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                    border: Border.all(
                      color: tokens.accent.withValues(alpha: .35),
                    ),
                  ),
                  child: AppIcon(
                    Icons.smartphone_outlined,
                    color: tokens.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.authPayByPhone.select(language),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.authWillBeDeductedFromYour(amount, cur).select(language),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: topup == null
                  ? _NotesList(
                      notes: notes,
                      heading: AppStrings.authNote.select(language),
                    )
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
                  MasterActionButton(
                    label: _starting
                        ? AppStrings.requestsPleaseWait.select(language)
                        : AppStrings.authConfirmPayment.select(language),
                    enabled: !_starting,
                    trailingArrow: true,
                    onTap: _start,
                  )
                else
                  MasterActionButton(
                    label: _checking
                        ? AppStrings.authChecking.select(language)
                        : AppStrings.authCheckPayment.select(language),
                    enabled: !_checking,
                    trailingArrow: true,
                    onTap: _check,
                  ),
                const SizedBox(height: 6),
                _DialogCancelButton(
                  label: AppStrings.servicesCancel.select(language),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
