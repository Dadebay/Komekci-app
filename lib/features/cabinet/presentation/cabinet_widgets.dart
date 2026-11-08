part of '../../../app/komekci_app.dart';

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _softLine(context.appTokens)),
      ),
      child: AppIcon(icon, color: context.appTokens.textPrimary, size: 19),
    ),
  );
}

/// Balance pill shown in place of the help button on the payment screen.
class _BalanceChip extends StatelessWidget {
  const _BalanceChip();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final balance = context.watch<BillingProvider>().balance;
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tokens.accent.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            Icons.account_balance_wallet_outlined,
            color: tokens.accent,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '$balance ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}


/// Rounded info banner: icon badge on the left, explanatory copy on the right.
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.appTokens.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appTokens.surfaceElevated,
          ),
          child: AppIcon(icon, color: context.appTokens.textPrimary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: context.appTokens.textSecondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

/// One row inside the "Goşmaça sazlamalar" card: icon, title/subtitle, a value and an optional
/// switch and/or chevron. Used for break time, vacation, client buffer and special days.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.showChevron = false,
    this.onTap,
  }) : switchValue = null, onSwitchChanged = null;

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softLine(tokens)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppIcon(icon, color: tokens.accent, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: tokens.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    value!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
                if (switchValue != null) ...[
                  const SizedBox(width: 2),
                  Transform.scale(
                    scale: .82,
                    child: Switch(
                      value: switchValue!,
                      activeThumbColor: tokens.surface,
                      activeTrackColor: tokens.textPrimary,
                      onChanged: onSwitchChanged,
                    ),
                  ),
                ],
                if (showChevron) ...[
                  const SizedBox(width: 2),
                  AppIcon(
                    Icons.chevron_right,
                    color: tokens.textSecondary,
                    size: 17,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Labeled box that opens a picker (time or date) on tap.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.trailingIcon = Icons.expand_more,
  });
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: context.appTokens.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              AppIcon(icon, color: context.appTokens.textPrimary, size: 17),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppIcon(trailingIcon, color: context.appTokens.textSecondary, size: 18),
            ],
          ),
        ),
      ],
    ),
  );
}


/// Rounded checkbox indicator used in the client-picker lists.
