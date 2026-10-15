part of '../../../app/komekci_app.dart';

/// Small status pill used inside the actions sheet (distinct name from
/// [_StatusBadge] to keep icon-less usage simple here).
class _StatusBadge2 extends StatelessWidget {
  const _StatusBadge2({
    required this.label,
    required this.color,
    required this.bg,
  });
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({
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
    final statusColor = _apptStatusColor(appointment.status, tokens);
    final phone = customer?.phone ?? appointment.clientPhone;
    final canCall =
        appointment.status == AppointmentStatus.expected &&
        phone != null &&
        phone.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        elevation: 1,
        shadowColor: tokens.textPrimary.withValues(alpha: .10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: statusColor.withValues(alpha: .24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIcon(
                      Icons.schedule_outlined,
                      size: 17,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${formatTime(TimeOfDay.fromDateTime(appointment.startsAt))} – ${formatTime(TimeOfDay.fromDateTime(appointment.endsAt))}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge2(
                      label: _apptStatusLabel(appointment.status, language),
                      color: statusColor,
                      bg: _apptStatusBg(appointment.status, tokens),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Divider(height: 1, color: tokens.border),
                const SizedBox(height: 13),
                Row(
                  children: [
                    customer == null
                        ? CircleAvatar(
                            radius: 20,
                            backgroundColor: tokens.accent.withValues(
                              alpha: .16,
                            ),
                            child: AppIcon(
                              Icons.person_outline,
                              size: 19,
                              color: tokens.accent,
                            ),
                          )
                        : _CustomerAvatar(customer: customer!, radius: 20),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                          if (customer != null)
                            Text(
                              '${_handleFor(customer!)} · ${_scheduleCustomerLabel(customer!.status, language)}',
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
                    if (canCall) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: pickTr(
                          language,
                          tk: 'Jaň etmek',
                          ru: 'Позвонить',
                          en: 'Call',
                        ),
                        onPressed: () => launchUrl(
                          Uri(scheme: 'tel', path: phone.replaceAll(' ', '')),
                        ),
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: tokens.surface,
                          side: BorderSide(color: tokens.border),
                        ),
                        icon: AppIcon(
                          Icons.phone_outlined,
                          size: 18,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      AppIcon(
                        Icons.content_cut,
                        size: 15,
                        color: tokens.accent,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          appointment.serviceName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (appointment.note.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: AppIcon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.3,
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

class _FreeSlotRow extends StatelessWidget {
  const _FreeSlotRow({
    required this.start,
    required this.end,
    required this.language,
    required this.onTap,
  });
  final DateTime start;
  final DateTime end;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    // No left time-column reserve here, unlike [_AppointmentRow] — the free
    // slot's time range is printed inside the card itself, so reserving
    // that column would just leave an empty gap to its left.
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: freeSlotSurface(context.appTokens),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: freeSlotForeground(context.appTokens).withValues(alpha: .6)),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: freeSlotForeground(context.appTokens).withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                Icons.schedule_outlined,
                size: 13,
                color: freeSlotForeground(context.appTokens),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${formatTime(TimeOfDay.fromDateTime(start))} - ${formatTime(TimeOfDay.fromDateTime(end))}',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: freeSlotForeground(context.appTokens),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '· ${pickTr(language, tk: "Boş wagt", ru: "Свободно", en: "Free")}',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: freeSlotForeground(context.appTokens),
              ),
            ),
            const Spacer(),
            AppIcon(Icons.add, size: 15, color: freeSlotForeground(context.appTokens)),
          ],
        ),
      ),
    ),
  );
}
