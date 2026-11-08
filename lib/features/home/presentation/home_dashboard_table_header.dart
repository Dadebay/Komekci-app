part of '../../../app/komekci_app.dart';

class _ApptListHead extends StatelessWidget {
  const _ApptListHead({
    required this.language,
    required this.people,
    required this.freeSlots,
  });
  final AppLanguage language;
  final int people;
  final int freeSlots;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Semantics(
      container: true,
      header: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _apptRowInset,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border(
            bottom: BorderSide(
              color: tokens.accent.withValues(alpha: .55),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            AppIcon(Icons.format_list_numbered, size: 14, color: tokens.accent),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                pickTr(
                  language,
                  tk: 'NOBAT TERTIBI',
                  ru: 'ПОРЯДОК ОЧЕРЕДИ',
                  en: 'QUEUE ORDER',
                ).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .3,
                  color: tokens.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$people ${pickTr(language, tk: 'adam', ru: 'чел.', en: 'people')}'
              '${freeSlots == 0 ? '' : ' · $freeSlots ${pickTr(language, tk: 'boş', ru: 'своб.', en: 'free')}'}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: tokens.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// The numbered badge at the head of every row — a soft, tinted chip rather
/// than a bare digit. Rows tint it with their own status colours, so the
/// number doubles as a status cue you can scan straight down the queue.
class _ApptIndexChip extends StatelessWidget {
  const _ApptIndexChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  static const _size = 28.0;

  @override
  Widget build(BuildContext context) => Container(
    width: _size,
    height: _size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

/// One booked slot: order chip + start time in the left rail, then the
/// customer, the service and (only when there is one) the note, with the
/// status pill on the right.
