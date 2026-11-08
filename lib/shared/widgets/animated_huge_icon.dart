import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

/// A HugeIcons glyph whose strokes can draw themselves. HugeIcons ships its
/// glyphs as SVG path data, so the shapes are parsed once and then painted
/// stroke by stroke: at [progress] 1 this is the plain icon, while 0 → 1 traces
/// every line from nothing, one after another, over a faint ghost of the icon.
class AnimatedHugeIcon extends StatelessWidget {
  const AnimatedHugeIcon({super.key, required this.icon, required this.color, required this.progress, this.size = 22});

  final List<List<dynamic>> icon;
  final Color color;

  /// 0 = nothing drawn yet, 1 = fully drawn (the resting icon).
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _HugeIconPainter(_strokesFor(icon), color, progress)),
  );
}

class _Stroke {
  const _Stroke(this.path, this.width);
  final Path path;
  final double width;
}

final _cache = HashMap<Object, List<_Stroke>>.identity();

List<_Stroke> _strokesFor(List<List<dynamic>> icon) => _cache.putIfAbsent(icon, () {
  final strokes = <_Stroke>[];
  for (final element in icon) {
    if (element.length < 2) continue;
    final tag = element[0] as String;
    final attrs = Map<String, dynamic>.from(element[1] as Map);
    double num(String key, [double fallback = 0]) => double.tryParse('${attrs[key] ?? ''}') ?? fallback;
    final path = Path();
    switch (tag) {
      case 'path':
        final builder = _PathBuilder(path);
        writeSvgPathDataToPath('${attrs['d']}', builder);
      case 'circle':
        path.addOval(Rect.fromCircle(center: Offset(num('cx'), num('cy')), radius: num('r')));
      case 'ellipse':
        path.addOval(Rect.fromCenter(center: Offset(num('cx'), num('cy')), width: num('rx') * 2, height: num('ry') * 2));
      case 'rect':
        path.addRRect(RRect.fromLTRBR(num('x'), num('y'), num('x') + num('width'), num('y') + num('height'), Radius.circular(num('rx'))));
      case 'line':
        path
          ..moveTo(num('x1'), num('y1'))
          ..lineTo(num('x2'), num('y2'));
      default:
        continue;
    }
    strokes.add(_Stroke(path, num('strokeWidth', 1.5)));
  }
  return strokes;
});

class _PathBuilder extends PathProxy {
  _PathBuilder(this.path);
  final Path path;

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}

class _HugeIconPainter extends CustomPainter {
  const _HugeIconPainter(this.strokes, this.color, this.progress);
  final List<_Stroke> strokes;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final drawing = progress < 1;
    // Each stroke starts a little after the one before it.
    final stagger = strokes.length <= 1 ? 0.0 : .35 / (strokes.length - 1);
    final window = 1 - .35;
    for (var i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      if (!drawing) {
        canvas.drawPath(stroke.path, paint..color = color);
        continue;
      }
      // A faint ghost keeps the icon readable while it traces itself.
      canvas.drawPath(stroke.path, paint..color = color.withValues(alpha: color.a * .22));
      final local = ((progress - i * stagger) / window).clamp(0.0, 1.0);
      final eased = Curves.easeInOutCubic.transform(local);
      if (eased <= 0) continue;
      final solid = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color;
      for (final metric in stroke.path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * math.min(1, eased)), solid);
      }
    }
  }

  @override
  bool shouldRepaint(_HugeIconPainter old) => old.progress != progress || old.color != color || old.strokes != strokes;
}
