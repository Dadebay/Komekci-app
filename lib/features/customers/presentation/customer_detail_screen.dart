part of '../../../app/komekci_app.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    // The list only carries totals; the visit history and note come with
    // the full card.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        runApi(context, () async {
          await context.read<CustomerProvider>().loadCard(widget.customerId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final provider = context.watch<CustomerProvider>();
    final customer = _findCustomer(provider.customers, widget.customerId);
    if (customer == null) {
      Future.microtask(() {
        if (context.mounted) Navigator.maybePop(context);
      });
      return const SizedBox.shrink();
    }
    final recentVisits = customer.visits.take(4).toList();

    final tokens = context.appTokens;

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Müşderi maglumatlary', ru: 'Информация о клиенте', en: 'Customer details'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                children: [
                  _CustomerDetailHero(customer: customer, language: language),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.content_cut,
                          accent: tokens.accent,
                          label: t(tk: 'Soňky hyzmat', ru: 'Последняя услуга', en: 'Last service'),
                          value: customer.lastCompletedVisit == null
                              ? '—'
                              : customer.lastCompletedVisit!.serviceName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.calendar_month_outlined,
                          accent: _statusColor(CustomerStatus.newClient, tokens),
                          label: t(tk: 'Indiki ýazgy', ru: 'Следующая запись', en: 'Next booking'),
                          value: customer.nextVisit == null
                              ? t(tk: 'Ýok', ru: 'Нет', en: 'None')
                              : '${formatDate(customer.nextVisit!)} • ${formatTime(TimeOfDay.fromDateTime(customer.nextVisit!))}',
                          chevron: true,
                          onTap: () => Navigator.push(
                            context,
                            pageRoute(
                              NewAppointmentScreen(customer: customer),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (customer.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 34,
                            decoration: BoxDecoration(
                              color: tokens.accent.withValues(alpha: .5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t(tk: 'Bellik', ru: 'Заметка', en: 'Note'),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: tokens.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  customer.note,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t(tk: 'Sapar taryhy', ru: 'История визитов', en: 'Visit history'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (customer.visits.length > recentVisits.length)
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            pageRoute(
                              CustomerVisitsScreen(customerId: customer.id),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                t(tk: 'Ählisini görmek', ru: 'Смотреть все', en: 'View all'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: tokens.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppIcon(
                                Icons.chevron_right,
                                size: 14,
                                color: tokens.accent,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (recentVisits.isEmpty)
                    EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: t(tk: 'Sapar ýok', ru: 'Визитов пока нет', en: 'No visits yet'),
                      text: t(tk: 'Bu müşderi entek gelen däldir.', ru: 'Клиент ещё не приходил.', en: 'This customer has not visited yet.'),
                    )
                  else
                    ...recentVisits.map(
                      (visit) => _VisitRow(visit: visit, language: language),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _OutlineActionButton(
                      icon: Icons.phone_outlined,
                      label: t(tk: 'Habarlaşmak', ru: 'Связаться', en: 'Contact'),
                      onTap: () => launchUrl(
                        Uri(
                          scheme: 'tel',
                          path: customer.phone.replaceAll(' ', ''),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MasterActionButton(
                      label: t(tk: 'Täze ýazgy etmek', ru: 'Новая запись', en: 'New booking'),
                      enabled: true,
                      leading: Icons.calendar_month_outlined,
                      onTap: () => Navigator.push(
                        context,
                        pageRoute(NewAppointmentScreen(customer: customer)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
