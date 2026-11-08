import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
part 'nav_motion_painter.dart';

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
