import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
  });
  final String label;
  final VoidCallback onTap;

  /// Disables the button and swaps the arrow for a spinner while a request runs.
  final bool loading;
  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: t.textPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.only(left: 22, right: 10),
        ),
        onPressed: loading ? null : onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 22),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: t.surface,
              ),
            ),
            CircleAvatar(
              backgroundColor: t.accent,
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: t.accentOn,
                      ),
                    )
                  : AppIcon(Icons.arrow_forward, color: t.accentOn, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
