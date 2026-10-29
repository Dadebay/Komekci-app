import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_theme_tokens.dart';
import '../utils/app_today.dart';
import 'animated_huge_icon.dart';
import 'nav_motion_icons.dart';
part 'glass_nav_bar_docked.dart';

/// HugeIcons ships its glyphs as JSON path data rather than as [IconData].
typedef HugeIconData = List<List<dynamic>>;

/// Floating frosted navigation bar. The selected slot is marked by a rounded
/// tile that glides between positions, stretching slightly mid-travel; an
/// optional label sits under each icon, outside the tile.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({super.key, required this.icons, required this.currentIndex, required this.onSelected, this.labels, this.animatedIcons = false, this.docked = false, this.badgeCounts = const {}});

  final List<HugeIconData> icons;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// Pending-item counts keyed by tab index on the docked bar.
  /// Zero counts are hidden.
  final Map<int, int> badgeCounts;

  /// One label per icon, shown underneath it. Omit to keep the bar icon-only.
  final List<String>? labels;

  /// Draws the icons by hand and plays a small scene on each when it is picked
  /// (see `nav_motion_icons.dart`). Off, the bar shows plain HugeIcons.
  final bool animatedIcons;

  /// An opaque bar with side margins instead of the floating glass pill:
  /// white surface, rounded corners and a soft shadow, like the booking and
  /// master-profile action bars.
  final bool docked;

  static const _barHeight = 68.0;
  static const _labelledBarHeight = 60.0;
  static const _tileWidth = 54.0;
  static const _tileHeight = 46.0;
  static const _labelledTileHeight = 34.0;
  static const _tileTop = 6.0;
  static const _slide = Duration(milliseconds: 460);

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    if (docked) {
      return _DockedBar(icons: icons, labels: labels, currentIndex: currentIndex, onSelected: onSelected, tokens: t, badgeCounts: badgeCounts);
    }
    final hasLabels = labels != null;
    final barHeight = hasLabels ? _labelledBarHeight : _barHeight;
    final tileHeight = hasLabels ? _labelledTileHeight : _tileHeight;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        // The shadow lives outside the clip — inside it would be cut away.
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(color: t.scrim.withValues(alpha: .18), blurRadius: 30, spreadRadius: -6, offset: const Offset(0, 14)),
              BoxShadow(color: t.scrim.withValues(alpha: .10), blurRadius: 10, spreadRadius: -2, offset: const Offset(0, 3)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: barHeight,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: t.surface.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: t.textPrimary.withValues(alpha: .10), width: 1),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slot = constraints.maxWidth / icons.length;
                    // Driving the tween off the index keeps motion continuous even
                    // when taps land before the previous slide has settled.
                    return TweenAnimationBuilder<double>(
                      duration: _slide,
                      curve: Curves.easeOutQuint,
                      tween: Tween(end: currentIndex.toDouble()),
                      builder: (context, position, _) {
                        // Widest at the halfway point of a hop, back to rest on arrival.
                        final travel = (position - position.roundToDouble()).abs() * 2;
                        final width = _tileWidth * (1 + (travel * .28));
                        return Stack(
                          children: [
                            Positioned(
                              left: (slot * position) + ((slot - width) / 2),
                              top: hasLabels ? _tileTop : (barHeight - tileHeight) / 2,
                              width: width,
                              height: tileHeight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                icons.length,
                                (index) => Expanded(
                                  child: _NavSlot(
                                    icon: icons[index],
                                    label: labels?[index],
                                    tokens: t,
                                    selected: index == currentIndex,
                                    animated: animatedIcons,
                                    // Fade tracks the tile, so the icon lights up as it arrives.
                                    progress: (1 - (position - index).abs()).clamp(0.0, 1.0),
                                    onTap: () => onSelected(index),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatefulWidget {
  const _NavSlot({
    required this.icon,
    required this.selected,
    required this.animated,
    required this.progress,
    required this.onTap,
    required this.tokens,
    this.label,
  });

  final HugeIconData icon;
  final String? label;
  final bool selected;
  final bool animated;

  /// 1 when this slot holds the tile, 0 when the tile is a full slot away.
  final double progress;
  final VoidCallback onTap;
  final AppThemeTokens tokens;

  @override
  State<_NavSlot> createState() => _NavSlotState();
}

class _NavSlotState extends State<_NavSlot> with SingleTickerProviderStateMixin {
  static const _iconSize = 21.0;

  late final AnimationController _controller = AnimationController(vsync: this);

  /// Hand-drawn icons play their own scene (master bar only); otherwise plain HugeIcons.
  late final NavMotionKind? _kind = widget.animated ? navMotionKindFor(widget.icon) : null;
  bool _pressed = false;

  @override
  void didUpdateWidget(_NavSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) _play();
  }

  void _play() {
    final kind = _kind;
    if (kind == null || MediaQuery.disableAnimationsOf(context)) return;
    _controller.duration = navMotionLength(kind);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _glyph(double t) {
    final kind = _kind;
    if (kind != null) {
      // Grey while the tile is away, the on-accent colour as it arrives.
      final color = Color.lerp(widget.tokens.textPrimary.withValues(alpha: .5), widget.tokens.accentOn, widget.progress)!;
      return NavMotionIcon(kind: kind, t: t, color: color, size: _iconSize, day: appToday().day);
    }
    // Two copies cross-fade so the icon recolours while the tile travels.
    return SizedBox(
      width: _iconSize,
      height: _iconSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 1 - widget.progress,
            child: HugeIcon(icon: widget.icon, color: widget.tokens.textPrimary.withValues(alpha: .5), size: _iconSize),
          ),
          Opacity(
            opacity: widget.progress,
            child: HugeIcon(icon: widget.icon, color: widget.tokens.accentOn, size: _iconSize),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconStack = Transform.scale(
      scale: 1 + (widget.progress * .1),
      child: SizedBox(
        width: 40,
        height: widget.label == null ? 40 : GlassNavBar._labelledTileHeight,
        child: Center(
          // 1 is the resting icon, so it is also what an idle slot paints.
          child: AnimatedBuilder(animation: _controller, builder: (context, _) => _glyph(_controller.isAnimating ? _controller.value : 1)),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        _play();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .88 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.label == null
            ? Center(child: iconStack)
            : Padding(
                padding: const EdgeInsets.only(top: GlassNavBar._tileTop),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconStack,
                    const SizedBox(height: 1),
                    Text(
                      widget.label!,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Color.lerp(widget.tokens.textSecondary, widget.tokens.accent, widget.progress),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Docked variant of [GlassNavBar]: plain HugeIcons with a caption, the picked
/// tab tinted in the accent colour on a soft rounded highlight.
