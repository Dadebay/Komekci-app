part of '../../../app/komekci_app.dart';

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.title,
    required this.description,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final AppThemeTokens palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final fill = selected && tokens.surfaceElevated != tokens.surface
        ? Color.alphaBlend(palette.accent.withValues(alpha: .07), tokens.surface)
        : tokens.surfaceElevated;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? palette.accent : tokens.border, width: selected ? 1.6 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Row(
              children: [
                _ThemeMiniPreview(palette: palette),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(color: tokens.textSecondary, fontSize: 12.5)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? palette.accent : Colors.transparent,
                    border: Border.all(color: selected ? palette.accent : tokens.border, width: 1.5),
                  ),
                  child: selected ? Icon(Icons.check, color: palette.accentOn, size: 18) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeMiniPreview extends StatelessWidget {
  const _ThemeMiniPreview({required this.palette});

  final AppThemeTokens palette;

  @override
  Widget build(BuildContext context) => Container(
    width: 55,
    height: 60,
    decoration: BoxDecoration(
      color: palette.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: palette.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 16, color: palette.accent),
        const SizedBox(height: 8),
        Container(width: 30, height: 4, margin: const EdgeInsets.only(left: 8), decoration: BoxDecoration(color: palette.textPrimary.withValues(alpha: .65), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 5),
        Container(width: 22, height: 4, margin: const EdgeInsets.only(left: 8), decoration: BoxDecoration(color: palette.border, borderRadius: BorderRadius.circular(2))),
        const Spacer(),
        Container(width: 37, height: 8, margin: const EdgeInsets.fromLTRB(8, 0, 0, 7), decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(3))),
      ],
    ),
  );
}
