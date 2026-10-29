part of '../../../app/komekci_app.dart';

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

Color _apptStatusBg(AppointmentStatus status, AppThemeTokens tokens) {
  if (tokens.brightness == Brightness.dark) {
    return Color.alphaBlend(
      _apptStatusColor(status, tokens).withValues(alpha: .16),
      tokens.surfaceElevated,
    );
  }
  return switch (status) {
    AppointmentStatus.expected => const Color(0xffFCEDD9),
    AppointmentStatus.arrived => const Color(0xffDCF3E3),
    AppointmentStatus.completed => const Color(0xffEDEDEA),
    AppointmentStatus.cancelled ||
    AppointmentStatus.noShow => const Color(0xffFBE3E0),
  };
}

Color _apptStatusColor(AppointmentStatus status, AppThemeTokens tokens) {
  if (tokens.brightness == Brightness.dark) {
    return switch (status) {
      AppointmentStatus.expected => tokens.warning,
      AppointmentStatus.arrived => tokens.success,
      AppointmentStatus.completed => tokens.textSecondary,
      AppointmentStatus.cancelled || AppointmentStatus.noShow => tokens.danger,
    };
  }
  return switch (status) {
    AppointmentStatus.expected => const Color(0xffB8720C),
    AppointmentStatus.arrived => const Color(0xff1F8A4C),
    AppointmentStatus.completed => Colors.black54,
    AppointmentStatus.cancelled ||
    AppointmentStatus.noShow => const Color(0xffC0392B),
  };
}

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

String _appointmentPhone(Appointment appointment, Customer? customer) {
  final customerPhone = customer?.phone.trim() ?? '';
  return customerPhone.isNotEmpty
      ? customerPhone
      : appointment.clientPhone?.trim() ?? '';
}

