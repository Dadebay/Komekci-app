part of 'glass_nav_bar.dart';

class _DockedBar extends StatelessWidget {
  const _DockedBar({required this.icons, required this.labels, required this.currentIndex, required this.onSelected, required this.tokens, required this.badgeCounts});

  final List<HugeIconData> icons;
  final List<String>? labels;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final AppThemeTokens tokens;
  final Map<int, int> badgeCounts;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      // Inset from the screen edges, so every corner is rounded.
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: tokens.border.withValues(alpha: .6)),
        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .10), blurRadius: 22, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        child: Row(
          children: List.generate(
            icons.length,
            (index) => Expanded(
              child: _DockedSlot(
                icon: icons[index],
                label: labels?[index],
                selected: index == currentIndex,
                badgeCount: badgeCounts[index] ?? 0,
                tokens: tokens,
                onTap: () => onSelected(index),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DockedSlot extends StatefulWidget {
  const _DockedSlot({required this.icon, required this.selected, required this.onTap, required this.tokens, required this.badgeCount, this.label});

  final HugeIconData icon;
  final String? label;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;
  final AppThemeTokens tokens;

  @override
  State<_DockedSlot> createState() => _DockedSlotState();
}

class _DockedSlotState extends State<_DockedSlot> with SingleTickerProviderStateMixin {
  /// Drives the icon tracing itself: 0 → 1 when the tab is picked.
  late final AnimationController _draw = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));

  @override
  void didUpdateWidget(_DockedSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) _play();
  }

  void _play() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _draw.forward(from: 0);
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final idle = tokens.textPrimary.withValues(alpha: .5);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _play();
        widget.onTap();
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        tween: Tween(end: widget.selected ? 1 : 0),
        builder: (context, t, _) {
          final color = Color.lerp(idle, tokens.accentOn, t)!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: tokens.accent.withValues(alpha: t), borderRadius: BorderRadius.circular(16)),
                    child: AnimatedBuilder(
                      animation: _draw,
                      builder: (context, _) {
                        final p = _draw.isAnimating ? _draw.value : 1.0;
                        // A small springy pop while the lines are being drawn.
                        final pop = _draw.isAnimating ? .14 * math.sin(math.pi * p) : 0.0;
                        return Transform.scale(
                          scale: 1 + .06 * t + pop,
                          child: AnimatedHugeIcon(icon: widget.icon, color: color, progress: p, size: 22),
                        );
                      },
                    ),
                  ),
                  if (widget.badgeCount > 0)
                    Positioned(
                      right: -7,
                      top: -7,
                      child: IgnorePointer(
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: tokens.danger,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: tokens.surface, width: 1.5),
                          ),
                          child: Text(
                            widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, height: 1),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.label != null) ...[
                const SizedBox(height: 3),
                Text(
                  widget.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w600, color: Color.lerp(tokens.textSecondary, tokens.textPrimary, t)),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
