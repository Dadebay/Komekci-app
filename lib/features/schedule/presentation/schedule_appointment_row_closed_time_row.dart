part of '../../../app/komekci_app.dart';

class _ClosedTimeRow extends StatelessWidget {
  const _ClosedTimeRow({
    required this.closed,
    required this.language,
    required this.onTap,
  });

  final ClosedTime closed;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: tokens.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.warning.withValues(alpha: .6)),
          ),
          child: Row(
            children: [
              AppIcon(Icons.lock_clock_outlined, size: 20, color: tokens.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${formatTime(TimeOfDay.fromDateTime(closed.startsAt))} – ${formatTime(TimeOfDay.fromDateTime(closed.endsAt))} · ${pickTr(language, tk: 'Ýapyk wagt', ru: 'Закрытое время', en: 'Blocked time')}',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                    ),
                    if (closed.note.isNotEmpty)
                      Text(
                        closed.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                      ),
                  ],
                ),
              ),
              AppIcon(Icons.lock_open_outlined, size: 18, color: tokens.warning),
            ],
          ),
        ),
      ),
    );
  }
}
