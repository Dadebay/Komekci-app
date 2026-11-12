part of '../../../app/komekci_app.dart';

/// Subscription and top-up. The monthly price comes from the server; the
/// amount offered is 1, 2, 3 or 6 months of it. The balance and subscription
/// state shown here are the server's — after a payment the app only asks
/// again, it never marks anything paid itself.
///
/// [onboarding] is true when this is step 4 of master sign-up (shows the
/// progress dots); the cabinet's "Top up" opens it with false.
class MasterSubscriptionScreen extends StatefulWidget {
  const MasterSubscriptionScreen({
    super.key,
    this.onboarding = true,
    this.onLeave,
  });
  final bool onboarding;

  /// Offered when this is the only route and the master needs another account.
  final VoidCallback? onLeave;

  @override
  State<MasterSubscriptionScreen> createState() =>
      _MasterSubscriptionScreenState();
}

class _MasterSubscriptionScreenState extends State<MasterSubscriptionScreen> {
  /// Months offered as top-up amounts.
  static const _monthChoices = [1, 2, 3, 6];

  int _monthsIndex = 0;
  bool _payByPhone = true;

  @override
  void initState() {
    super.initState();
    // Fresh balance/status whenever the page opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BillingProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final settings = context.watch<AppSettingsProvider>();
    final billing = context.watch<BillingProvider>();
    final cur = settings.currencyLabel(language);
    final fee = settings.monthlyFee;
    final months = _monthChoices[_monthsIndex];
    final amount = fee * months;
    // `phone: null` in /me/billing means the server has no receiving number
    // free, so paying by phone cannot start (POST topup would 404).
    final phoneAvailable = !billing.loaded || billing.billing?.phone != null;
    final byPhone = _payByPhone && phoneAvailable;

    return PopScope(
      canPop: widget.onLeave == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave?.call();
      },
      child: Scaffold(
        backgroundColor: tokens.surface,
        appBar: widget.onboarding
            ? _MasterSetupHeader(
                title: AppStrings.authSubscriptionPayment.select(language),
                onBack: widget.onLeave,
              )
            : CabinetAppBar(
                title: AppStrings.cabinetTopUpBalance.select(language),
                onBack: widget.onLeave,
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              widget.onboarding ? 24 : 20,
              8,
              widget.onboarding ? 24 : 20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.onboarding) ...[
                  const _MasterProgressIndicator(step: 4),
                  const SizedBox(height: 22),
                  if (billing.loaded) ...[
                    _SubscriptionStatusStrip(billing: billing, cur: cur),
                    const SizedBox(height: 16),
                  ],
                  _PlanCard(fee: fee, cur: cur),
                  const SizedBox(height: 28),
                ] else ...[
                  _TopUpBalanceSummary(
                    balance: billing.loaded ? billing.balance : '—',
                    fee: fee,
                    cur: cur,
                  ),
                  const SizedBox(height: 22),
                ],
                Text(
                  widget.onboarding
                      ? AppStrings.authHowManyMonths.select(language)
                      : AppStrings.authChooseAnAmount.select(language),
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.onboarding
                      ? AppStrings.authTheAmountGoesToYour.select(language)
                      : AppStrings.authMoneyGoesToYourBalance(fee, cur).select(language),
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: widget.onboarding ? 10 : 8,
                  crossAxisSpacing: widget.onboarding ? 10 : 8,
                  childAspectRatio: widget.onboarding ? 1.95 : 2.45,
                  children: [
                    for (var i = 0; i < _monthChoices.length; i++)
                      _AmountOption(
                        amount: fee * _monthChoices[i],
                        months: _monthChoices[i],
                        cur: cur,
                        selected: i == _monthsIndex,
                        compact: !widget.onboarding,
                        onTap: () => setState(() => _monthsIndex = i),
                      ),
                  ],
                ),
                SizedBox(height: widget.onboarding ? 28 : 22),
                Text(
                  AppStrings.authPaymentMethod.select(language),
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _PaymentMethodTile(
                  icon: Icons.smartphone_outlined,
                  title: AppStrings.authPhoneBalance.select(language),
                  subtitle: phoneAvailable
                      ? AppStrings.authTransferFromYourSimCard.select(language)
                      : AppStrings.authNoPaymentPhoneNumberIs.select(language),
                  enabled: phoneAvailable,
                  selected: byPhone,
                  compact: !widget.onboarding,
                  onTap: () => setState(() => _payByPhone = true),
                ),
                const SizedBox(height: 8),
                _PaymentMethodTile(
                  icon: Icons.credit_card_outlined,
                  title: AppStrings.authBankCard.select(language),
                  subtitle: 'Halkbank, Rysgal, Senagat',
                  selected: !byPhone,
                  compact: !widget.onboarding,
                  onTap: () => setState(() => _payByPhone = false),
                ),
                if (widget.onboarding) ...[
                  const SizedBox(height: 20),
                  _HowBalanceWorks(fee: fee, cur: cur),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: tokens.surface,
            border: Border(top: BorderSide(color: tokens.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.authToPay.select(language),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$amount $cur',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        AppStrings.authForMonth(months, months == 1 ? '' : 's').select(language),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: MasterActionButton(
                      label: widget.onboarding
                          ? AppStrings.authPay.select(language)
                          : AppStrings.authContinueToPay.select(language),
                      enabled: true,
                      trailingArrow: true,
                      onTap: () => _pay(amount, byPhone),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pay(int amount, bool byPhone) async {
    await showDialog<void>(
      context: context,
      builder: (_) => byPhone
          ? _PhonePaymentDialog(amount: amount)
          : _CardPaymentDialog(amount: amount),
    );
  }
}
