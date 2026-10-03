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

const _timeColumnWidth = 46.0;

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
    final tint = customer == null
        ? tokens.surface
        : _statusBg(customer!.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _timeColumnWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                formatTime(TimeOfDay.fromDateTime(appointment.startsAt)),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: tokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customer == null
                            ? CircleAvatar(
                                radius: 17,
                                backgroundColor: const Color(0xffE6D2B1),
                                child: AppIcon(
                                  Icons.person_outline,
                                  size: 15,
                                  color: tokens.textPrimary,
                                ),
                              )
                            : _CustomerAvatar(customer: customer!, radius: 17),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.black45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (customer != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _StatusBadge2(
                              label: _scheduleCustomerLabel(
                                customer!.status,
                                language,
                              ),
                              color: _statusColor(customer!.status),
                              bg: tokens.surface,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appointment.serviceName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusBadge2(
                          label: _apptStatusLabel(appointment.status, language),
                          color: _apptStatusColor(appointment.status),
                          bg: _apptStatusBg(appointment.status),
                        ),
                        if (appointment.status == AppointmentStatus.expected &&
                            customer != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri(
                                scheme: 'tel',
                                path: customer!.phone.replaceAll(' ', ''),
                              ),
                            ),
                            child: Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tokens.surface,
                                border: Border.all(color: tokens.border),
                              ),
                              child: AppIcon(
                                Icons.phone_outlined,
                                size: 12,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _freeSlotColor = Color(0xff2FAE60);

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
          color: freeSlotBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _freeSlotColor.withValues(alpha: .6)),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _freeSlotColor.withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: const AppIcon(
                Icons.schedule_outlined,
                size: 13,
                color: freeSlotColorDark,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${formatTime(TimeOfDay.fromDateTime(start))} - ${formatTime(TimeOfDay.fromDateTime(end))}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: freeSlotColorDark,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '· ${pickTr(language, tk: "Boş wagt", ru: "Свободно", en: "Free")}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: freeSlotColorDark,
              ),
            ),
            const Spacer(),
            const AppIcon(Icons.add, size: 15, color: freeSlotColorDark),
          ],
        ),
      ),
    ),
  );
}
