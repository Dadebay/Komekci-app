part of '../../../app/komekci_app.dart';

class _HomeStatCard extends StatelessWidget {
  const _HomeStatCard({
    required this.refreshingNumbers,
    required this.numberShimmer,
    required this.numberCountUp,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.hint,
  });
  final bool refreshingNumbers;
  final Animation<double> numberShimmer;
  final Animation<double> numberCountUp;
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: context.appTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.appTokens.border),
      boxShadow: [
        BoxShadow(
          color: context.appTokens.textPrimary.withValues(alpha: .06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _DashboardNumber(
          loading: refreshingNumbers,
          shimmer: numberShimmer,
          countUp: numberCountUp,
          value: value,
          color: color,
          placeholderWidth: 56,
          placeholderHeight: 24,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: TextStyle(
            fontSize: 10.5,
            color: context.appTokens.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// Hides the old value during refresh, then counts up to the latest API value.
class _DashboardNumber extends StatelessWidget {
  const _DashboardNumber({
    required this.loading,
    required this.shimmer,
    required this.countUp,
    required this.value,
    required this.color,
    required this.style,
    required this.placeholderWidth,
    required this.placeholderHeight,
    this.suffix = '',
  });

  final bool loading;
  final Animation<double> shimmer;
  final Animation<double> countUp;
  final String value;
  final String suffix;
  final Color color;
  final TextStyle style;
  final double placeholderWidth;
  final double placeholderHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: placeholderWidth,
        minHeight: placeholderHeight,
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          ExcludeSemantics(
            child: Opacity(
              opacity: 0,
              child: Text(
                '$value$suffix',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (loading)
            AnimatedBuilder(
              animation: shimmer,
              builder: (context, _) => ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    LinearGradient(
                      colors: [
                        color.withValues(alpha: .12),
                        color.withValues(alpha: .38),
                        color.withValues(alpha: .12),
                      ],
                    ).createShader(
                      Rect.fromLTWH(
                        bounds.left + (shimmer.value * 2 - 1) * bounds.width,
                        bounds.top,
                        bounds.width,
                        bounds.height,
                      ),
                    ),
                child: Container(
                  width: placeholderWidth,
                  height: placeholderHeight,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            )
          else
            AnimatedBuilder(
              animation: countUp,
              builder: (context, _) => Text(
                '${_countedValue(value, countUp.value)}$suffix',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  static String _countedValue(String target, double progress) {
    if (progress >= 1) return target;
    final fraction = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final time = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(target);
    if (time != null) {
      final minutes = int.parse(time[1]!) * 60 + int.parse(time[2]!);
      final current = (minutes * fraction).round();
      return '${(current ~/ 60).toString().padLeft(2, '0')}:${(current % 60).toString().padLeft(2, '0')}';
    }
    final number = double.tryParse(target);
    if (number == null) return target;
    final decimals = target.contains('.') ? target.split('.').last.length : 0;
    final current = number * fraction;
    return decimals == 0
        ? current.round().toString()
        : current.toStringAsFixed(decimals);
  }
}
