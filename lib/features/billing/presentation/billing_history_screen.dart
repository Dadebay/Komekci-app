part of '../../../app/komekci_app.dart';

String _ledgerTypeLabel(LedgerType type, AppLanguage language) =>
    switch (type) {
      LedgerType.topup => AppStrings.billingBalanceTopUp.select(language),
      LedgerType.charge => AppStrings.billingSubscriptionPayment.select(language),
      LedgerType.refund => AppStrings.billingRefund.select(language),
    };

String _ledgerStatusLabel(LedgerStatus status, AppLanguage language) =>
    switch (status) {
      LedgerStatus.succeeded => AppStrings.billingSuccessful.select(language),
      LedgerStatus.pending => AppStrings.billingPending.select(language),
      LedgerStatus.failed => AppStrings.billingFailed.select(language),
    };

Color _ledgerStatusColor(LedgerStatus status, AppThemeTokens tokens) =>
    switch (status) {
      LedgerStatus.succeeded => tokens.success,
      LedgerStatus.pending => tokens.warning,
      LedgerStatus.failed => tokens.danger,
    };

/// One row in the payment ledger — shared by [BillingScreen]'s recent-3
/// preview and the full [BillingHistoryScreen] list.
class _LedgerEntryTile extends StatelessWidget {
  const _LedgerEntryTile({required this.entry, required this.language});
  final LedgerTransaction entry;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final statusColor = _ledgerStatusColor(entry.status, tokens);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softLine(tokens)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIcon(
              Icons.credit_card_outlined,
              color: tokens.accent,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatDate(entry.createdAt)}  ${formatTime(TimeOfDay.fromDateTime(entry.createdAt))}',
                  style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  _ledgerTypeLabel(entry.type, language),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _ledgerStatusLabel(entry.status, language),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.type == LedgerType.charge ? '-' : '+'}${formatMoney(entry.amount)} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${AppStrings.billingBalance.select(language)}: ${formatMoney(entry.balanceAfter)}',
                style: TextStyle(fontSize: 11, color: tokens.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Full payment ledger, reached from [BillingScreen]'s "see all" link.
class BillingHistoryScreen extends StatelessWidget {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final billing = context.watch<BillingProvider>();
    final history = billing.history;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.billingPaymentHistory.select(language),
        action: const _BalanceChip(),
      ),
      body: SafeArea(
        child: history.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: AppStrings.billingNoPaymentHistory.select(language),
                  text: AppStrings.billingOnceYouMakeAPayment.select(language),
                ),
              )
            : RefreshIndicator(
                onRefresh: billing.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    for (final entry in history)
                      _LedgerEntryTile(entry: entry, language: language),
                    if (billing.hasMoreHistory)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: TextButton(
                          onPressed: billing.loadingMore
                              ? null
                              : billing.loadMoreHistory,
                          child: Text(
                            billing.loadingMore
                                ? AppStrings.billingLoading.select(language)
                                : AppStrings.billingShowMore.select(language),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
