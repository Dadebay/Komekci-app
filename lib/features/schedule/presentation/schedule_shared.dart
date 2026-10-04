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
const _weekdaysFullEn = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
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
const _monthsShortRu = [
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
const _monthsShortEn = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
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
const _monthsFullEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Picks the value for [language] from parallel tk/ru/en arrays or constants
/// (e.g. `_byLang(language, _weekdaysTk, _weekdaysRu, weekdaysEn)`).
T _byLang<T>(AppLanguage language, T tk, T ru, T en) => switch (language) {
  AppLanguage.tk => tk,
  AppLanguage.ru => ru,
  AppLanguage.en => en,
};

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

String _scheduleCustomerLabel(CustomerStatus status, AppLanguage language) =>
    switch (status) {
      CustomerStatus.vip => 'VIP',
      CustomerStatus.regular => pickTr(
        language,
        tk: 'Hemişelik',
        ru: 'Постоянный',
        en: 'Regular',
      ),
      CustomerStatus.newClient => pickTr(
        language,
        tk: 'Täze müşderi',
        ru: 'Новый клиент',
        en: 'New client',
      ),
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

String _apptStatusLabel(AppointmentStatus status, AppLanguage language) =>
    switch (status) {
      AppointmentStatus.expected => pickTr(
        language,
        tk: 'Garaşylýar',
        ru: 'Ожидание',
        en: 'Upcoming',
      ),
      AppointmentStatus.arrived => pickTr(
        language,
        tk: 'Geldi',
        ru: 'Пришёл',
        en: 'Arrived',
      ),
      AppointmentStatus.completed => pickTr(
        language,
        tk: 'Tamamlandy',
        ru: 'Завершено',
        en: 'Completed',
      ),
      AppointmentStatus.cancelled => pickTr(
        language,
        tk: 'Ýatyryldy',
        ru: 'Отменено',
        en: 'Cancelled',
      ),
      AppointmentStatus.noShow => pickTr(
        language,
        tk: 'Gelmedi',
        ru: 'Не пришёл',
        en: 'No-show',
      ),
    };

Future<void> _rescheduleAppointment(
  BuildContext context,
  Appointment appointment,
) async {
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
  if (picked == null || !context.mounted) return;
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
  await runApi(context, () => bookingProvider.reschedule(appointment.id, picked));
}

Future<void> _confirmCancelAppointment(
  BuildContext context,
  Appointment appointment,
) async {
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
  if (confirmed && context.mounted) {
    await runApi(context, () => context.read<BookingProvider>().cancel(appointment.id));
  }
}

/// Opens the bottom-sheet of actions (mark arrived, reschedule, cancel,
/// go to profile, call) for an appointment. Shared between the schedule
/// screen's timeline and the home dashboard's today table so tapping a
/// customer row always surfaces the same actions instead of navigating away.
void _openAppointmentActions(
  BuildContext context,
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
                      label: _scheduleCustomerLabel(customer.status, language),
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
                  runApi(context, () => context.read<BookingProvider>().markNoShow(appointment.id));
                },
              ),
            ],
            if (appointment.status == AppointmentStatus.arrived ||
                appointment.status == AppointmentStatus.expected)
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
                  runApi(context, () => context.read<BookingProvider>().complete(appointment.id));
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
                  _rescheduleAppointment(context, appointment);
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
                  _confirmCancelAppointment(context, appointment);
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
/// free-time blocks across the 09:00–19:00 working window, broken into
/// 1-hour chunks (a trailing shorter chunk for whatever's left over) rather
/// than one long block, so each hour can be booked on its own.
List<_TimelineEntry> _buildTimeline(
  List<Appointment> appointments,
  DateTime day,
) {
  final workStart = DateTime(day.year, day.month, day.day, 9);
  final workEnd = DateTime(day.year, day.month, day.day, 19);
  final entries = <_TimelineEntry>[];

  void addFreeChunks(DateTime start, DateTime end) {
    var chunkStart = start;
    while (chunkStart.isBefore(end)) {
      final chunkEnd = chunkStart.add(const Duration(hours: 1));
      entries.add(
        _FreeEntry(chunkStart, chunkEnd.isBefore(end) ? chunkEnd : end),
      );
      chunkStart = chunkEnd;
    }
  }

  var cursor = workStart;
  for (final appt in appointments) {
    if (appt.startsAt.isAfter(cursor)) {
      addFreeChunks(cursor, appt.startsAt);
    }
    entries.add(_ApptEntry(appt));
    final apptEnd = appt.startsAt.add(const Duration(minutes: 30));
    if (apptEnd.isAfter(cursor)) cursor = apptEnd;
  }
  if (workEnd.isAfter(cursor)) addFreeChunks(cursor, workEnd);
  return entries;
}
