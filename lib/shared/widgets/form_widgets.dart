import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';
import 'photo_picker.dart';
import 'primary_button.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.titleInAppBar = false,
  });
  final String title;
  final String? subtitle;
  final Widget child;

  /// Puts [title] centred in the app bar and [subtitle] centred under it,
  /// instead of the large left-aligned heading in the body.
  final bool titleInAppBar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: titleInAppBar
          ? Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
          : null,
      leading: IconButton(icon: const AppIcon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: titleInAppBar ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            if (!titleInAppBar)
              Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              SizedBox(height: titleInAppBar ? 0 : 7),
              Text(
                subtitle!,
                textAlign: titleInAppBar ? TextAlign.center : TextAlign.start,
                style: TextStyle(color: context.appTokens.textSecondary),
              ),
            ],
            const SizedBox(height: 18),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

class FormScreen extends StatelessWidget {
  const FormScreen({super.key, required this.title, this.subtitle, required this.fields, required this.action, required this.onAction, this.avatar = false});
  final String title;
  final String? subtitle;
  final List<String> fields;
  final String action;
  final VoidCallback onAction;
  final bool avatar;
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: title,
    subtitle: subtitle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (avatar) ...[
          const SizedBox(height: 14),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xffE6D2B1),
                  child: AppIcon(Icons.person_outline, size: 42, color: context.appTokens.textPrimary),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.appTokens.textPrimary,
                    child: AppIcon(Icons.camera_alt_outlined, size: 16, color: context.appTokens.surface),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
        ],
        ...fields.map(
          (label) => Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Field(label: label),
          ),
        ),
        const Spacer(),
        PrimaryButton(label: action, onTap: onAction),
      ],
    ),
  );
}

class Field extends StatelessWidget {
  const Field({super.key, required this.label, this.icon, this.controller, this.onChanged});
  final String label;
  final IconData? icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: icon == null ? null : AppIcon(icon!, size: 24, color: context.appTokens.textSecondary),
      prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 0),
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),
  );
}

class SelectRow extends StatelessWidget {
  const SelectRow({super.key, required this.flag, required this.label, required this.onTap, this.selected = false});
  final String flag;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? tokens.accent : tokens.border),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontSize: 17)),
            const Spacer(),
            if (selected) AppIcon(Icons.check_circle, color: tokens.accent),
          ],
        ),
      ),
    );
  }
}

/// A master's round photo from the server, or a neutral placeholder.
class MasterAvatar extends StatelessWidget {
  const MasterAvatar({super.key, this.url, this.radius = 27});
  final String? url;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return RoundPhoto(url: url, radius: radius, placeholder: Icons.face_2_outlined);
  }
}

class HeroPhoto extends StatelessWidget {
  const HeroPhoto({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 210,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      image: const DecorationImage(image: AssetImage('assets/images/inspiration_02.jpeg'), fit: BoxFit.cover),
    ),
  );
}

/// "+993" shown at the start of a phone field at all times. `prefixText`
/// only appears once the field is focused or filled, so it is drawn as an
/// icon-slot widget instead.
Widget phonePrefix(BuildContext context, {double fontSize = 16, FontWeight weight = FontWeight.w600}) =>
    Padding(
      padding: const EdgeInsets.only(left: 16, right: 10),
      child: Text(
        '+993',
        style: TextStyle(
          color: context.appTokens.textSecondary,
          fontSize: fontSize,
          fontWeight: weight,
        ),
      ),
    );

const phonePrefixConstraints = BoxConstraints(minWidth: 0, minHeight: 0);

/// Filled, rounded input style shared by the sign-up forms: an optional
/// leading icon (or custom [prefix], e.g. the phone's "+993") and a status
/// [suffix]. [error] switches the border and icon to the danger colour.
InputDecoration registrationDecoration(
  AppThemeTokens tokens, {
  required String hint,
  required IconData icon,
  Widget? prefix,
  Widget? suffix,
  bool error = false,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color, width: width),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: tokens.disabled, fontWeight: FontWeight.w400),
    filled: true,
    fillColor: tokens.surfaceElevated,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    prefixIcon: prefix ??
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: AppIcon(icon, size: 20, color: error ? tokens.danger : tokens.textSecondary),
        ),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    suffixIcon: suffix == null ? null : Padding(padding: const EdgeInsets.only(right: 14), child: suffix),
    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    enabledBorder: border(error ? tokens.danger : tokens.border),
    focusedBorder: border(error ? tokens.danger : tokens.accent, 1.5),
  );
}
