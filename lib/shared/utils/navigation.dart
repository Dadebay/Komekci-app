import 'package:flutter/material.dart';

Route<T> pageRoute<T>(Widget screen) => PageRouteBuilder<T>(
  pageBuilder: (_, animation, _) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: screen,
    ),
  ),
  transitionDuration: const Duration(milliseconds: 220),
);
