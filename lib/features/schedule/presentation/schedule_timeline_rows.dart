part of '../../../app/komekci_app.dart';

Iterable<Widget> _scheduleTimelineRows({
  required BuildContext context,
  required List<_TimelineEntry> entries,
  required CustomerProvider customerProvider,
  required AppLanguage language,
  required VoidCallback onExpired,
}) {
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
  return entries.map((entry) {
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
                  language: language,
                  onTap: () => _openAppointmentActions(
                    context,
                    entry.appointment,
                    customer,
                    language,
                  ),
                );
              }
              if (entry is _ClosedEntry) {
                return _ClosedTimeRow(
                  closed: entry.closed,
                  language: language,
                  onTap: () => _reopenClosedTime(context, entry.closed),
                );
              }
              final free = entry as _FreeEntry;
              return _FreeSlotRow(
                start: free.start,
                end: free.end,
                language: language,
                onTap: () {
                  if (!free.start.isAfter(DateTime.now())) {
                    onExpired();
                    AppToast.of(context).error(
                      t(
                        tk: 'Bu wagt indi elýeterli däl. Başga wagt saýlaň.',
                        ru: 'Это время уже недоступно. Выберите другое.',
                        en: 'This time is no longer available. Choose another.',
                      ),
                    );
                    return;
                  }
                  _showFreeTimeActions(
                    context,
                    start: free.start,
                    end: free.end,
                    availableEnd: free.availableEnd,
                  );
                },
              );
            });
}
