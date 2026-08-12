part of '../../../app/komekci_app.dart';

const _weekdaysTk = ['Du', 'Si', 'Ça', 'Pe', 'An', 'Şe', 'Ýe'];
const _weekdaysRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
const _weekdaysFullTk = [
  'Duşenbe',
  'Sişenbe',
  'Çarşenbe',
  'Penşenbe',
  'Anna',
  'Şenbe',
  'Ýekşenbe',
];
const _weekdaysFullRu = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
];
const _monthsShortTk = [
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
const _monthsFullTk = [
  'Ýanwar',
  'Fewral',
  'Mart',
  'Aprel',
  'Maý',
  'Iýun',
  'Iýul',
  'Awgust',
  'Sentýabr',
  'Oktýabr',
  'Noýabr',
  'Dekabr',
];
const _monthsFullRu = [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
];

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _startOfWeek(DateTime date) => DateTime(
  date.year,
  date.month,
  date.day,
).subtract(Duration(days: date.weekday - 1));

String _handleFor(Customer customer) {
  String clean(String value) => value
      .toLowerCase()
      .replaceAll('ý', 'y')
      .replaceAll('ç', 'c')
      .replaceAll('ş', 'sh')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ň', 'n')
      .replaceAll('ä', 'a')
      .replaceAll(RegExp(r'[^a-z]'), '');
  final parts = customer.name.split(' ');
  final first = clean(parts.first);
  final last = parts.length > 1 ? clean(parts.last) : '';
  return '@$first${last.isEmpty ? '' : '_${last.length > 5 ? last.substring(0, 5) : last}'}';
}

String _scheduleCustomerLabel(CustomerStatus status, bool tk) =>
    switch (status) {
      CustomerStatus.vip => 'VIP',
      CustomerStatus.regular => tk ? 'Hemişelik' : 'Постоянный',
      CustomerStatus.newClient => tk ? 'Täze müşderi' : 'Новый клиент',
    };

Color _apptStatusBg(AppointmentStatus status) => switch (status) {
  AppointmentStatus.expected => const Color(0xffFCEDD9),
  AppointmentStatus.arrived => const Color(0xffDCF3E3),
  AppointmentStatus.completed => const Color(0xffEDEDEA),
  AppointmentStatus.cancelled ||
  AppointmentStatus.noShow => const Color(0xffFBE3E0),
};

Color _apptStatusColor(AppointmentStatus status) => switch (status) {
  AppointmentStatus.expected => const Color(0xffB8720C),
  AppointmentStatus.arrived => const Color(0xff1F8A4C),
  AppointmentStatus.completed => Colors.black54,
  AppointmentStatus.cancelled ||
  AppointmentStatus.noShow => const Color(0xffC0392B),
};

String _apptStatusLabel(AppointmentStatus status, bool tk) => switch (status) {
  AppointmentStatus.expected => tk ? 'Garaşylýar' : 'Ожидание',
  AppointmentStatus.arrived => tk ? 'Geldi' : 'Пришёл',
  AppointmentStatus.completed => tk ? 'Tamamlandy' : 'Завершено',
  AppointmentStatus.cancelled => tk ? 'Ýatyryldy' : 'Отменено',
  AppointmentStatus.noShow => tk ? 'Gelmedi' : 'Не пришёл',
};

sealed class _TimelineEntry {}

class _ApptEntry extends _TimelineEntry {
  _ApptEntry(this.appointment);
  final Appointment appointment;
}

class _FreeEntry extends _TimelineEntry {
  _FreeEntry(this.start, this.end);
  final DateTime start;
  final DateTime end;
}

/// Fills the gaps between [appointments] (already sorted, same day) with
/// free-time blocks across the 09:00–19:00 working window.
List<_TimelineEntry> _buildTimeline(
  List<Appointment> appointments,
  DateTime day,
) {
  final workStart = DateTime(day.year, day.month, day.day, 9);
  final workEnd = DateTime(day.year, day.month, day.day, 19);
  final entries = <_TimelineEntry>[];
  var cursor = workStart;
  for (final appt in appointments) {
    if (appt.startsAt.isAfter(cursor)) {
      entries.add(_FreeEntry(cursor, appt.startsAt));
    }
    entries.add(_ApptEntry(appt));
    final apptEnd = appt.startsAt.add(const Duration(minutes: 30));
    if (apptEnd.isAfter(cursor)) cursor = apptEnd;
  }
  if (workEnd.isAfter(cursor)) entries.add(_FreeEntry(cursor, workEnd));
  return entries;
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selected = DateTime(2026, 8, 13);
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
    final tk = context.read<LanguageProvider>().isTurkmen;
    final picked = await _pickAppointmentDateTime(
      context,
      tk: tk,
      initial: appointment.startsAt,
    );
    if (picked == null || !mounted) return;
    context.read<BookingProvider>().reschedule(appointment.id, picked);
  }

  Future<void> _confirmCancel(Appointment appointment) async {
    final tk = context.read<LanguageProvider>().isTurkmen;
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.event_busy_outlined,
      danger: true,
      title: tk ? 'Ýazgyny ýatyrmaly?' : 'Отменить запись?',
      message: tk
          ? '${appointment.clientName} üçin bu ýazgy ýatyrylar.'
          : 'Запись для ${appointment.clientName} будет отменена.',
      confirmLabel: tk ? 'Ýatyr' : 'Отменить',
      cancelLabel: tk ? 'Ýok' : 'Нет',
    );
    if (confirmed && mounted) {
      context.read<BookingProvider>().cancel(appointment.id);
    }
  }

  void _openActions(Appointment appointment, Customer? customer, bool tk) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                    color: line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customer == null
                      ? const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xffE6D2B1),
                          child: AppIcon(
                            Icons.person_outline,
                            size: 18,
                            color: ink,
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
                        label: _scheduleCustomerLabel(customer.status, tk),
                        color: _statusColor(customer.status),
                        bg: _statusBg(customer.status),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _SheetAction(
                icon: Icons.calendar_month_outlined,
                title: tk ? 'Wagty üýtgetmek' : 'Изменить время',
                subtitle: tk
                    ? 'Bu ýazgyny başga wagtga geçirmek'
                    : 'Перенести эту запись',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _reschedule(appointment);
                },
              ),
              _SheetAction(
                icon: Icons.close,
                danger: true,
                title: tk ? 'Ýazgyny ýatyrmak' : 'Отменить запись',
                subtitle: tk ? 'Bu ýazgyny ýatyrmak' : 'Отменить эту запись',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmCancel(appointment);
                },
              ),
              if (customer != null)
                _SheetAction(
                  icon: Icons.person_outline,
                  title: tk
                      ? 'Müşderi profiline geçmek'
                      : 'Перейти в профиль клиента',
                  subtitle: tk
                      ? 'Müşderiniň maglumatlaryny görmek'
                      : 'Посмотреть данные клиента',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      _pageRoute(CustomerDetailScreen(customerId: customer.id)),
                    );
                  },
                ),
              _SheetAction(
                icon: Icons.phone_outlined,
                callAction: true,
                title: tk ? 'Jaň etmek' : 'Позвонить',
                subtitle: tk ? 'Müşdere jaň etmek' : 'Позвонить клиенту',
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
    final tk = context.watch<LanguageProvider>().isTurkmen;
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
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Senenama' : 'Расписание',
        action: _CustomerIconButton(
          icon: Icons.search,
          onTap: () => setState(() => _searching = !_searching),
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
                hint: tk
                    ? 'Müşderi ýa-da hyzmat gözle'
                    : 'Поиск клиента или услуги',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
            ],
            _WeekStrip(
              weekStart: _weekStart,
              selected: _selected,
              tk: tk,
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
                    color: cream,
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
                tk: tk,
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
                  '${_selected.day} ${(tk ? _monthsFullTk : _monthsFullRu)[_selected.month - 1]}, ${_selected.year} • ${(tk ? _weekdaysFullTk : _weekdaysFullRu)[_selected.weekday - 1]}',
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
              _EmptyState(
                icon: Icons.event_busy_outlined,
                title: tk ? 'Bu gün ýazgy ýok' : 'На этот день записей нет',
                text: tk ? 'Boş gün — dynç alyň!' : 'Свободный день.',
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
                    tk: tk,
                    onTap: () => _openActions(entry.appointment, customer, tk),
                  );
                }
                final free = entry as _FreeEntry;
                return _FreeSlotRow(
                  start: free.start,
                  end: free.end,
                  tk: tk,
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

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: line),
      ),
      child: AppIcon(icon, size: 15, color: ink),
    ),
  );
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekStart,
    required this.selected,
    required this.tk,
    required this.onSelect,
    required this.onPrevWeek,
    required this.onNextWeek,
  });
  final DateTime weekStart;
  final DateTime selected;
  final bool tk;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _NavArrow(icon: Icons.chevron_left, onTap: onPrevWeek),
      const SizedBox(width: 4),
      Expanded(
        child: Row(
          children: List.generate(7, (i) {
            final day = weekStart.add(Duration(days: i));
            final isSelected = _sameDay(day, selected);
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(day),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (tk ? _weekdaysTk : _weekdaysRu)[day.weekday - 1],
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white70 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : ink,
                        ),
                      ),
                      Text(
                        _monthsShortTk[day.month - 1],
                        style: TextStyle(
                          fontSize: 8.5,
                          color: isSelected ? Colors.white70 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(width: 4),
      _NavArrow(icon: Icons.chevron_right, onTap: onNextWeek),
    ],
  );
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.selected,
    required this.tk,
    required this.onSelect,
    required this.onPrevMonth,
    required this.onNextMonth,
  });
  final DateTime month;
  final DateTime selected;
  final bool tk;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;
    final startCell = first.subtract(Duration(days: leading));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavArrow(icon: Icons.chevron_left, onTap: onPrevMonth),
              Text(
                '${(tk ? _monthsFullTk : _monthsFullRu)[month.month - 1]} ${month.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _NavArrow(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: (tk ? _weekdaysTk : _weekdaysRu)
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 2,
            ),
            itemBuilder: (_, i) {
              final date = startCell.add(Duration(days: i));
              final inMonth = date.month == month.month;
              final isSelected = _sameDay(date, selected);
              return GestureDetector(
                onTap: () => onSelect(date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? ink : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (inMonth ? ink : Colors.black26),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Small status pill used inside the actions sheet (distinct name from
/// [_StatusBadge] to keep icon-less usage simple here).
class _StatusBadge2 extends StatelessWidget {
  const _StatusBadge2({
    required this.label,
    required this.color,
    required this.bg,
  });
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

const _timeColumnWidth = 46.0;

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({
    required this.appointment,
    required this.customer,
    required this.tk,
    required this.onTap,
  });
  final Appointment appointment;
  final Customer? customer;
  final bool tk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = customer == null ? Colors.white : _statusBg(customer!.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _timeColumnWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                _formatTime(TimeOfDay.fromDateTime(appointment.startsAt)),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customer == null
                            ? const CircleAvatar(
                                radius: 17,
                                backgroundColor: Color(0xffE6D2B1),
                                child: AppIcon(
                                  Icons.person_outline,
                                  size: 15,
                                  color: ink,
                                ),
                              )
                            : _CustomerAvatar(customer: customer!, radius: 17),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.clientName,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (customer != null)
                                Text(
                                  _handleFor(customer!),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.black45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (customer != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _StatusBadge2(
                              label: _scheduleCustomerLabel(
                                customer!.status,
                                tk,
                              ),
                              color: _statusColor(customer!.status),
                              bg: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appointment.serviceName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusBadge2(
                          label: _apptStatusLabel(appointment.status, tk),
                          color: _apptStatusColor(appointment.status),
                          bg: _apptStatusBg(appointment.status),
                        ),
                        if (appointment.status == AppointmentStatus.expected &&
                            customer != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri(
                                scheme: 'tel',
                                path: customer!.phone.replaceAll(' ', ''),
                              ),
                            ),
                            child: Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: line),
                              ),
                              child: const AppIcon(
                                Icons.phone_outlined,
                                size: 12,
                                color: ink,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _freeSlotColor = Color(0xff2FAE60);
const _freeSlotColorDark = Color(0xff1F8A4C);
const _freeSlotBg = Color(0xffEFFAF3);

class _FreeSlotRow extends StatelessWidget {
  const _FreeSlotRow({
    required this.start,
    required this.end,
    required this.tk,
    required this.onTap,
  });
  final DateTime start;
  final DateTime end;
  final bool tk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: _timeColumnWidth + 10, bottom: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _freeSlotBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _freeSlotColor.withValues(alpha: .6)),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _freeSlotColor.withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: const AppIcon(
                Icons.schedule_outlined,
                size: 13,
                color: _freeSlotColorDark,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_formatTime(TimeOfDay.fromDateTime(start))} - ${_formatTime(TimeOfDay.fromDateTime(end))}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _freeSlotColorDark,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '· ${tk ? "Boş wagt" : "Свободно"}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _freeSlotColorDark,
              ),
            ),
            const Spacer(),
            const AppIcon(Icons.add, size: 15, color: _freeSlotColorDark),
          ],
        ),
      ),
    ),
  );
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
    this.callAction = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  final bool callAction;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: danger ? const Color(0xffFDF0EE) : cream,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              icon,
              size: 17,
              color: danger ? const Color(0xffC0392B) : ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: danger ? const Color(0xffC0392B) : ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                ),
              ],
            ),
          ),
          if (callAction)
            const CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xff2FAE60),
              child: AppIcon(
                Icons.phone_outlined,
                size: 15,
                color: Colors.white,
              ),
            )
          else
            const AppIcon(Icons.chevron_right, size: 16, color: Colors.black26),
        ],
      ),
    ),
  );
}

