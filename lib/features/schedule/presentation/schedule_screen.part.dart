part of '../../../app/komekci_app.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, this.initialDate});

  /// Deep-links the timeline to a specific day, e.g. tapped from the home
  /// dashboard's day list. Defaults to the seeded "today" when omitted.
  final DateTime? initialDate;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selected = widget.initialDate ?? DateTime(2026, 8, 13);
  late DateTime _weekStart = _startOfWeek(_selected);
  late DateTime _visibleMonth = DateTime(_selected.year, _selected.month);
  bool _showMonth = false;
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _select(DateTime date) {
    setState(() {
      _selected = date;
      _weekStart = _startOfWeek(date);
      _visibleMonth = DateTime(date.year, date.month);
    });
  }

  Future<void> _reschedule(Appointment appointment) async {
    final language = context.read<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final bookingProvider = context.read<BookingProvider>();
    final picked = await _pickAppointmentDateTime(
      context,
      language: language,
      initial: appointment.startsAt,
      minutes: appointment.minutes,
      excludeId: appointment.id,
      bookingProvider: bookingProvider,
    );
    if (picked == null || !mounted) return;
    // Re-checked here, not just in the picker's chip state, in case the
    // slot stopped being free between opening the sheet and confirming.
    if (bookingProvider.hasConflict(
      picked,
      appointment.minutes,
      excludeId: appointment.id,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t(
              tk: 'Bu wagt eýýäm alyndy.',
              ru: 'Это время уже занято.',
              en: 'This time is already taken.',
            ),
          ),
        ),
      );
      return;
    }
    bookingProvider.reschedule(appointment.id, picked);
  }

  Future<void> _confirmCancel(Appointment appointment) async {
    final language = context.read<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.event_busy_outlined,
      danger: true,
      title: t(
        tk: 'Ýazgyny ýatyrmaly?',
        ru: 'Отменить запись?',
        en: 'Cancel this booking?',
      ),
      message: t(
        tk: '${appointment.clientName} üçin bu ýazgy ýatyrylar.',
        ru: 'Запись для ${appointment.clientName} будет отменена.',
        en: 'The booking for ${appointment.clientName} will be cancelled.',
      ),
      confirmLabel: t(tk: 'Ýatyr', ru: 'Отменить', en: 'Cancel'),
      cancelLabel: t(tk: 'Ýok', ru: 'Нет', en: 'No'),
    );
    if (confirmed && mounted) {
      context.read<BookingProvider>().cancel(appointment.id);
    }
  }

  void _openActions(
    Appointment appointment,
    Customer? customer,
    AppLanguage language,
  ) {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customer == null
                      ? CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xffE6D2B1),
                          child: AppIcon(
                            Icons.person_outline,
                            size: 18,
                            color: tokens.textPrimary,
                          ),
                        )
                      : _CustomerAvatar(customer: customer, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.clientName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (customer != null)
                          Text(
                            _handleFor(customer),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Colors.black45,
                            ),
                          ),
                        Text(
                          appointment.serviceName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (customer != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _StatusBadge2(
                        label: _scheduleCustomerLabel(
                          customer.status,
                          language,
                        ),
                        color: _statusColor(customer.status),
                        bg: _statusBg(customer.status),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (appointment.status == AppointmentStatus.expected) ...[
                _SheetAction(
                  icon: Icons.check_circle_outline,
                  title: t(
                    tk: 'Geldi diýip belle',
                    ru: 'Отметить «Пришёл»',
                    en: 'Mark as arrived',
                  ),
                  subtitle: t(
                    tk: 'Müşderi geldi',
                    ru: 'Клиент пришёл',
                    en: 'Customer arrived',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<BookingProvider>().arrive(appointment.id);
                  },
                ),
                _SheetAction(
                  icon: Icons.person_off_outlined,
                  danger: true,
                  title: t(
                    tk: 'Gelmedi diýip belle',
                    ru: 'Отметить «Не пришёл»',
                    en: 'Mark as no-show',
                  ),
                  subtitle: t(
                    tk: 'Müşderi gelmedi',
                    ru: 'Клиент не пришёл',
                    en: 'Customer did not show up',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<BookingProvider>().markNoShow(appointment.id);
                  },
                ),
              ],
              if (appointment.status == AppointmentStatus.arrived)
                _SheetAction(
                  icon: Icons.task_alt_outlined,
                  title: t(
                    tk: 'Tamamlandy diýip belle',
                    ru: 'Отметить «Завершено»',
                    en: 'Mark as completed',
                  ),
                  subtitle: t(
                    tk: 'Hyzmat tamamlandy',
                    ru: 'Услуга завершена',
                    en: 'Service completed',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<BookingProvider>().complete(appointment.id);
                  },
                ),
              if (appointment.status == AppointmentStatus.expected ||
                  appointment.status == AppointmentStatus.arrived) ...[
                _SheetAction(
                  icon: Icons.calendar_month_outlined,
                  title: t(
                    tk: 'Wagty üýtgetmek',
                    ru: 'Изменить время',
                    en: 'Change time',
                  ),
                  subtitle: t(
                    tk: 'Bu ýazgyny başga wagtga geçirmek',
                    ru: 'Перенести эту запись',
                    en: 'Move this booking to another time',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _reschedule(appointment);
                  },
                ),
                _SheetAction(
                  icon: Icons.close,
                  danger: true,
                  title: t(
                    tk: 'Ýazgyny ýatyrmak',
                    ru: 'Отменить запись',
                    en: 'Cancel booking',
                  ),
                  subtitle: t(
                    tk: 'Bu ýazgyny ýatyrmak',
                    ru: 'Отменить эту запись',
                    en: 'Cancel this booking',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmCancel(appointment);
                  },
                ),
              ],
              if (customer != null)
                _SheetAction(
                  icon: Icons.person_outline,
                  title: t(
                    tk: 'Müşderi profiline geçmek',
                    ru: 'Перейти в профиль клиента',
                    en: 'Go to customer profile',
                  ),
                  subtitle: t(
                    tk: 'Müşderiniň maglumatlaryny görmek',
                    ru: 'Посмотреть данные клиента',
                    en: 'View customer details',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      pageRoute(CustomerDetailScreen(customerId: customer.id)),
                    );
                  },
                ),
              _SheetAction(
                icon: Icons.phone_outlined,
                callAction: true,
                title: t(tk: 'Jaň etmek', ru: 'Позвонить', en: 'Call'),
                subtitle: t(
                  tk: 'Müşdere jaň etmek',
                  ru: 'Позвонить клиенту',
                  en: 'Call the customer',
                ),
                onTap: () => launchUrl(
                  Uri(
                    scheme: 'tel',
                    path: (customer?.phone ?? '').replaceAll(' ', ''),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final bookingProvider = context.watch<BookingProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final canPop = Navigator.of(context).canPop();

    final dayAppointments = bookingProvider.onDay(_selected);
    final query = _searchController.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? dayAppointments
        : dayAppointments
              .where(
                (a) =>
                    a.clientName.toLowerCase().contains(query) ||
                    a.serviceName.toLowerCase().contains(query),
              )
              .toList();
    final entries = _buildTimeline(visible, _selected);

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Senenama', ru: 'Расписание', en: 'Schedule'),
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_sameDay(_selected, DateTime(2026, 8, 13)))
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () => _select(DateTime(2026, 8, 13)),
                  child: Text(t(tk: 'Bugün', ru: 'Сегодня', en: 'Today')),
                ),
              ),
            IconActionButton(
              icon: Icons.grid_view_outlined,
              onTap: () => Navigator.push(
                context,
                pageRoute(
                  WeekOverviewScreen(
                    weekStart: _weekStart,
                    onSelectDay: _select,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconActionButton(
              icon: Icons.search,
              onTap: () => setState(() => _searching = !_searching),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 10, 20, canPop ? 20 : 100),
          children: [
            if (_searching) ...[
              _SearchField(
                controller: _searchController,
                hint: t(
                  tk: 'Müşderi ýa-da hyzmat gözle',
                  ru: 'Поиск клиента или услуги',
                  en: 'Search customer or service',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
            ],
            _WeekStrip(
              weekStart: _weekStart,
              selected: _selected,
              language: language,
              onSelect: _select,
              onPrevWeek: () => setState(
                () => _weekStart = _weekStart.subtract(const Duration(days: 7)),
              ),
              onNextWeek: () => setState(
                () => _weekStart = _weekStart.add(const Duration(days: 7)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _showMonth = !_showMonth),
                child: Container(
                  width: 40,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: AppIcon(
                    _showMonth ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_showMonth) ...[
              _MonthCalendar(
                month: _visibleMonth,
                selected: _selected,
                language: language,
                onSelect: (date) {
                  _select(date);
                  setState(() => _showMonth = false);
                },
                onPrevMonth: () => setState(
                  () => _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                  ),
                ),
                onNextMonth: () => setState(
                  () => _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const AppIcon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: Colors.black45,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selected.day} ${_byLang(language, _monthsFullTk, _monthsFullRu, _monthsFullEn)[_selected.month - 1]}, ${_selected.year} • ${_byLang(language, _weekdaysFullTk, _weekdaysFullRu, _weekdaysFullEn)[_selected.weekday - 1]}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              EmptyState(
                icon: Icons.event_busy_outlined,
                title: t(
                  tk: 'Bu gün ýazgy ýok',
                  ru: 'На этот день записей нет',
                  en: 'No bookings today',
                ),
                text: t(
                  tk: 'Boş gün — dynç alyň!',
                  ru: 'Свободный день.',
                  en: 'A free day — enjoy the rest!',
                ),
              )
            else
              ...entries.map((entry) {
                if (entry is _ApptEntry) {
                  final customer = entry.appointment.customerId == null
                      ? null
                      : _findCustomer(
                          customerProvider.customers,
                          entry.appointment.customerId!,
                        );
                  return _AppointmentRow(
                    appointment: entry.appointment,
                    customer: customer,
                    language: language,
                    onTap: () =>
                        _openActions(entry.appointment, customer, language),
                  );
                }
                final free = entry as _FreeEntry;
                return _FreeSlotRow(
                  start: free.start,
                  end: free.end,
                  language: language,
                  onTap: () => _NewSlotAppointmentSheet.show(
                    context,
                    start: free.start,
                    end: free.end,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

