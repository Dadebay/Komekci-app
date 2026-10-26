part of '../../../app/komekci_app.dart';

/// Colour that marks a booking's state across its date tile and chip.
Color _bookingStatusColor(AppThemeTokens tokens, ClientBookingStatus status) => switch (status) {
  ClientBookingStatus.expected => tokens.success,
  ClientBookingStatus.completed => const Color(0xff2A5DB0),
  ClientBookingStatus.cancelled || ClientBookingStatus.noShow => tokens.danger,
};

/// "In 2 h 15 min" / "Tomorrow" / "In 3 days" for a booking that has not
/// happened yet; null once it is over or was cancelled.
String? _bookingCountdown(ClientBooking booking, AppLanguage language) {
  if (booking.status != ClientBookingStatus.expected) return null;
  String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
  final now = DateTime.now();
  final diff = booking.startsAt.difference(now);
  if (diff.isNegative) {
    return booking.endsAt.isAfter(now) ? t(tk: 'Häzir dowam edýär', ru: 'Идёт сейчас', en: 'In progress') : null;
  }
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(booking.startsAt.year, booking.startsAt.month, booking.startsAt.day);
  final days = day.difference(today).inDays;
  if (days == 0) {
    if (diff.inMinutes < 60) return t(tk: '${diff.inMinutes} min soň', ru: 'через ${diff.inMinutes} мин', en: 'in ${diff.inMinutes} min');
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return t(
      tk: '$h sag${m == 0 ? '' : ' $m min'} soň',
      ru: 'через $h ч${m == 0 ? '' : ' $m мин'}',
      en: 'in $h h${m == 0 ? '' : ' $m min'}',
    );
  }
  if (days == 1) return t(tk: 'Ertir', ru: 'Завтра', en: 'Tomorrow');
  return t(tk: '$days gün soň', ru: 'через $days дн.', en: 'in $days days');
}

/// One appointment, laid out like a ticket: a date tile tinted with the
/// booking's state, who and what, then time, length and price underneath.
class _ClientBookingRow extends StatelessWidget {
  const _ClientBookingRow({required this.booking, required this.tk});
  final ClientBooking booking;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    final statusColor = _bookingStatusColor(tokens, booking.status);
    final months = switch (language) {
      AppLanguage.tk => _monthsFullTk,
      AppLanguage.ru => _monthsFullRu,
      AppLanguage.en => _monthsEn,
    };
    final month = months[booking.startsAt.month - 1];
    final end = booking.startsAt.add(Duration(minutes: booking.minutes));
    String clock(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final minLabel = pickTr(language, tk: 'min', ru: 'мин', en: 'min');

    return InkWell(
      onTap: () => Navigator.push(context, pageRoute(AppointmentDetailScreen(booking: booking))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text(
                        month.substring(0, month.length < 3 ? month.length : 3).toUpperCase(),
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: .6, color: statusColor),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${booking.startsAt.day}',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.1, color: tokens.textPrimary),
                      ),
                    ],
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
                              booking.serviceName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ClientBookingStatusChip(status: booking.status, tk: tk),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          MasterAvatar(url: booking.masterPhotoUrl, radius: 10),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              booking.masterName,
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  AppIcon(Icons.schedule_outlined, size: 14, color: tokens.accent),
                  const SizedBox(width: 6),
                  Text('${clock(booking.startsAt)} – ${clock(end)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text('· ${booking.minutes} $minLabel', style: TextStyle(fontSize: 12, color: tokens.textSecondary)),
                  const Spacer(),
                  Text(
                    '${booking.price.toStringAsFixed(0)} $currency',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.accent),
                  ),
                  const SizedBox(width: 4),
                  AppIcon(Icons.chevron_right, size: 15, color: tokens.disabled),
                ],
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
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final label = switch (status) {
      ClientBookingStatus.expected => t(tk: 'Tassyklanan', ru: 'Подтверждено', en: 'Confirmed'),
      ClientBookingStatus.completed => t(tk: 'Tamamlandy', ru: 'Завершено', en: 'Completed'),
      ClientBookingStatus.cancelled => t(tk: 'Ýatyryldy', ru: 'Отменено', en: 'Cancelled'),
      ClientBookingStatus.noShow => t(tk: 'Gelmedi', ru: 'Не пришёл', en: 'No-show'),
    };
    final fg = _bookingStatusColor(tokens, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: fg.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

/// Individual raised card — each booking on the "Ýazgylarym" tab and in the
/// home preview.
class _ClientBookingCard extends StatelessWidget {
  const _ClientBookingCard({required this.booking, required this.tk});
  final ClientBooking booking;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: _bookingCardDecoration(tokens),
      child: Material(
        color: Colors.transparent,
        child: _ClientBookingRow(booking: booking, tk: tk),
      ),
    );
  }
}

/// The home preview: one card per upcoming booking.
class _ClientBookingsListCard extends StatelessWidget {
  const _ClientBookingsListCard({required this.bookings, required this.tk});
  final List<ClientBooking> bookings;
  final bool tk;

  @override
  Widget build(BuildContext context) => Column(
    children: [for (final b in bookings) _ClientBookingCard(booking: b, tk: tk)],
  );
}

/// The soonest upcoming booking, shown big at the top of "Indiki".
class _NextBookingHero extends StatelessWidget {
  const _NextBookingHero({required this.booking, required this.language});
  final ClientBooking booking;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    final countdown = _bookingCountdown(booking, language);
    String clock(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: () => Navigator.push(context, pageRoute(AppointmentDetailScreen(booking: booking))),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _flatTintDecoration(tokens, tokens.accent, shadow: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: tokens.accent, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    t(tk: 'Indiki ýazgy', ru: 'Ближайшая запись', en: 'Next booking'),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tokens.accentOn),
                  ),
                ),
                const Spacer(),
                if (countdown != null)
                  Row(
                    children: [
                      AppIcon(Icons.timer_outlined, size: 14, color: tokens.textPrimary),
                      const SizedBox(width: 4),
                      Text(countdown, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(formatDate(booking.startsAt), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.1)),
            const SizedBox(height: 6),
            Row(
              children: [
                AppIcon(Icons.schedule_outlined, size: 16, color: tokens.accent),
                const SizedBox(width: 6),
                Text(
                  '${clock(booking.startsAt)} – ${clock(booking.endsAt)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: tokens.accent),
                ),
                const SizedBox(width: 8),
                Text('· ${booking.minutes} ${t(tk: 'min', ru: 'мин', en: 'min')}', style: TextStyle(fontSize: 13, color: tokens.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: tokens.surface, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  MasterAvatar(url: booking.masterPhotoUrl, radius: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.masterName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(booking.serviceName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${booking.price.toStringAsFixed(0)} $currency', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: tokens.accent)),
                  AppIcon(Icons.chevron_right, size: 16, color: tokens.disabled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
