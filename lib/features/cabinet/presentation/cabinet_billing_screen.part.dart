part of '../../../app/komekci_app.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final billing = context.watch<BillingProvider>();
    final recentHistory = billing.history.take(3).toList();
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(
          tk: 'Töleg we Abuna',
          ru: 'Оплата и подписка',
          en: 'Billing & subscription',
        ),
        action: const _BalanceChip(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              t(
                tk: '1. Häzirki abuna',
                ru: '1. Текущая подписка',
                en: '1. Current subscription',
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _softLine(tokens)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.textPrimary,
                        ),
                        child: Text(
                          '♔',
                          style: TextStyle(fontSize: 20, color: tokens.accent),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t(
                                tk: 'Master abuna',
                                ru: 'Подписка мастера',
                                en: 'Master subscription',
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_monthlyFee ${t(tk: "manat / aý", ru: "манат / мес.", en: "TMT / mo.")}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffEFF7EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t(tk: 'Aktiw', ru: 'Активна', en: 'Active'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff3E8E41),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: _softLine(tokens), height: 1),
                  const SizedBox(height: 14),
                  _SubscriptionDateRow(
                    icon: Icons.calendar_today_outlined,
                    label: t(
                      tk: 'Soňky töleg',
                      ru: 'Последний платёж',
                      en: 'Last payment',
                    ),
                    value: formatDate(billing.lastPaymentDate),
                  ),
                  const SizedBox(height: 10),
                  _SubscriptionDateRow(
                    icon: Icons.calendar_month_outlined,
                    label: t(
                      tk: 'Indiki töleg',
                      ru: 'Следующий платёж',
                      en: 'Next payment',
                    ),
                    value: formatDate(billing.nextPaymentDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InfoBanner(
              icon: Icons.info_outline,
              text: t(
                tk: 'Siziň abunaňyz ${billing.nextPaymentDate.difference(DateTime.now()).inDays} gün soň awtomatiki täzelener. Indiki töleg senesi: ${formatDate(billing.nextPaymentDate)}',
                ru: 'Ваша подписка автоматически продлится через ${billing.nextPaymentDate.difference(DateTime.now()).inDays} дней. Дата следующего платежа: ${formatDate(billing.nextPaymentDate)}',
                en: 'Your subscription will automatically renew in ${billing.nextPaymentDate.difference(DateTime.now()).inDays} days. Next payment date: ${formatDate(billing.nextPaymentDate)}',
              ),
            ),
            const SizedBox(height: 26),
            Text(
              t(
                tk: '2. Balans doldurmak',
                ru: '2. Пополнение баланса',
                en: '2. Top up balance',
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _MasterActionButton(
              label: t(
                tk: 'Balans doldurmak',
                ru: 'Пополнить баланс',
                en: 'Top up balance',
              ),
              enabled: true,
              leading: Icons.add,
              onTap: () => Navigator.push(
                context,
                pageRoute(const MasterSubscriptionScreen()),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t(
                      tk: '3. Töleg taryhy',
                      ru: '3. История платежей',
                      en: '3. Payment history',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    pageRoute(const BillingHistoryScreen()),
                  ),
                  child: Row(
                    children: [
                      Text(
                        t(
                          tk: 'Ählisini görmek',
                          ru: 'Смотреть все',
                          en: 'View all',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const AppIcon(
                        Icons.chevron_right,
                        color: Colors.black26,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentHistory.isEmpty)
              EmptyState(
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
              )
            else
              ...recentHistory.map(
                (entry) => _LedgerEntryTile(entry: entry, language: language),
              ),
          ],
        ),
      ),
    );
  }
}
