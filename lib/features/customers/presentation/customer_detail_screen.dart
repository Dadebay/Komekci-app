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
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final provider = context.watch<CustomerProvider>();
    final customer = _findCustomer(provider.customers, widget.customerId);
    if (customer == null) {
      Future.microtask(() {
        if (context.mounted) Navigator.maybePop(context);
      });
      return const SizedBox.shrink();
    }
    final recentVisits = customer.visits.take(4).toList();

    final statusColor = _statusColor(customer.status);
    final tokens = context.appTokens;

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: tk ? 'Müşderi maglumatlary' : 'Информация о клиенте',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _statusBg(customer.status),
                          tokens.surfaceElevated,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: statusColor,
                                  width: 2,
                                ),
                              ),
                              child: _CustomerAvatar(
                                customer: customer,
                                radius: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const AppIcon(
                                        Icons.phone_outlined,
                                        size: 12,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        customer.phone.isEmpty
                                            ? '—'
                                            : displayPhone(customer.phone),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: tokens.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _StatusPill(
                                    status: customer.status,
                                    tk: tk,
                                  ),
                                ],
                              ),
                            ),
                            _SquareIconButton(
                              icon: Icons.edit_outlined,
                              onTap: () => Navigator.push(
                                context,
                                pageRoute(
                                  CustomerFormScreen(customer: customer),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: tokens.surfaceElevated.withValues(alpha: .7),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _HeaderStat(
                                value: '${customer.totalVisits}',
                                label: tk ? 'Sapar' : 'Визитов',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: tokens.surfaceElevated.withValues(
                                alpha: .7,
                              ),
                            ),
                            Expanded(
                              child: _HeaderStat(
                                value: '${customer.totalSpent}',
                                label: tk ? 'Manat' : 'Манат',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: tokens.surfaceElevated.withValues(
                                alpha: .7,
                              ),
                            ),
                            Expanded(
                              child: _HeaderStat(
                                value: customer.lastVisitDate == null
                                    ? '—'
                                    : formatDate(customer.lastVisitDate!),
                                label: tk ? 'Şodny gelişi' : 'Визит',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.content_cut,
                          accent: tokens.accent,
                          label: tk ? 'Şodny hyzmat' : 'Последняя услуга',
                          value: customer.lastCompletedVisit == null
                              ? '—'
                              : customer.lastCompletedVisit!.serviceName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.calendar_month_outlined,
                          accent: _statusColor(CustomerStatus.newClient),
                          label: tk ? 'Indiki ýazgy' : 'Следующая запись',
                          value: customer.nextVisit == null
                              ? (tk ? 'Ýok' : 'Нет')
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
                        color: const Color(0xffFAF7F0),
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
                                  tk ? 'Bellik' : 'Заметка',
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
                        tk ? 'Sapar taryhy' : 'История визитов',
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
                                tk ? 'Ählisini görmek' : 'Смотреть все',
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
                      title: tk ? 'Sapar ýok' : 'Визитов пока нет',
                      text: tk
                          ? 'Bu müşderi entek gelen däldir.'
                          : 'Клиент ещё не приходил.',
                    )
                  else
                    ...recentVisits.map(
                      (visit) => _VisitRow(visit: visit, tk: tk),
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
                      label: tk ? 'Habarlaşmak' : 'Связаться',
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
                    child: _MasterActionButton(
                      label: tk ? 'Täze ýazgy etmek' : 'Новая запись',
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

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          color: context.appTokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = Colors.black45,
    this.chevron = false,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(icon, size: 12, color: accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: tokens.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (chevron)
                  AppIcon(
                    Icons.chevron_right,
                    size: 14,
                    color: tokens.disabled,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit, required this.tk});
  final CustomerVisit visit;
  final bool tk;

  static const _monthsTk = [
    'Ýan',
    'Few',
    'Mart',
    'Apr',
    'Maý',
    'Iýun',
    'Iýul',
    'Awg',
    'Sen',
    'Okt',
    'Noý',
    'Dek',
  ];
  static const _monthsRu = [
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  visit.date.day.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: tokens.textPrimary,
                  ),
                ),
                Text(
                  (tk ? _monthsTk : _monthsRu)[visit.date.month - 1],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.serviceName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatTime(TimeOfDay.fromDateTime(visit.date)),
                  style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${visit.price} ${context.watch<AppSettingsProvider>().currencyLabel(tk ? AppLanguage.tk : AppLanguage.ru)}',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 17, color: tokens.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerVisitsScreen extends StatelessWidget {
  const CustomerVisitsScreen({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final customer = _findCustomer(
      context.watch<CustomerProvider>().customers,
      customerId,
    );
    return Scaffold(
      backgroundColor: context.appTokens.surface,
      appBar: CabinetAppBar(title: tk ? 'Sapar taryhy' : 'История визитов'),
      body: SafeArea(
        child: customer == null
            ? const SizedBox.shrink()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: customer.visits.length,
                itemBuilder: (_, index) =>
                    _VisitRow(visit: customer.visits[index], tk: tk),
              ),
      ),
    );
  }
}

