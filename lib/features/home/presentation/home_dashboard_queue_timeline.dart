part of '../../../app/komekci_app.dart';

/// Switch between the two queue designs on the home dashboard. `true` is the
/// timeline (time on the left, a rail with dots, one card per booking);
/// `false` brings back the original numbered rows, which are still in
/// `home_dashboard_appointment_row.dart` / `home_dashboard_free_row.dart`.
const _useTimelineQueueDesign = false;

const _queueTimeWidth = 46.0;
const _queueRailWidth = 22.0;

/// Colours and icon for a booking's status in the timeline.
(Color, Color, IconData) _queueStatusStyle(
  AppointmentStatus status,
  AppThemeTokens tokens,
) {
  final dark = tokens.brightness == Brightness.dark;
  return switch (status) {
    AppointmentStatus.completed => (
      dark ? _apptStatusColor(status, tokens) : freeSlotColorDark,
      dark ? _apptStatusBg(status, tokens) : freeSlotBg,
      Icons.check_circle,
    ),
    AppointmentStatus.arrived => (
      dark ? _apptStatusColor(status, tokens) : const Color(0xff2A5DB0),
      dark ? _apptStatusBg(status, tokens) : const Color(0xffE6EEFB),
      Icons.circle,
    ),
    AppointmentStatus.expected => (
      dark ? _apptStatusColor(status, tokens) : const Color(0xffB8720C),
      dark ? _apptStatusBg(status, tokens) : const Color(0xffFCEDD9),
      Icons.schedule_outlined,
    ),
    AppointmentStatus.cancelled || AppointmentStatus.noShow => (
      dark ? _apptStatusColor(status, tokens) : const Color(0xffC0392B),
      dark ? _apptStatusBg(status, tokens) : const Color(0xffFBE3E0),
      Icons.close,
    ),
  };
}

class _HomeQueueTimeline extends StatelessWidget {
  const _HomeQueueTimeline({
    required this.entries,
    required this.customers,
    required this.language,
    required this.onTapAppointment,
    required this.onTapFree,
    required this.onTapClosed,
  });

  final List<_TimelineEntry> entries;
  final List<Customer> customers;
  final AppLanguage language;
  final void Function(Appointment appointment, Customer? customer)
  onTapAppointment;
  final void Function(DateTime start, DateTime end, DateTime availableEnd)
  onTapFree;
  final void Function(ClosedTime closed) onTapClosed;

