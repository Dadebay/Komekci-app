part of '../../../app/komekci_app.dart';

String _ledgerTypeLabel(LedgerEntryType type, AppLanguage language) =>
    switch (type) {
      LedgerEntryType.topUp => pickTr(
        language,
        tk: 'Balans doldurmak',
        ru: 'Пополнение баланса',
        en: 'Balance top-up',
      ),
      LedgerEntryType.subscriptionCharge => pickTr(
        language,
        tk: 'Abuna tölegi',
        ru: 'Оплата подписки',
        en: 'Subscription payment',
      ),
    };

String _ledgerStatusLabel(LedgerEntryStatus status, AppLanguage language) =>
    switch (status) {
      LedgerEntryStatus.success => pickTr(
        language,
        tk: 'Üstünlikli',
        ru: 'Успешно',
        en: 'Successful',
      ),
      LedgerEntryStatus.pending => pickTr(
        language,
        tk: 'Garaşylýar',
        ru: 'В обработке',
        en: 'Pending',
      ),
      LedgerEntryStatus.failed => pickTr(
        language,
        tk: 'Şowsuz',
        ru: 'Не удалось',
        en: 'Failed',
      ),
    };

Color _ledgerStatusColor(LedgerEntryStatus status, AppThemeTokens tokens) =>
    switch (status) {
      LedgerEntryStatus.success => tokens.success,
      LedgerEntryStatus.pending => tokens.warning,
      LedgerEntryStatus.failed => tokens.danger,
    };

/// One row in the payment ledger — shared by [BillingScreen]'s recent-3
/// preview and the full [BillingHistoryScreen] list.
class _LedgerEntryTile extends StatelessWidget {
  const _LedgerEntryTile({required this.entry, required this.language});
  final LedgerEntry entry;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
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
              color: const Color(0xffFDF9F2),
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
                  '${formatDate(entry.date)}  ${formatTime(TimeOfDay.fromDateTime(entry.date))}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
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
                '-${entry.amount} ${t(tk: "manat", ru: "манат", en: "TMT")}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${t(tk: "Balans", ru: "Баланс", en: "Balance")}: ${entry.resultingBalance}',
                style: const TextStyle(fontSize: 11, color: Colors.black45),
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
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final history = context.watch<BillingProvider>().history;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(
          tk: 'Töleg taryhy',
          ru: 'История платежей',
          en: 'Payment history',
        ),
        action: const _BalanceChip(),
      ),
      body: SafeArea(
        child: history.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: t(
                    tk: 'Töleg taryhy boş',
                    ru: 'История платежей пуста',
                    en: 'No payment history',
                  ),
                  text: t(
                    tk: 'Töleg edeniňizden soň, ol şu ýerde görüner.',
                    ru: 'После оплаты она появится здесь.',
                    en: 'Once you make a payment, it will appear here.',
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: history
                    .map(
                      (entry) =>
                          _LedgerEntryTile(entry: entry, language: language),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