/// Custom date + time sheet used everywhere the app needs to pick a moment
/// in time — deliberately replaces the plain OS date/time pickers with a
/// sheet that matches the rest of the app (reuses [_MonthCalendar]).
Future<DateTime?> _pickAppointmentDateTime(
  BuildContext context, {
  required bool tk,
  required DateTime initial,
}) {
  var month = DateTime(initial.year, initial.month);
  var selectedDate = DateTime(initial.year, initial.month, initial.day);
  var selectedTime = TimeOfDay.fromDateTime(initial);
  final quickTimes = List.generate(20, (i) {
    final total = 9 * 60 + i * 30;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  });

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tk ? 'Sene we wagt saýlaň' : 'Выберите дату и время',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _MonthCalendar(
                  month: month,
                  selected: selectedDate,
                  tk: tk,
                  onSelect: (d) => setSheetState(() => selectedDate = d),
                  onPrevMonth: () => setSheetState(
                    () => month = DateTime(month.year, month.month - 1),
                  ),
                  onNextMonth: () => setSheetState(
                    () => month = DateTime(month.year, month.month + 1),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  tk ? 'Wagt' : 'Время',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickTimes.map((t) {
                    final selected =
                        selectedTime.hour == t.hour &&
                        selectedTime.minute == t.minute;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedTime = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? ink : Colors.white,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: selected ? ink : line),
                        ),
                        child: Text(
                          _formatTime(t),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : ink,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _MasterActionButton(
                  label: tk ? 'Tassykla' : 'Подтвердить',
                  enabled: true,
                  leading: Icons.check,
                  onTap: () => Navigator.pop(
                    sheetContext,
                    DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ),
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

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: selected ? _freeSlotBg : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? _freeSlotColor : line,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _freeSlotColor.withValues(alpha: .15) : cream,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              icon,
              size: 16,
              color: selected ? _freeSlotColorDark : ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? _freeSlotColorDark : ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const AppIcon(Icons.chevron_right, size: 16, color: Colors.black26),
        ],
      ),
    ),
  );
}

