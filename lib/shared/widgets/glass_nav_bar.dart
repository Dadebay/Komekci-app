import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';

/// HugeIcons ships its glyphs as JSON path data rather than as [IconData].
typedef HugeIconData = List<List<dynamic>>;

/// Floating frosted navigation bar. Icons only — the selected slot is marked by
/// a rounded tile that glides between positions, stretching slightly mid-travel.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.icons,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<HugeIconData> icons;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const _barHeight = 68.0;
  static const _tileWidth = 54.0;
  static const _tileHeight = 46.0;
  static const _slide = Duration(milliseconds: 460);

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      // The shadow lives outside the clip — inside it would be cut away.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(color: ink.withValues(alpha: .18), blurRadius: 30, spreadRadius: -6, offset: const Offset(0, 14)),
            BoxShadow(color: ink.withValues(alpha: .10), blurRadius: 10, spreadRadius: -2, offset: const Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: _barHeight,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .82),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: ink.withValues(alpha: .10), width: 1),
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
                          top: (_barHeight - _tileHeight) / 2,
                          width: width,
                          height: _tileHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: gold.withValues(alpha: .42), blurRadius: 16, offset: const Offset(0, 5)),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(
                            icons.length,
                            (index) => Expanded(
                              child: _NavSlot(
                                icon: icons[index],
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

class _NavSlot extends StatelessWidget {
  const _NavSlot({required this.icon, required this.progress, required this.onTap});

  final HugeIconData icon;

  /// 1 when this slot holds the tile, 0 when the tile is a full slot away.
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Center(
      child: Transform.scale(
        scale: 1 + (progress * .1),
        child: SizedBox(
          width: 44,
          height: 44,
          // Two copies cross-fade so the icon recolours while the tile travels.
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 1 - progress,
                child: HugeIcon(icon: icon, color: ink.withValues(alpha: .5), size: 23),
              ),
              Opacity(
                opacity: progress,
                child: HugeIcon(icon: icon, color: Colors.white, size: 23),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
