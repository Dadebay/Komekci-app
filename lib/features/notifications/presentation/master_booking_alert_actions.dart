part of 'master_booking_alert_overlay.dart';

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.tokens});

  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.accent.withValues(alpha: .12),
      ),
      child: Container(
        width: 62,
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tokens.accent,
          boxShadow: [
            BoxShadow(
              color: tokens.accent.withValues(alpha: .35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AppIcon(
          Icons.calendar_month_rounded,
          size: 28,
          color: tokens.accentOn,
        ),
      ),
    );
  }
}

/// Dismiss button whose trailing ring counts down the auto-close time.
class _CountdownButton extends StatelessWidget {
  const _CountdownButton({
    required this.label,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final textColouredButton = t.button == t.textPrimary;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: t.button,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.only(left: 22, right: 8),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            const SizedBox(width: 38),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: t.buttonText,
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: duration,
              builder: (context, value, _) => SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 2.5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: t.buttonText.withValues(alpha: .18),
                        color: textColouredButton ? t.accent : t.buttonText,
                      ),
                    ),
                    Text(
                      '${(value * duration.inSeconds).ceil()}',
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: t.buttonText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
