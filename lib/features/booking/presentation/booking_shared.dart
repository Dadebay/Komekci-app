part of '../../../app/komekci_app.dart';


const _monthsEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Translator shorthand shared by every screen in this flow.
typedef _Tr =
    String Function({
      required String tk,
      required String ru,
      required String en,
    });

/// Soft raised surface used by every card in the booking flow.
BoxDecoration _bookingCardDecoration(AppThemeTokens tokens, {bool selected = false}) => BoxDecoration(
  color: selected && tokens.surfaceElevated != tokens.surface
      ? Color.alphaBlend(tokens.accent.withValues(alpha: .07), tokens.surface)
      : tokens.surface,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: selected ? tokens.accent : tokens.border.withValues(alpha: .7), width: selected ? 1.5 : 1),
  boxShadow: [
    BoxShadow(color: tokens.textPrimary.withValues(alpha: selected ? .07 : .05), blurRadius: 18, offset: const Offset(0, 6)),
  ],
);

/// A flat, softly tinted surface (no gradient) for highlighted cards: the
/// page colour with a wash of [tint], a thin border in the same tint and,
/// optionally, a soft shadow.
BoxDecoration _flatTintDecoration(AppThemeTokens tokens, Color tint, {double radius = 28, bool shadow = false}) => BoxDecoration(
  color: Color.alphaBlend(tint.withValues(alpha: .10), tokens.surface),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: tint.withValues(alpha: .28)),
  boxShadow: shadow ? [BoxShadow(color: tokens.textPrimary.withValues(alpha: .06), blurRadius: 18, offset: const Offset(0, 8))] : null,
);

/// Top of every wizard step: back button, the master being booked, and the
/// step progress underneath.
class _BookingHeader extends StatelessWidget {
  const _BookingHeader({required this.master, required this.current, required this.labels});
  final MasterBrief master;
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: tokens.border.withValues(alpha: .8)),
                    boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .06), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: AppIcon(Icons.arrow_back, size: 19, color: tokens.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: tokens.border.withValues(alpha: .6)),
                  ),
                  child: Row(
                    children: [
                      MasterAvatar(url: master.photoUrl, radius: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              master.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.15),
                            ),
                            Text(
                              master.address.isNotEmpty ? master.address : '@${master.nickname}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: tokens.textSecondary, height: 1.2),
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
          const SizedBox(height: 20),
          _WizardSteps(current: current, labels: labels),
        ],
      ),
    );
  }
}

/// "1 Hyzmat · 2 Wagt · 3 Tassykla" progress row used across the wizard.
class _WizardSteps extends StatelessWidget {
  const _WizardSteps({required this.current, required this.labels});
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    const dur = Duration(milliseconds: 260);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final done = (i ~/ 2) + 1 < current;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: AnimatedContainer(
                duration: dur,
                height: 2.5,
                decoration: BoxDecoration(color: done ? t.accent : t.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          );
        }
        final step = (i ~/ 2) + 1;
        final active = step == current;
        final done = step < current;
        return SizedBox(
          width: 56,
          child: Column(
            children: [
              AnimatedContainer(
                duration: dur,
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active || done ? t.accent : t.surface,
                  border: Border.all(color: active || done ? t.accent : t.border, width: 1.5),
                  boxShadow: active ? [BoxShadow(color: t.accent.withValues(alpha: .35), blurRadius: 10, offset: const Offset(0, 3))] : null,
                ),
                child: done
                    ? AppIcon(Icons.check, size: 14, color: t.accentOn)
                    : Text(
                        '$step',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: active ? t.accentOn : t.textSecondary),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[step - 1],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active || done ? t.textPrimary : t.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Bottom bar with a summary on the left and the primary action on the right.
class _BookingBottomBar extends StatelessWidget {
  const _BookingBottomBar({required this.caption, required this.value, required this.label, required this.onPressed, this.loading = false});
  final String caption;
  final String value;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .08), blurRadius: 22, offset: const Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  // Without this the column fills the height the Scaffold
                  // offers a bottom bar (the whole screen) and hides the page.
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(caption, style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
                    const SizedBox(height: 2),
                    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.textPrimary,
                    disabledBackgroundColor: tokens.border,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                  ),
                  onPressed: loading ? null : onPressed,
                  child: loading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: tokens.surface))
                      : Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big screen title with a quiet subtitle underneath.
class _BookingTitle extends StatelessWidget {
  const _BookingTitle({required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.15)),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle!, style: TextStyle(fontSize: 13.5, color: context.appTokens.textSecondary)),
      ],
    ],
  );
}