/// Search-and-pick sheet for choosing an existing [Customer].
class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet({required this.customers, required this.tk});
  final List<Customer> customers;
  final bool tk;

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim().toLowerCase();
    final digits = query.replaceAll(RegExp(r'\s+'), '');
    final results = query.isEmpty
        ? widget.customers
        : widget.customers
              .where(
                (c) =>
                    c.name.toLowerCase().contains(query) ||
                    c.phone.replaceAll(' ', '').contains(digits),
              )
              .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.tk ? 'Müşderi saýlaň' : 'Выберите клиента',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _SearchField(
                controller: _controller,
                hint: widget.tk ? 'Müşderi gözlemek' : 'Поиск клиента',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          widget.tk
                              ? 'Müşderi tapylmady'
                              : 'Клиенты не найдены',
                          style: const TextStyle(color: Colors.black45),
                        ),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final c = results[i];
                          return InkWell(
                            onTap: () => Navigator.pop(context, c),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              child: Row(
                                children: [
                                  _CustomerAvatar(customer: c, radius: 19),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          c.phone,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _StatusBadge2(
                                    label: _statusLabel(c.status, widget.tk),
                                    color: _statusColor(c.status),
                                    bg: _statusBg(c.status),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NewSlotCustomerMode { existing, brandNew }

/// The "Täze ýazgy goşmak" sheet opened from a free-time row: pick or add a
/// customer, pick a service, add an optional note, and book it into the slot.
class _NewSlotAppointmentSheet extends StatefulWidget {
  const _NewSlotAppointmentSheet({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  static Future<void> show(
    BuildContext context, {
    required DateTime start,
    required DateTime end,
  }) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _NewSlotAppointmentSheet(start: start, end: end),
  );

  @override
  State<_NewSlotAppointmentSheet> createState() =>
      _NewSlotAppointmentSheetState();
}

class _NewSlotAppointmentSheetState extends State<_NewSlotAppointmentSheet> {
  _NewSlotCustomerMode? _mode;
  Customer? _selectedCustomer;
  final _newNameController = TextEditingController();
  final _newPhoneController = TextEditingController();
  SalonService? _selectedService;
  final _noteController = TextEditingController();
  bool _showErrors = false;

  @override
  void dispose() {
    _newNameController.dispose();
    _newPhoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _newCustomerOk =>
      _newNameController.text.trim().isNotEmpty &&
      _newPhoneController.text.trim().length >= 8;
  bool get _customerOk => switch (_mode) {
    _NewSlotCustomerMode.existing => _selectedCustomer != null,
    _NewSlotCustomerMode.brandNew => _newCustomerOk,
    null => false,
  };
  bool get _complete => _customerOk && _selectedService != null;

  Future<void> _pickExistingCustomer() async {
    final tk = context.read<LanguageProvider>().isTurkmen;
    final customers = context.read<CustomerProvider>().customers;
    final picked = await showModalBottomSheet<Customer>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CustomerPickerSheet(customers: customers, tk: tk),
    );
    if (picked != null) {
      setState(() {
        _selectedCustomer = picked;
        _mode = _NewSlotCustomerMode.existing;
      });
    }
  }

  Future<void> _pickService(List<SalonService> services) async {
    final tk = context.read<LanguageProvider>().isTurkmen;
    final picked = await showModalBottomSheet<SalonService>(
      context: context,
      backgroundColor: Colors.white,
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
                    color: line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tk ? 'Hyzmat saýlaň' : 'Выберите услугу',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (services.isEmpty)
                _EmptyState(
                  icon: Icons.content_cut,
                  title: tk ? 'Hyzmat ýok' : 'Услуг нет',
                  text: tk
                      ? 'Ilki bilen hyzmat goşuň.'
                      : 'Сначала добавьте услугу.',
                )
              else
                ...services.map(
                  (s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${s.price} ${tk ? "manat" : "манат"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    trailing: _selectedService?.id == s.id
                        ? const AppIcon(Icons.check, color: gold)
                        : null,
                    onTap: () => Navigator.pop(sheetContext, s),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _selectedService = picked);
  }

  void _save() {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    final customerProvider = context.read<CustomerProvider>();
    final Customer customer;
    if (_mode == _NewSlotCustomerMode.existing) {
      customer = _selectedCustomer!;
    } else {
      customer = Customer(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _newNameController.text.trim(),
        phone: _newPhoneController.text.trim(),
        status: CustomerStatus.newClient,
      );
      customerProvider.add(customer);
    }
    context.read<BookingProvider>().create(
      service: _selectedService!.name,
      startsAt: widget.start,
      price: _selectedService!.price.toDouble(),
      clientName: customer.name,
      customerId: customer.id,
    );
    customerProvider.update(customer.copyWith(nextVisit: widget.start));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final services = context.watch<ServiceProvider>().services;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tk ? 'Täze ýazgy goşmak' : 'Добавить новую запись',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const AppIcon(
                      Icons.close,
                      size: 20,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _freeSlotBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _freeSlotColor),
                ),
                child: Row(
                  children: [
                    const AppIcon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: _freeSlotColorDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatTime(TimeOfDay.fromDateTime(widget.start))} - ${_formatTime(TimeOfDay.fromDateTime(widget.end))} • ${_formatDate(widget.start)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _freeSlotColorDark,
                            ),
                          ),
                          Text(
                            tk ? 'Boş wagt' : 'Свободно',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _freeSlotColorDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                tk ? '1. Müşderi saýlaň' : '1. Выберите клиента',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _ChoiceCard(
                icon: Icons.people_outline,
                title: tk ? 'Müşderilerden saýlaň' : 'Выбрать из клиентов',
                subtitle:
                    _mode == _NewSlotCustomerMode.existing &&
                        _selectedCustomer != null
                    ? _selectedCustomer!.name
                    : (tk
                          ? 'Bar bolan müşderini saýlaň'
                          : 'Выберите существующего клиента'),
                selected: _mode == _NewSlotCustomerMode.existing,
                onTap: _pickExistingCustomer,
              ),
              const SizedBox(height: 8),
              _ChoiceCard(
                icon: Icons.person_add_alt_1,
                title: tk ? 'Täze müşderi goşuň' : 'Добавить нового клиента',
                subtitle: tk
                    ? 'Täze müşderini el bilen goşuň'
                    : 'Добавьте нового клиента вручную',
                selected: _mode == _NewSlotCustomerMode.brandNew,
                onTap: () =>
                    setState(() => _mode = _NewSlotCustomerMode.brandNew),
              ),
              if (_mode == _NewSlotCustomerMode.brandNew) ...[
                const SizedBox(height: 12),
                _FormField(
                  controller: _newNameController,
                  hint: tk ? 'Ady we familiýasy' : 'Имя и фамилия',
                  invalid:
                      _showErrors && _newNameController.text.trim().isEmpty,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 10),
                _FormField(
                  controller: _newPhoneController,
                  hint: '+993 65 123456',
                  keyboardType: TextInputType.phone,
                  invalid:
                      _showErrors && _newPhoneController.text.trim().length < 8,
                  onChanged: () => setState(() {}),
                ),
              ],
              if (_showErrors && !_customerOk) _ErrorText(tk: tk),
              const SizedBox(height: 22),
              Text(
                tk ? '2. Hyzmat saýlaň' : '2. Выберите услугу',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickService(services),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _showErrors && _selectedService == null
                          ? const Color(0xffC0392B)
                          : line,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedService?.name ??
                              (tk ? 'Hyzmat saýlaň' : 'Выберите услугу'),
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedService == null
                                ? Colors.black38
                                : ink,
                            fontWeight: _selectedService == null
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      const AppIcon(
                        Icons.expand_more,
                        size: 18,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showErrors && _selectedService == null) _ErrorText(tk: tk),
              const SizedBox(height: 22),
              Text(
                tk ? '3. Bellik (islege görä)' : '3. Заметка (необязательно)',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _FormField(
                controller: _noteController,
                hint: tk ? 'Bellik goşuň...' : 'Добавьте заметку...',
                maxLines: 3,
                maxLength: 200,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 12),
              _MasterActionButton(
                label: tk ? 'Ýazgyny sakla' : 'Сохранить запись',
                enabled: _complete,
                leading: Icons.save_outlined,
                onTap: _save,
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    tk ? 'Ýatyr' : 'Отмена',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
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
