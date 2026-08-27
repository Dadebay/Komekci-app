part of '../../../app/komekci_app.dart';

/// The avatar-tint palette a master's initial is picked from, so repeat
/// masters read as the same color across cards without a real photo.
const _avatarPalette = [
  Color(0xffE6D2B1),
  Color(0xffCFE3D6),
  Color(0xffDCD3EE),
  Color(0xffF3D6D0),
  Color(0xffCFE1F0),
];

Color _avatarColorFor(String name) =>
    _avatarPalette[name.hashCode.abs() % _avatarPalette.length];

/// One appointment row — shared between the bordered per-item card used on
/// the full "Ýazgylarym" tab and the divided list used in the home preview.
class _ClientBookingRow extends StatelessWidget {
  const _ClientBookingRow({required this.booking, required this.tk});
  final ClientBooking booking;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final statusColor = switch (booking.status) {
      ClientBookingStatus.expected => freeSlotColorDark,
      ClientBookingStatus.completed => const Color(0xff2A5DB0),
      ClientBookingStatus.cancelled => Colors.deepOrange,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(context, pageRoute(AppointmentDetailScreen(booking: booking))),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 13, 14, 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: _avatarColorFor(booking.masterName),
                      child: Text(
                        booking.masterName.isEmpty ? '?' : booking.masterName[0].toUpperCase(),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking.masterName,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _ClientBookingStatusChip(status: booking.status, tk: tk),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(booking.serviceName, style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              AppIcon(Icons.calendar_today_outlined, size: 12, color: tokens.textSecondary),
                              const SizedBox(width: 4),
                              Text(formatDate(booking.startsAt), style: TextStyle(fontSize: 11, color: tokens.textSecondary)),
                              const SizedBox(width: 10),
                              AppIcon(Icons.schedule_outlined, size: 12, color: tokens.textSecondary),
                              const SizedBox(width: 4),
                              Text('${booking.startsAt.hour.toString().padLeft(2, '0')}:${booking.startsAt.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: tokens.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(height: 1, color: tokens.border),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              AppIcon(Icons.hourglass_empty, size: 12, color: tokens.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                tk ? '${booking.minutes} min' : '${booking.minutes} мин',
                                style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
                              ),
                              const Spacer(),
                              Text(
                                '${booking.price.toStringAsFixed(0)} ${tk ? 'manat' : 'манат'}',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                              ),
                              const SizedBox(width: 4),
                              AppIcon(Icons.chevron_right, size: 15, color: tokens.disabled),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientBookingStatusChip extends StatelessWidget {
  const _ClientBookingStatusChip({required this.status, required this.tk});
  final ClientBookingStatus status;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final (bg, fg, label) = switch (status) {
      ClientBookingStatus.expected => (freeSlotBg, freeSlotColorDark, t(tk: 'Tassyklanan', ru: 'Подтверждено', en: 'Confirmed')),
      ClientBookingStatus.completed => (const Color(0xffE6EEFB), const Color(0xff2A5DB0), t(tk: 'Tamamlandy', ru: 'Завершено', en: 'Completed')),
      ClientBookingStatus.cancelled => (const Color(0xffFBE3E0), Colors.deepOrange, t(tk: 'Ýatyryldy', ru: 'Отменено', en: 'Cancelled')),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// Individual elevated card — used for each row on the full "Ýazgylarym" tab.
class _ClientBookingCard extends StatelessWidget {
  const _ClientBookingCard({required this.booking, required this.tk});
  final ClientBooking booking;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: _ClientBookingRow(booking: booking, tk: tk),
    );
  }
}

/// One rounded card holding every booking row separated by thin dividers —
/// used for the "Meniň ýazgylarym" preview on the home dashboard.
class _ClientBookingsListCard extends StatelessWidget {
  const _ClientBookingsListCard({required this.bookings, required this.tk});
  final List<ClientBooking> bookings;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < bookings.length; i++) ...[
            _ClientBookingRow(booking: bookings[i], tk: tk),
            if (i != bookings.length - 1) Divider(height: 1, thickness: 1, color: tokens.border, indent: 14, endIndent: 14),
          ],
        ],
      ),
    );
  }
}
