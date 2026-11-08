import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';

const freeSlotColorDark = Color(0xff1F8A4C);
const freeSlotBg = Color(0xffEFFAF3);

Color freeSlotSurface(AppThemeTokens tokens) =>
    tokens.brightness == Brightness.dark
    ? Color.alphaBlend(
        tokens.success.withValues(alpha: .14),
        tokens.surfaceElevated,
      )
    : freeSlotBg;

Color freeSlotForeground(AppThemeTokens tokens) =>
    tokens.brightness == Brightness.dark ? tokens.success : freeSlotColorDark;
