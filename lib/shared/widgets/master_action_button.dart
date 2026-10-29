import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';

/// Shared primary action for the master flow and dashboard forms.
class MasterActionButton extends StatelessWidget {
  const MasterActionButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.trailingArrow = false,
    this.leading,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool trailingArrow;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: enabled
              ? tokens.textPrimary
              : tokens.surfaceElevated,
          foregroundColor: enabled ? tokens.surface : tokens.disabled,
          disabledBackgroundColor: tokens.surfaceElevated,
          disabledForegroundColor: tokens.disabled,
          side: enabled ? BorderSide.none : BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: enabled ? onTap : null,
        child: Row(
          mainAxisAlignment: trailingArrow
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (trailingArrow) const SizedBox(width: 20),
            if (leading != null) ...[
              AppIcon(
                leading!,
                color: enabled ? tokens.surface : tokens.disabled,
                size: 19,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingArrow) const AppIcon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
