import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';

/// Compact help action used in cabinet page headers.
class AppHelpButton extends StatelessWidget {
  const AppHelpButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: tokens.border.withValues(alpha: .55)),
        ),
        child: AppIcon(Icons.help_outline, color: tokens.textPrimary, size: 16),
      ),
    );
  }
}
