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

