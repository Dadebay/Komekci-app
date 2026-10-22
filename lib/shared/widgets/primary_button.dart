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
    final textColouredButton = t.button == t.textPrimary;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: t.button,
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
                color: t.buttonText,
              ),
            ),
            CircleAvatar(
              backgroundColor: textColouredButton
                  ? t.accent
                  : t.buttonText.withValues(alpha: .18),
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: t.buttonText,
                      ),
                    )
                  : AppIcon(Icons.arrow_forward, color: t.buttonText, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
