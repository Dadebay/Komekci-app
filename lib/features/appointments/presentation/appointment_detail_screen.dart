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
    final timeLabel = '${current.startsAt.hour.toString().padLeft(2, '0')}:${current.startsAt.minute.toString().padLeft(2, '0')}';
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(title: current.serviceName),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const HeroPhoto(),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withValues(alpha: .05)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xffE6D2B1),
                        child: AppIcon(Icons.person_outline, size: 19, color: tokens.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(current.masterName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(
                              '${current.minutes} ${t(tk: "min", ru: "мин", en: "min")} · ${current.price.toStringAsFixed(0)} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                              style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      _ClientBookingStatusChip(status: current.status, tk: tk),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: tokens.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AppIcon(Icons.calendar_today_outlined, size: 13, color: tokens.textSecondary),
                      const SizedBox(width: 5),
                      Text(formatDate(current.startsAt), style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                      const SizedBox(width: 14),
                      AppIcon(Icons.schedule_outlined, size: 13, color: tokens.textSecondary),
                      const SizedBox(width: 5),
                      Text(timeLabel, style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                    ],
                  ),
                  if (current.lateMinutes != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        AppIcon(Icons.timer_outlined, size: 14, color: tokens.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t(
                              tk: '${current.lateMinutes} min gijä galýaryn diýip habar berdiňiz',
                              ru: 'Вы сообщили, что опоздаете на ${current.lateMinutes} мин',
                              en: 'You signalled you’ll be ${current.lateMinutes} min late',
                            ),
                            style: TextStyle(fontSize: 12, color: tokens.warning),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (current.note.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      t(tk: 'Bellik', ru: 'Заметка', en: 'Note'),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(current.note, style: TextStyle(color: tokens.textSecondary, height: 1.4)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, canPop ? 16 : 24),
          child: isUpcoming
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: tokens.border),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => _showLateSheet(context, current, t),
                      child: Text(t(tk: 'Gijä galýaryn', ru: 'Я опаздываю', en: 'I’m running late')),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: tokens.border),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.push(context, pageRoute(RescheduleScreen(booking: current))),
                      child: Text(t(tk: 'Randevuny üýtget', ru: 'Изменить запись', en: 'Change appointment')),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => _confirmCancel(context, current, t),
                      child: Text(
                        t(tk: 'Randevuny ýatyr', ru: 'Отменить запись', en: 'Cancel appointment'),
                        style: TextStyle(color: tokens.danger),
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
