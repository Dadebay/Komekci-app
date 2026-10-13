import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Bottom-nav icons that are drawn by hand so their parts can move: the door
/// swings open, the side people step out, the check mark draws itself, the
/// plus spins in, the head glances around and the heart fills up.
enum NavMotionKind { home, people, calendar, addUser, profile, heart }

/// The scene for the HugeIcons glyph a nav slot was given, if it has one.
NavMotionKind? navMotionKindFor(List<List<dynamic>> icon) {
  if (identical(icon, HugeIcons.strokeRoundedHome01)) return NavMotionKind.home;
  if (identical(icon, HugeIcons.strokeRoundedUserGroup)) return NavMotionKind.people;
  if (identical(icon, HugeIcons.strokeRoundedCalendar01)) return NavMotionKind.calendar;
  if (identical(icon, HugeIcons.strokeRoundedUserAdd01)) return NavMotionKind.addUser;
  if (identical(icon, HugeIcons.strokeRoundedUser)) return NavMotionKind.profile;
  if (identical(icon, HugeIcons.strokeRoundedFavourite)) return NavMotionKind.heart;
  return null;
}

/// How long each scene runs.
Duration navMotionLength(NavMotionKind kind) => Duration(
  milliseconds: switch (kind) {
    NavMotionKind.profile => 1300,
    NavMotionKind.home => 1000,
    NavMotionKind.calendar => 1000,
    _ => 900,
  },
);

/// One nav icon. [t] is the scene clock: 0 at the start of the scene, 1 when
/// it is over — and 1 is also the resting icon, so a finished scene and an
/// icon that never played look the same.
class NavMotionIcon extends StatelessWidget {
  const NavMotionIcon({super.key, required this.kind, required this.t, required this.color, this.size = 22, this.day});

  final NavMotionKind kind;
  final double t;
  final Color color;
  final double size;

  /// Day of the month the calendar icon shows (and counts up to). Defaults to
  /// the device's today.
  final int? day;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _NavIconPainter(kind: kind, t: t, color: color, day: day ?? DateTime.now().day)),
  );
}

double _seg(double t, double from, double to) => ((t - from) / (to - from)).clamp(0.0, 1.0);

class _NavIconPainter extends CustomPainter {
  const _NavIconPainter({required this.kind, required this.t, required this.color, required this.day});

  final NavMotionKind kind;
  final double t;
  final Color color;
  final int day;

