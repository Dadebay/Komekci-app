part of '../../../app/komekci_app.dart';

class _ApptStatusPill extends StatelessWidget {
  const _ApptStatusPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 11, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// A free gap between two bookings — same left rail as [_HomeApptRow] so the
/// numbering and times stay in one line down the list, with the "Üýtgetmek"
/// action that opens the day in Senenama.
class _HomeFreeRow extends StatelessWidget {
  const _HomeFreeRow({
    required this.index,
    required this.start,
    required this.end,
    required this.language,
    required this.onTap,
    required this.showDivider,
    this.closed,
  });
  final int index;
  final DateTime start;
  final DateTime end;
  final AppLanguage language;
  final VoidCallback onTap;
  final bool showDivider;
  final ClosedTime? closed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final freeColor = closed != null
        ? tokens.warning
        : tokens.brightness == Brightness.dark
        ? tokens.success
        : const Color(0xff2A5DB0);
    final minutes = end.difference(start).inMinutes;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: _apptRowInset,
      ),
      decoration: BoxDecoration(
        color: closed != null
            ? tokens.surfaceElevated
            : tokens.brightness == Brightness.dark
            ? freeSlotSurface(tokens)
            : freeSlotBg.withValues(alpha: .5),
        border: showDivider
            ? Border(bottom: BorderSide(color: tokens.border))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _apptRailWidth,
            child: Column(
              children: [
                _ApptIndexChip(
                  label: '$index',
                  color: freeColor,
                  background: freeColor.withValues(alpha: .12),
                ),
                const SizedBox(height: 6),
                Text(
                  formatTime(TimeOfDay.fromDateTime(start)),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: freeColor,
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
                  children: [
                    AppIcon(
                      closed == null
                          ? Icons.schedule_outlined
                          : Icons.lock_clock_outlined,
                      size: 14,
                      color: freeColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        closed == null
                            ? pickTr(
                                language,
                                tk: 'Boş aralyk',
                                ru: 'Свободно',
                                en: 'Free slot',
                              )
                            : pickTr(
                                language,
                                tk: 'Ýapyk wagt',
                                ru: 'Закрытое время',
                                en: 'Blocked time',
                              ),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: freeColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatTime(TimeOfDay.fromDateTime(start))} – ${formatTime(TimeOfDay.fromDateTime(end))} · $minutes ${pickTr(language, tk: 'min', ru: 'мин', en: 'min')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: freeColor.withValues(alpha: .8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (closed?.note.isNotEmpty == true)
                  Text(
                    closed!.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: freeColor,
              side: BorderSide(color: freeColor),
              backgroundColor: context.appTokens.surface,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              visualDensity: VisualDensity.compact,
            ),
            icon: AppIcon(
              closed == null ? Icons.edit_outlined : Icons.lock_open_outlined,
              size: 12,
            ),
            label: Text(
              closed == null
                  ? pickTr(
                      language,
                      tk: 'Üýtgetmek',
                      ru: 'Изменить',
                      en: 'Edit',
                    )
                  : pickTr(language, tk: 'Açmak', ru: 'Открыть', en: 'Reopen'),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
