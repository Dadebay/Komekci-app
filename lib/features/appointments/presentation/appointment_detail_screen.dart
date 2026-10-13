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
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tk = language == AppLanguage.tk;
    final tokens = context.appTokens;

    final provider = context.watch<ClientBookingsProvider>();
    ClientBooking current = booking;
    for (final b in provider.bookings) {
      if (b.id == booking.id) current = b;
    }
    final isUpcoming = current.status == ClientBookingStatus.expected;
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    final statusColor = _bookingStatusColor(tokens, current.status);
    final countdown = _bookingCountdown(current, language);
    String clock(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

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
                        border: Border.all(color: tokens.border.withValues(alpha: .8)),
                        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .06), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: AppIcon(Icons.arrow_back, size: 19, color: tokens.textPrimary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t(tk: 'Ýazgy', ru: 'Запись', en: 'Booking'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _flatTintDecoration(tokens, statusColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ClientBookingStatusChip(status: current.status, tk: tk),
                            const Spacer(),
                            if (countdown != null)
                              Row(
                                children: [
                                  AppIcon(Icons.timer_outlined, size: 15, color: tokens.textPrimary),
                                  const SizedBox(width: 4),
                                  Text(countdown, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(formatDate(current.startsAt), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            AppIcon(Icons.schedule_outlined, size: 18, color: statusColor),
                            const SizedBox(width: 7),
                            Text(
                              '${clock(current.startsAt)} – ${clock(current.endsAt)}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: statusColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (current.lateMinutes != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.warning.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: tokens.warning.withValues(alpha: .3)),
                      ),
                      child: Row(
                        children: [
                          AppIcon(Icons.timer_outlined, size: 18, color: tokens.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t(
                                tk: '${current.lateMinutes} min gijä galýaryn diýip habar berdiňiz',
                                ru: 'Вы сообщили, что опоздаете на ${current.lateMinutes} мин',
                                en: 'You signalled you’ll be ${current.lateMinutes} min late',
                              ),
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.warning, height: 1.35),
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
                        Text(t(tk: 'Master', ru: 'Мастер', en: 'Master'), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.textSecondary)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: tokens.accent, width: 1.6)),
                              child: MasterAvatar(url: current.masterPhotoUrl, radius: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(current.masterName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: tokens.border),
                        const SizedBox(height: 16),
                        Text(t(tk: 'Hyzmat', ru: 'Услуга', en: 'Service'), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.textSecondary)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .13), borderRadius: BorderRadius.circular(15)),
                              child: AppIcon(Icons.content_cut, size: 20, color: tokens.accent),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(current.serviceName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      AppIcon(Icons.hourglass_empty, size: 12, color: tokens.textSecondary),
                                      const SizedBox(width: 4),
                                      Text('${current.minutes} ${t(tk: "min", ru: "мин", en: "min")}', style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text('${current.price.toStringAsFixed(0)} $currency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tokens.accent)),
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
                              AppIcon(Icons.sticky_note_2_outlined, size: 16, color: tokens.accent),
                              const SizedBox(width: 6),
                              Text(t(tk: 'Bellik', ru: 'Заметка', en: 'Note'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(current.note, style: TextStyle(fontSize: 13.5, color: tokens.textSecondary, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                  if (current.waitlistEarlier && isUpcoming) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        AppIcon(Icons.notifications_none, size: 15, color: tokens.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t(
                              tk: 'Has erki wagt açylsa size habar berler',
                              ru: 'Сообщим, если освободится более раннее время',
                              en: 'We’ll tell you if an earlier slot opens up',
                            ),
                            style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                          ),
                        ),
                      ],
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
          boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .08), blurRadius: 22, offset: const Offset(0, -6))],
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
                              onPressed: () => _showLateSheet(context, current, t),
                              icon: AppIcon(Icons.timer_outlined, size: 17, color: tokens.textPrimary),
                              label: Text(t(tk: 'Gijä galýaryn', ru: 'Опаздываю', en: 'Running late'), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.textPrimary)),
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
                              onPressed: () => Navigator.push(context, pageRoute(RescheduleScreen(booking: current))),
                              icon: AppIcon(Icons.edit_outlined, size: 17, color: tokens.surface),
                              label: Text(t(tk: 'Üýtget', ru: 'Изменить', en: 'Change'), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.surface)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => _confirmCancel(context, current, t),
                        child: Text(
                          t(tk: 'Randevuny ýatyr', ru: 'Отменить запись', en: 'Cancel appointment'),
                          style: TextStyle(color: tokens.danger, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  )
                : PrimaryButton(
                    label: t(tk: 'Täzeden ýazyl', ru: 'Записаться снова', en: 'Book again'),
                    onTap: () => _rebook(context, current, t),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, ClientBooking current, String Function({required String tk, required String ru, required String en}) t) async {
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.event_busy_outlined,
      danger: true,
      title: t(tk: 'Randevuny ýatyrmaly?', ru: 'Отменить запись?', en: 'Cancel this booking?'),
      message: t(tk: 'Bu hereketi yzyna gaýtaryp bolmaz.', ru: 'Это действие нельзя отменить.', en: 'This action cannot be undone.'),
      confirmLabel: t(tk: 'Ýatyr', ru: 'Отменить', en: 'Cancel'),
      cancelLabel: t(tk: 'Ýapmak', ru: 'Закрыть', en: 'Close'),
    );
    if (confirmed && context.mounted) {
      final navigator = Navigator.of(context);
      final ok = await runApi(context, () => context.read<ClientBookingsProvider>().cancel(current.id));
      if (ok) navigator.maybePop();
    }
  }

  /// "Book again": the server looks for the same time in the coming days
  /// (`POST /appointments/{id}/rebook`). If that is taken it answers
  /// `SLOT_TAKEN` with alternatives, offered here to pick from.
  Future<void> _rebook(BuildContext context, ClientBooking current, String Function({required String tk, required String ru, required String en}) t) async {
    final bookings = context.read<ClientBookingsProvider>();
    final language = context.read<LanguageProvider>().language;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    Future<ClientBooking?> attempt(DateTime? startsAt) async {
      try {
        return await bookings.rebook(current.id, startsAt: startsAt);
      } on ApiException catch (e) {
        if (e.code == ApiErrors.slotTaken && context.mounted) {
          final slots = [for (final s in e.suggestedSlots) ?parseApiTime(s)];
          if (slots.isNotEmpty) {
            final picked = await showModalBottomSheet<DateTime>(
              context: context,
              builder: (sheetContext) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t(tk: 'Şol wagt eýýäm alnan. Ýakyn boş wagtlar:', ru: 'Это время занято. Ближайшее свободное:', en: 'That time is taken. Nearest free times:'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final slot in slots)
                            ActionChip(
                              label: Text('${formatDate(slot)} · ${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}'),
                              onPressed: () => Navigator.pop(sheetContext, slot),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (picked != null) return attempt(picked);
            return null;
          }
        }
        messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e, language))));
        return null;
      } catch (error) {
        messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(error, language))));
        return null;
      }
    }

    final booking = await attempt(null);
    if (booking == null || !context.mounted) return;
    navigator.push(pageRoute(BookingSuccessScreen(appointment: booking, masterName: booking.masterName)));
  }

  void _showLateSheet(BuildContext context, ClientBooking current, String Function({required String tk, required String ru, required String en}) t) {
    final tokens = context.appTokens;
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(tk: 'Näçe minut gijä galýarsyňyz?', ru: 'На сколько минут вы опаздываете?', en: 'How many minutes late?'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [5, 10].map((minutes) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: tokens.border),
                        ),
                        onPressed: () {
                          runApi(context, () => context.read<ClientBookingsProvider>().setLate(current.id, minutes));
                          Navigator.pop(sheetContext);
                        },
                        child: Text('$minutes ${t(tk: "min", ru: "мин", en: "min")}'),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
