part of '../../../app/komekci_app.dart';

Future<void> _rescheduleAppointment(
  BuildContext context,
  Appointment appointment,
) async {
  final language = context.read<LanguageProvider>().language;
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
          AppStrings.scheduleThisTimeIsAlreadyTaken.select(language),
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
  final confirmed = await _showConfirmDialog(
    context,
    icon: Icons.event_busy_outlined,
    danger: true,
    title: AppStrings.appointmentsCancelThisBooking.select(language),
    message: AppStrings.scheduleTheBookingForWillBe(
      appointment.clientName,
    ).select(language),
    confirmLabel: AppStrings.appointmentsCancel.select(language),
    cancelLabel: AppStrings.scheduleNo.select(language),
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
