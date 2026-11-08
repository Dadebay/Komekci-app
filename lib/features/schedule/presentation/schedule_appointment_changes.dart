part of '../../../app/komekci_app.dart';

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
  await runApi(
    context,
    () => bookingProvider.reschedule(appointment.id, picked),
  );
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
    await runApi(
      context,
      () => context.read<BookingProvider>().cancel(appointment.id),
    );
  }
}

/// Opens the bottom-sheet of actions (mark arrived, reschedule, cancel,
/// go to profile, call) for an appointment. Shared between the schedule
/// screen's timeline and the home dashboard's today table so tapping a
/// customer row always surfaces the same actions instead of navigating away.
