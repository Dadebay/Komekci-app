part of '../../../app/komekci_app.dart';

/// Client's own booking, with mutation rules: change/cancel only apply
/// before the appointment starts; a completed/cancelled booking renders as a
/// read-only history record instead. "Running late" has no elapsed-time
/// simulation to gate against in this mock (there's no ticking in-app
/// clock), so it's offered for any upcoming booking rather than a strict
/// start±window check a real backend would enforce.
class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key, required this.booking});
  final ClientBooking booking;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;

    final provider = context.watch<ClientBookingsProvider>();
    ClientBooking current = booking;
    for (final b in provider.bookings) {
      if (b.id == booking.id) current = b;
    }
    final isUpcoming = current.status == ClientBookingStatus.expected;
    final currency = context.watch<AppSettingsProvider>().currencyLabel(
      language,
    );

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tokens.border.withValues(alpha: .8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.textPrimary.withValues(alpha: .06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: AppIcon(
                        Icons.arrow_back,
                        size: 19,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.appointmentsBooking.select(language),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  // When and how it stands: status, countdown, date and time.
                  _AppointmentTimeCard(current: current, language: language),
                  if (current.lateMinutes != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.warning.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: tokens.warning.withValues(alpha: .3),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppIcon(
                            Icons.timer_outlined,
                            size: 18,
                            color: tokens.warning,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.appointmentsYouSignalledYouLlBe(
                                current.lateMinutes,
                              ).select(language),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: tokens.warning,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _bookingCardDecoration(tokens),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appointmentsMaster.select(language),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: tokens.accent,
                                  width: 1.6,
                                ),
                              ),
                              child: MasterAvatar(
                                url: current.masterPhotoUrl,
                                radius: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                current.masterName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: tokens.border),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.bookingService.select(language),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: tokens.accent.withValues(alpha: .13),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: AppIcon(
                                Icons.content_cut,
                                size: 20,
                                color: tokens.accent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    current.serviceName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      AppIcon(
                                        Icons.hourglass_empty,
                                        size: 12,
                                        color: tokens.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${current.minutes} ${AppStrings.bookingMin.select(language)}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: tokens.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${current.price.toStringAsFixed(0)} $currency',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: tokens.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (current.note.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: _bookingCardDecoration(tokens),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppIcon(
                                Icons.sticky_note_2_outlined,
                                size: 16,
                                color: tokens.accent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.bookingNote.select(language),
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            current.note,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: tokens.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (current.waitlistEarlier && isUpcoming) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        AppIcon(
                          Icons.notifications_none,
                          size: 15,
                          color: tokens.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            AppStrings.appointmentsWeLlTellYouIf.select(
                              language,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isUpcoming) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final toast = AppToast.of(context);
                        final result = await provider.saveToCalendar(current);
                        switch (result) {
                          case CalendarSaveResult.saved:
                            toast.success(
                              AppStrings.appointmentsAddedToCalendarWithA
                                  .select(language),
                            );
                          case CalendarSaveResult.permissionDenied:
                            toast.error(
                              AppStrings.appointmentsAllowCalendarAccessInPhone
                                  .select(language),
                            );
                          case CalendarSaveResult.unavailable:
                          case CalendarSaveResult.failed:
                            toast.error(
                              AppStrings.appointmentsCouldNotAddToCalendar
                                  .select(language),
                            );
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        AppStrings.appointmentsAddToPhoneCalendar.select(
                          language,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: tokens.textPrimary.withValues(alpha: .08),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: isUpcoming
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                side: BorderSide(color: tokens.border),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () =>
                                  _showLateSheet(context, current, t),
                              icon: AppIcon(
                                Icons.timer_outlined,
                                size: 17,
                                color: tokens.textPrimary,
                              ),
                              label: Text(
                                AppStrings.appointmentsRunningLate.select(
                                  language,
                                ),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: tokens.textPrimary,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                pageRoute(RescheduleScreen(booking: current)),
                              ),
                              icon: AppIcon(
                                Icons.edit_outlined,
                                size: 17,
                                color: tokens.surface,
                              ),
                              label: Text(
                                AppStrings.profileChange.select(language),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.surface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => _confirmCancel(context, current, t),
                        child: Text(
                          AppStrings.appointmentsCancelAppointment.select(
                            language,
                          ),
                          style: TextStyle(
                            color: tokens.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                : PrimaryButton(
                    label: AppStrings.appointmentsBookAgain.select(language),
                    onTap: () => _rebook(context, current, t),
                  ),
          ),
        ),
      ),
    );
  }
}
