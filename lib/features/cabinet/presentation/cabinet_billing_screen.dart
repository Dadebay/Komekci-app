part of '../../../app/komekci_app.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final billing = context.watch<BillingProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final recentHistory = billing.history.take(2).toList();
    final tokens = context.appTokens;
    final currency = settings.currencyLabel(language);
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(
          tk: 'Töleg we Abuna',
          ru: 'Оплата и подписка',
          en: 'Billing & subscription',
        ),
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
                                t(
                                  tk: 'Töleg maglumatlaryny ýükläp bolmady.',
                                  ru: 'Не удалось загрузить данные об оплате.',
                                  en: 'Could not load billing details.',
                                ),
                              ),
                              TextButton(
                                onPressed: billing.refresh,
                                child: Text(
                                  t(
                                    tk: 'Gaýtadan synanyş',
                                    ru: 'Повторить',
                                    en: 'Retry',
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                )
              else ...[
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
                              t(
                                tk: 'Häzirki balans',
                                ru: 'Текущий баланс',
                                en: 'Current balance',
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.textSecondary,
                              ),
                            ),
                          ),
                          _SubscriptionStatusChip(
                            status: billing.status,
                            language: language,
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
                              t(
                                tk: 'Abuna bahasy',
                                ru: 'Стоимость подписки',
                                en: 'Subscription price',
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '${settings.monthlyFee} $currency / ${t(tk: "aý", ru: "мес.", en: "mo.")}',
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
                          label: t(
                            tk: 'Indiki töleg',
                            ru: 'Следующий платёж',
                            en: 'Next payment',
                          ),
                          value: formatDate(billing.nextChargeAt!),
                        ),
                      ],
                    ],
                  ),
                ),
                if (billing.status != SubscriptionStatus.active) ...[
                  const SizedBox(height: 12),
                  _InfoBanner(
                    icon: Icons.info_outline,
                    text: _renewalText(billing, language),
                  ),
                ],
                const SizedBox(height: 16),
                _MasterActionButton(
                  label: t(
                    tk: 'Balans doldur',
                    ru: 'Пополнить баланс',
                    en: 'Top up balance',
                  ),
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
                        t(
                          tk: 'Töleg taryhy',
                          ru: 'История платежей',
                          en: 'Payment history',
                        ),
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
                        child: Text(t(tk: 'Ählisi', ru: 'Все', en: 'View all')),
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
                            t(
                              tk: 'Entek töleg ýok. Tölegleriňiz şu ýerde görkeziler.',
                              ru: 'Платежей пока нет. Они появятся здесь.',
                              en: 'No payments yet. They will appear here.',
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
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
  final next = billing.nextChargeAt;
  switch (billing.status) {
    case SubscriptionStatus.suspended:
      return t(
        tk: 'Abuna işjeň däl. Täze ýazgylar ýapyk. Açmak üçin balansyňyzy dolduryň.',
        ru: 'Подписка не активна, новые записи закрыты. Пополните баланс, чтобы открыть их.',
        en: 'Your subscription is not active and new bookings are closed. Top up your balance to reopen them.',
      );
    case SubscriptionStatus.grace:
      return t(
        tk: 'Tölegiň wagty ýetdi, ýöne ýazgylar entek kabul edilýär. Tiz wagtda balansyňyzy dolduryň.',
        ru: 'Пора платить, но записи пока принимаются. Пополните баланс как можно скорее.',
        en: 'Payment is due but bookings are still open. Please top up soon.',
      );
    case SubscriptionStatus.active:
      if (next == null) {
        return t(
          tk: 'Abunaňyz işjeň.',
          ru: 'Ваша подписка активна.',
          en: 'Your subscription is active.',
        );
      }
      final days = next.difference(DateTime.now()).inDays;
      return t(
        tk: 'Siziň abunaňyz $days gün soň awtomatiki täzelener. Indiki töleg senesi: ${formatDate(next)}',
        ru: 'Ваша подписка автоматически продлится через $days дней. Дата следующего платежа: ${formatDate(next)}',
        en: 'Your subscription will automatically renew in $days days. Next payment date: ${formatDate(next)}',
      );
  }
}

class _SubscriptionStatusChip extends StatelessWidget {
  const _SubscriptionStatusChip({required this.status, required this.language});
  final SubscriptionStatus status;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final (label, color) = switch (status) {
      SubscriptionStatus.active => (
        pickTr(language, tk: 'Aktiw', ru: 'Активна', en: 'Active'),
        tokens.success,
      ),
      SubscriptionStatus.grace => (
        pickTr(
          language,
          tk: 'Töleg wagty',
          ru: 'Льготный период',
          en: 'Grace period',
        ),
        tokens.warning,
      ),
      SubscriptionStatus.suspended => (
        pickTr(
          language,
          tk: 'Duruzylan',
          ru: 'Приостановлена',
          en: 'Suspended',
        ),
        tokens.danger,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
