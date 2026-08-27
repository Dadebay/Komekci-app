import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';
import 'primary_button.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(icon: const AppIcon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[const SizedBox(height: 7), Text(subtitle!, style: TextStyle(color: context.appTokens.textSecondary))],
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

class MasterPreviewCard extends StatelessWidget {
  const MasterPreviewCard({super.key});
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: const Color(0xffE6D2B1),
            child: AppIcon(Icons.face_2_outlined, color: tokens.textPrimary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aida Saparova', style: TextStyle(fontSize: 17)),
                SizedBox(height: 3),
                Text('@aida_style · Ashgabat', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          AppIcon(Icons.chevron_right),
        ],
      ),
    );
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
