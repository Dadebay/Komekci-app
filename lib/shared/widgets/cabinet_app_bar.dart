import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';

/// Shared header used across cabinet/customer/schedule/booking destinations.
class CabinetAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CabinetAppBar({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    // Reused as a tab root, where there is nothing to pop back to.
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      toolbarHeight: 52,
      elevation: 0,
      centerTitle: true,

      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: AppIcon(Icons.arrow_back, color: context.appTokens.textPrimary, size: 20),
            )
          : null,
      title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      actions: [if (action != null) Padding(padding: const EdgeInsets.only(right: 12), child: action!)],
    );
  }
}

class IconActionButton extends StatelessWidget {
  const IconActionButton({super.key, required this.icon, required this.onTap, this.filled = false, this.bare = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  /// Icon only, no circular background/border — used where the app bar
  /// action should sit flush against the title row instead of as a badge.
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    if (bare) {
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(width: 46, height: 46, child: AppIcon(icon, color: filled ? tokens.accent : tokens.textPrimary, size: 21)),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? tokens.textPrimary : tokens.surfaceElevated,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: tokens.border),
        ),
        child: AppIcon(icon, color: filled ? tokens.surface : tokens.textPrimary, size: 19),
      ),
    );
  }
}
