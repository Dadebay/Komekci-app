part of '../../../app/komekci_app.dart';

class _HomeApptRow extends StatelessWidget {
  const _HomeApptRow({
    required this.index,
    required this.appointment,
    required this.customer,
    required this.language,
    required this.onTap,
    required this.showDivider,
  });
  final int index;
  final Appointment appointment;
  final Customer? customer;
  final AppLanguage language;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final (
      lightStatusColor,
      lightStatusBg,
      statusIcon,
    ) = switch (appointment.status) {
      AppointmentStatus.completed => (
        freeSlotColorDark,
        freeSlotBg,
        Icons.check_circle,
      ),
      AppointmentStatus.arrived => (
        const Color(0xff2A5DB0),
        const Color(0xffE6EEFB),
        Icons.circle,
      ),
      AppointmentStatus.expected => (
        const Color(0xffB8720C),
        const Color(0xffFCEDD9),
        Icons.schedule_outlined,
      ),
      AppointmentStatus.cancelled || AppointmentStatus.noShow => (
        const Color(0xffC0392B),
        const Color(0xffFBE3E0),
        Icons.close,
      ),
    };
    final statusColor = tokens.brightness == Brightness.dark
        ? _apptStatusColor(appointment.status, tokens)
        : lightStatusColor;
    final statusBg = tokens.brightness == Brightness.dark
        ? _apptStatusBg(appointment.status, tokens)
        : lightStatusBg;
    // Mirrors the reference design's single highlighted "in progress" row —
    // the client is on-site right now, so it's the one row worth calling out.
    final highlighted = appointment.status == AppointmentStatus.arrived;
    final minutesLabel = pickTr(language, tk: 'min', ru: 'мин', en: 'min');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 9,
          horizontal: _apptRowInset,
        ),
        decoration: BoxDecoration(
          color: highlighted ? statusBg.withValues(alpha: .5) : null,
          border: showDivider
              ? Border(bottom: BorderSide(color: tokens.border))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left rail: the queue position, with the slot's start and end
            // time under it — the two things the master scans for first.
            SizedBox(
              width: _apptRailWidth,
              child: Column(
                children: [
                  _ApptIndexChip(
                    label: '$index',
                    color: statusColor,
                    background: statusBg,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatTime(TimeOfDay.fromDateTime(appointment.startsAt)),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
                  ),
                  Text(
                    formatTime(TimeOfDay.fromDateTime(appointment.endsAt)),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: tokens.textSecondary,
                    ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customer == null
                          ? CircleAvatar(
                              radius: 16,
                              backgroundColor: tokens.accent.withValues(
                                alpha: .18,
                              ),
                              child: AppIcon(
                                Icons.person_outline,
                                size: 15,
                                color: tokens.textPrimary,
                              ),
                            )
                          : _CustomerAvatar(customer: customer!, radius: 16),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              appointment.clientName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (customer != null)
                              Text(
                                _handleFor(customer!),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: tokens.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ApptStatusPill(
                        label: _apptStatusLabel(appointment.status, language),
                        icon: statusIcon,
                        color: statusColor,
                        background: statusBg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // The service is what the master is actually about to do,
                  // so it gets its own tinted chip instead of a narrow column
                  // that used to clip after two lines.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Row(
                      children: [
                        AppIcon(
                          Icons.content_cut,
                          size: 13,
                          color: tokens.accent,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            appointment.serviceName,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: tokens.accent,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${appointment.minutes} $minutesLabel',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tokens.accent.withValues(alpha: .75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (appointment.note.isNotEmpty) ...[
                    const SizedBox(height: 7),
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
                            style: TextStyle(
                              fontSize: 11.5,
                              color: tokens.textSecondary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}

/// Status pill — label plus its icon, sized to its text so it can sit beside
/// the customer's name on any phone width.
