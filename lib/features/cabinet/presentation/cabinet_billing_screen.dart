part of '../../../app/komekci_app.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final billing = context.watch<BillingProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final recentHistory = billing.history.take(2).toList();
    final tokens = context.appTokens;
    final currency = settings.currencyLabel(language);
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.cabinetBillingSubscription.select(language),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: billing.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              if (!billing.loaded)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: billing.error == null
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              Text(
                                AppStrings.cabinetCouldNotLoadBillingDetails
                                    .select(language),
                              ),
                              TextButton(
                                onPressed: billing.refresh,
                                child: Text(
                                  AppStrings.cabinetRetry.select(language),
                                ),
                              ),
                            ],
                          ),
                  ),
                )
              else ...[
                const _PromoCard(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.cabinetCurrentBalance.select(language),
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.textSecondary,
                              ),
                            ),
                          ),
                          _SubscriptionStatusChip(
                            status: billing.status,
                            language: language,
                            promo: billing.promo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${billing.balance} $currency',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Divider(height: 1, color: tokens.border),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.cabinetSubscriptionPrice.select(
                                language,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '${settings.monthlyFee} $currency / ${AppStrings.cabinetMo.select(language)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (billing.nextChargeAt != null) ...[
                        const SizedBox(height: 12),
                        _SubscriptionDateRow(
                          icon: Icons.calendar_month_outlined,
                          label: AppStrings.cabinetNextPayment.select(language),
                          value: formatDate(billing.nextChargeAt!),
                        ),
                      ],
                    ],
                  ),
                ),
                if (billing.status != SubscriptionStatus.active &&
                    billing.promo?.isAvailable != true &&
                    billing.promo?.active != true &&
                    billing.promo?.paidAccess != true) ...[
                  const SizedBox(height: 12),
                  _InfoBanner(
                    icon: Icons.info_outline,
                    text: _renewalText(billing, language),
                  ),
                ],
                const SizedBox(height: 16),
                MasterActionButton(
                  label: AppStrings.cabinetTopUpBalance.select(language),
                  enabled: true,
                  leading: Icons.add,
                  onTap: () => Navigator.push(
                    context,
                    pageRoute(
                      const MasterSubscriptionScreen(onboarding: false),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.billingPaymentHistory.select(language),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    if (recentHistory.isNotEmpty)
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          pageRoute(const BillingHistoryScreen()),
                        ),
                        child: Text(AppStrings.cabinetViewAll.select(language)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (recentHistory.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: tokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Row(
                      children: [
                        AppIcon(
                          Icons.receipt_long_outlined,
                          color: tokens.accent,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.cabinetNoPaymentsYetTheyWill.select(
                              language,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...recentHistory.map(
                    (entry) =>
                        _LedgerEntryTile(entry: entry, language: language),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _renewalText(BillingProvider billing, AppLanguage language) {
  final next = billing.nextChargeAt;
  switch (billing.status) {
    case SubscriptionStatus.suspended:
      return AppStrings.cabinetYourSubscriptionIsNotActive.select(language);
    case SubscriptionStatus.grace:
      return AppStrings.cabinetPaymentIsDueButBookings.select(language);
    case SubscriptionStatus.active:
      if (next == null) {
        return AppStrings.cabinetYourSubscriptionIsActive.select(language);
      }
      final days = next.difference(DateTime.now()).inDays;
      return AppStrings.cabinetYourSubscriptionWillAutomaticallyRenew(
        days,
        formatDate(next),
      ).select(language);
  }
}
