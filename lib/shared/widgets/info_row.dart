import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.text, this.status});
  final String text;
  final String? status;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffE6D2B1),
            child: AppIcon(Icons.person_outline, color: tokens.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          if (status != null) StatusChip(label: status!),
          const AppIcon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final late = label.startsWith('Late');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: late ? const Color(0xffFBE3E0) : const Color(0xffFBF1D8),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: late ? Colors.deepOrange : const Color(0xff77540E),
        ),
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: const AppIcon(Icons.chevron_right),
  );
}
