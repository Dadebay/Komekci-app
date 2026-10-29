part of '../../../app/komekci_app.dart';

class _CheckboxDot extends StatelessWidget {
  const _CheckboxDot({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? tokens.textPrimary : tokens.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? tokens.textPrimary : tokens.border,
          width: 1.6,
        ),
      ),
      child: checked
          ? AppIcon(Icons.check, color: tokens.surface, size: 13)
          : null,
    );
  }
}

/// A single client row with avatar, contact details and a trailing checkbox.
class _ClientListTile extends StatelessWidget {
  const _ClientListTile({
    required this.name,
    required this.phone,
    required this.subtitle,
    required this.checked,
    required this.onTap,
    this.enabled = true,
  });
  final String name;
  final String phone;
  final String subtitle;
  final bool checked;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: checked ? tokens.accent : _softLine(tokens),
            width: checked ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: tokens.accent.withValues(alpha: .2),
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            enabled
                ? _CheckboxDot(checked: checked)
                : AppIcon(Icons.info_outline, color: tokens.textSecondary, size: 19),
          ],
        ),
      ),
    );
  }
}

/// Icon + label + value row used inside the subscription card.
class _SubscriptionDateRow extends StatelessWidget {
  const _SubscriptionDateRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.appTokens.accent.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AppIcon(icon, color: context.appTokens.accent, size: 15),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label,
          style: TextStyle(fontSize: 13, color: context.appTokens.textSecondary),
        ),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