  @override
  Widget build(BuildContext context) {
    final busy = entries.whereType<_ApptEntry>().length;
    final free = entries.whereType<_FreeEntry>().length;
    return Column(
      children: [
        _ApptListHead(language: language, people: busy, freeSlots: free),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _apptRowInset,
            14,
            _apptRowInset,
            4,
          ),
          child: Column(
            children: [
              for (var i = 0; i < entries.length; i++)
                _row(
                  context,
                  entries[i],
                  isFirst: i == 0,
                  isLast: i == entries.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    _TimelineEntry entry, {
    required bool isFirst,
    required bool isLast,
  }) {
    if (entry is _ApptEntry) {
      final appointment = entry.appointment;
      final customer = appointment.customerId == null
          ? null
          : _findCustomer(customers, appointment.customerId!);
      return _QueueRow(
        isFirst: isFirst,
        isLast: isLast,
        start: appointment.startsAt,
        end: appointment.endsAt,
        dotColor: _queueStatusStyle(appointment.status, context.appTokens).$1,
        child: _QueueApptCard(
          appointment: appointment,
          customer: customer,
          language: language,
          onTap: () => onTapAppointment(appointment, customer),
        ),
      );
    }
    if (entry is _ClosedEntry) {
      return _QueueRow(
        isFirst: isFirst,
        isLast: isLast,
        start: entry.closed.startsAt,
        end: null,
        hollow: true,
        dotColor: context.appTokens.warning,
        child: _QueueSlotCard(
          start: entry.closed.startsAt,
          end: entry.closed.endsAt,
          closed: entry.closed,
          language: language,
          onTap: () => onTapClosed(entry.closed),
        ),
      );
    }
    final gap = entry as _FreeEntry;
    final tokens = context.appTokens;
    return _QueueRow(
      isFirst: isFirst,
      isLast: isLast,
      start: gap.start,
      end: null,
      hollow: true,
      dotColor: tokens.brightness == Brightness.dark
          ? tokens.success
          : const Color(0xff2A5DB0),
      child: _QueueSlotCard(
        start: gap.start,
        end: gap.end,
        language: language,
        onTap: () => onTapFree(gap.start, gap.end, gap.availableEnd),
      ),
    );
  }
}

/// One line of the timeline: start time, the rail with its dot, the card.
class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.isFirst,
    required this.isLast,
    required this.start,
    required this.end,
    required this.child,
    required this.dotColor,
    this.hollow = false,
  });
  final bool isFirst;
  final bool isLast;
  final DateTime start;
  final DateTime? end;
  final Widget child;
  final Color dotColor;
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _queueTimeWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatTime(TimeOfDay.fromDateTime(start)),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: hollow ? tokens.textSecondary : tokens.textPrimary,
                    ),
                  ),
                  if (end != null)
                    Text(
                      formatTime(TimeOfDay.fromDateTime(end!)),
                      style: TextStyle(
                        fontSize: 11,
                        color: tokens.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _queueRailWidth,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: isFirst ? 16 : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 16 : null,
                  child: Container(width: 2, color: tokens.border),
                ),
                Positioned(
                  top: 11,
                  child: Container(
                    width: hollow ? 11 : 13,
                    height: hollow ? 11 : 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hollow ? tokens.surface : dotColor,
                      border: Border.all(
                        color: hollow ? dotColor : tokens.surface,
                        width: hollow ? 2 : 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 6 : 10),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueApptCard extends StatelessWidget {
  const _QueueApptCard({
    required this.appointment,
    required this.customer,
    required this.language,
    required this.onTap,
  });
  final Appointment appointment;
  final Customer? customer;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final (color, bg, icon) = _queueStatusStyle(appointment.status, tokens);
    final inactive =
        appointment.status == AppointmentStatus.cancelled ||
        appointment.status == AppointmentStatus.noShow;
    final arrived = appointment.status == AppointmentStatus.arrived;
    return Opacity(
      opacity: inactive ? .65 : 1,
      child: Material(
        color: arrived ? bg.withValues(alpha: .5) : tokens.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: arrived ? color.withValues(alpha: .5) : tokens.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RoundPhoto(
                      url: customer?.photoUrl ?? appointment.clientPhotoUrl,
                      radius: 19,
                      backgroundColor: tokens.accent.withValues(alpha: .18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              decoration: inactive
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (customer != null)
                            Text(
                              _handleFor(customer!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: tokens.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ApptStatusPill(
                      label: _apptStatusLabel(appointment.status, language),
                      icon: icon,
                      color: color,
                      background: bg,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      AppIcon(
                        Icons.content_cut,
                        size: 14,
                        color: tokens.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.serviceName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: tokens.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${appointment.minutes} ${AppStrings.bookingMin2.select(language)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: tokens.accent.withValues(alpha: .8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (appointment.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: AppIcon(
                          Icons.sticky_note_2_outlined,
                          size: 13,
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appointment.note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.25,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A free gap or a blocked time: a slim tappable strip, so bookings stay the
/// focus of the list.
class _QueueSlotCard extends StatelessWidget {
  const _QueueSlotCard({
    required this.start,
    required this.end,
    required this.language,
    required this.onTap,
    this.closed,
  });
  final DateTime start;
  final DateTime end;
  final AppLanguage language;
  final VoidCallback onTap;
  final ClosedTime? closed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final blocked = closed != null;
    final color = blocked
        ? tokens.warning
        : (tokens.brightness == Brightness.dark
              ? tokens.success
              : const Color(0xff2A5DB0));
    final minutes = end.difference(start).inMinutes;
    return Material(
      color: color.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
          child: Row(
            children: [
              AppIcon(
                blocked ? Icons.lock_clock_outlined : Icons.schedule_outlined,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blocked
                          ? AppStrings.scheduleBlockedTime.select(language)
                          : AppStrings.homeFreeSlot.select(language),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      '${formatTime(TimeOfDay.fromDateTime(start))} – ${formatTime(TimeOfDay.fromDateTime(end))} · $minutes ${AppStrings.bookingMin2.select(language)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: color.withValues(alpha: .8),
                      ),
                    ),
                    if (closed?.note.isNotEmpty == true)
                      Text(
                        closed!.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.surface,
                  border: Border.all(color: color.withValues(alpha: .5)),
                ),
                child: AppIcon(
                  blocked ? Icons.lock_open_outlined : Icons.add,
                  size: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
