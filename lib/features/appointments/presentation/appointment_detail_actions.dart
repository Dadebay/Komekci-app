part of '../../../app/komekci_app.dart';

extension _AppointmentDetailActions on AppointmentDetailScreen {
  Future<void> _confirmCancel(BuildContext context, ClientBooking current, String Function({required String tk, required String ru, required String en}) t) async {
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.event_busy_outlined,
      danger: true,
      title: t(tk: 'Ýazgyny ýatyrmaly?', ru: 'Отменить запись?', en: 'Cancel this booking?'),
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