  Paint get _stroke => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    switch (kind) {
      case NavMotionKind.home:
        _home(canvas);
      case NavMotionKind.people:
        _people(canvas);
      case NavMotionKind.calendar:
        _calendar(canvas);
      case NavMotionKind.addUser:
        _addUser(canvas);
      case NavMotionKind.profile:
        _profile(canvas);
      case NavMotionKind.heart:
        _heart(canvas);
    }
  }

  // ── Home: the roof hops, the door swings open and light spills out ────────

  void _home(Canvas canvas) {
    final bounce = t < .3 ? math.sin(math.pi * t / .3) : 0.0;
    // Open and shut again over the middle of the scene.
    final open = t < .15 || t > .9 ? 0.0 : math.sin(math.pi * (t - .15) / .75);
    final stroke = _stroke;

    // Roof.
    canvas.save();
    canvas.translate(0, -1.5 * bounce);
    canvas.drawPath(
      Path()
        ..moveTo(2.8, 11.4)
        ..lineTo(12, 3.6)
        ..lineTo(21.2, 11.4),
      stroke,
    );
    canvas.restore();

    // Walls.
    canvas.drawPath(
      Path()
        ..moveTo(5.6, 10.2)
        ..lineTo(5.6, 19.4)
        ..arcToPoint(const Offset(7.2, 21), radius: const Radius.circular(1.6), clockwise: false)
        ..lineTo(16.8, 21)
        ..arcToPoint(const Offset(18.4, 19.4), radius: const Radius.circular(1.6), clockwise: false)
        ..lineTo(18.4, 10.2),
      stroke,
    );

    // Door frame, the glow behind it, and the leaf swinging toward its hinge.
    final frame = Path()
      ..moveTo(9.8, 21)
      ..lineTo(9.8, 16.6)
      ..arcToPoint(const Offset(14.2, 16.6), radius: const Radius.circular(2.2))
      ..lineTo(14.2, 21);
    if (open > 0) {
      canvas.drawPath(
        Path.from(frame)..close(),
        Paint()..color = color.withValues(alpha: .38 * open),
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(9.8, 21)
        ..lineTo(9.8, 16.6)
        ..arcToPoint(const Offset(14.2, 16.6), radius: const Radius.circular(2.2)),
      stroke,
    );
    final leafX = 14.2 - 4.0 * open;
    canvas.drawLine(Offset(leafX, 21), Offset(leafX, 16.6), stroke);
  }

  // ── People: the two behind step out and the front one nods ────────────────

  void _people(Canvas canvas) {
    final step = Curves.easeOutBack.transform(_seg(t, .05, .65));
    final dx = (1 - step) * 4.4;
    final fade = (step * 1.6).clamp(0.0, 1.0);
    final nod = t < .5 ? math.sin(math.pi * t / .5) : 0.0;
    final stroke = _stroke;

    // Sides first, so the front person is drawn over them.
    final sideStroke = _stroke..color = color.withValues(alpha: color.a * fade);
    for (final side in const [-1, 1]) {
      canvas.save();
      canvas.translate(-side * dx, 0);
      // Mirror the right-hand person from the left-hand one.
      if (side == 1) {
        canvas.translate(24, 0);
        canvas.scale(-1, 1);
      }
      canvas.drawCircle(const Offset(5.6, 9.6), 2.2, sideStroke);
      canvas.drawPath(
        Path()
          ..moveTo(1.6, 19.6)
          ..cubicTo(1.6, 16.9, 3.2, 15.2, 5.4, 14.9),
        sideStroke,
      );
      canvas.restore();
    }

    canvas.drawCircle(Offset(12, 7.8 + nod), 2.9, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(7, 20.4)
        ..arcToPoint(const Offset(17, 20.4), radius: const Radius.circular(5)),
      stroke,
    );
  }

  // ── Calendar: the rings clap down and today's date counts up ──────────────

  void _calendar(Canvas canvas) {
    final clap = t < .3 ? math.sin(math.pi * t / .3) : 0.0;
    final stroke = _stroke;

    canvas.drawRRect(RRect.fromLTRBR(3.2, 5.2, 20.8, 20.8, const Radius.circular(3.2)), stroke);
    canvas.drawLine(const Offset(3.2, 9.6), const Offset(20.8, 9.6), stroke);
    for (final x in const [8.0, 16.0]) {
      canvas.drawLine(Offset(x, 2.8 + clap * 1.2), Offset(x, 6.8 + clap * 1.2), stroke);
    }

    // Today's date, counting up from 1 while the rings clap.
    final u = Curves.easeOutCubic.transform(_seg(t, .15, .85));
    final shown = day <= 1 ? day : 1 + ((day - 1) * u).round();
    final pop = 1 + .14 * math.sin(math.pi * _seg(t, .7, 1));
    final text = TextPainter(
      text: TextSpan(
        text: '$shown',
        style: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 8.2,
          height: 1,
          fontWeight: FontWeight.w700,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Centred in the body under the header line.
    canvas.save();
    canvas.translate(12, 15.5);
    canvas.scale(pop);
    text.paint(canvas, Offset(-text.width / 2, -text.height / 2));
    canvas.restore();
  }

  // ── Add user: the plus spins in with a spring, the head dips ──────────────

  void _addUser(Canvas canvas) {
    final dip = t < .5 ? math.sin(math.pi * t / .5) : 0.0;
    final stroke = _stroke;

    canvas.drawCircle(Offset(9.2, 7.8 + .9 * dip), 3.1, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(3.2, 20.4)
        ..arcToPoint(const Offset(15.2, 20.4), radius: const Radius.circular(6)),
      stroke,
    );

    final turn = -(math.pi / 2) * (1 - Curves.easeOutCubic.transform(_seg(t, 0, .7)));
    final grow = .25 + .75 * Curves.elasticOut.transform(_seg(t, 0, .85));
    canvas.save();
    canvas.translate(18.6, 8.6);
    canvas.rotate(turn);
    canvas.scale(grow);
    canvas.drawLine(const Offset(-3.1, 0), const Offset(3.1, 0), stroke);
    canvas.drawLine(const Offset(0, -3.1), const Offset(0, 3.1), stroke);
    canvas.restore();
  }

  // ── Profile: the head glances left, then right, and settles ───────────────

  void _profile(Canvas canvas) {
    // One continuous swing that is still at both ends.
    final u = _seg(t, .1, 1);
    final look = -math.sin(2 * math.pi * u) * math.sin(math.pi * u) / 0.7698;
    final stroke = _stroke;

    canvas.drawPath(
      Path()
        ..moveTo(4.8 - look * .5, 20.6)
        ..arcToPoint(Offset(19.2 - look * .5, 20.6), radius: const Radius.circular(7.2)),
      stroke,
    );
    final rx = 3.5 * (1 - .24 * look.abs());
    canvas.drawOval(
      Rect.fromCenter(center: Offset(12 + look * 1.9, 8 + look.abs() * .35), width: rx * 2, height: 7),
      stroke,
    );
  }

  // ── Heart: fills from the bottom with a double beat and a few sparks ──────

  void _heart(Canvas canvas) {
    final first = t < .25 ? math.sin(math.pi * t / .25) : 0.0;
    final second = t >= .3 && t < .6 ? .7 * math.sin(math.pi * (t - .3) / .3) : 0.0;
    final beat = 1 + .24 * math.max(first, second);
    // Rises, holds, then drains back to an outline.
    final fill = t < .45 ? Curves.easeOut.transform(t / .45) : (t < .75 ? 1.0 : 1 - (t - .75) / .25);
    final stroke = _stroke;

    final heart = Path()
      ..moveTo(12, 20.2)
      ..cubicTo(5.2, 15.4, 3, 12.4, 3, 8.8)
      ..cubicTo(3, 6.2, 5, 4.4, 7.4, 4.4)
      ..cubicTo(9.4, 4.4, 11, 5.4, 12, 7)
      ..cubicTo(13, 5.4, 14.6, 4.4, 16.6, 4.4)
      ..cubicTo(19, 4.4, 21, 6.2, 21, 8.8)
      ..cubicTo(21, 12.4, 18.8, 15.4, 12, 20.2)
      ..close();

    canvas.save();
    canvas.translate(12, 12);
    canvas.scale(beat);
    canvas.translate(-12, -12);
    if (fill > 0 && fill < 1.001) {
      canvas.save();
      canvas.clipPath(heart);
      canvas.drawRect(
        Rect.fromLTRB(0, 21 - 17 * fill, 24, 21),
        Paint()..color = color.withValues(alpha: .9),
      );
      canvas.restore();
    }
    canvas.drawPath(heart, stroke);
    canvas.restore();

    // Sparks flick out from the top of the heart.
    final spark = _seg(t, .15, .6);
    if (spark > 0 && spark < 1) {
      final sparkPaint = _stroke
        ..strokeWidth = 1.3
        ..color = color.withValues(alpha: color.a * (1 - spark));
      for (final angle in const [-2.2, -1.5708, -0.94]) {
        final from = 8.6 + 1.2 * spark;
        final to = from + 2.2 * (1 - spark * .4);
        canvas.drawLine(
          Offset(12 + math.cos(angle) * from, 10.5 + math.sin(angle) * from),
          Offset(12 + math.cos(angle) * to, 10.5 + math.sin(angle) * to),
          sparkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_NavIconPainter old) => old.kind != kind || old.t != t || old.color != color || old.day != day;
}
