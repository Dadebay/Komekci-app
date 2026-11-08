part of '../../../app/komekci_app.dart';

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.helperText,
    this.errorText,
    this.statusIcon,
    this.footer,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autocorrect = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? statusIcon;
  final Widget? footer;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final int maxLines;
  final int? minLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final hasError = errorText != null;
    final multiline = maxLines > 1;
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
          ),
        ),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autocorrect: autocorrect,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: tokens.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: tokens.disabled, fontWeight: FontWeight.w400),
            // The helper is shown by us below, so the error and the
            // suggestion chips can sit in one column.
            counterStyle: TextStyle(fontSize: 11, color: tokens.textSecondary),
            filled: true,
            fillColor: tokens.surface,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: multiline ? 14 : 15),
            prefixIcon: multiline
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: AppIcon(icon, size: 18, color: hasError ? tokens.danger : tokens.textSecondary),
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: statusIcon == null ? null : Padding(padding: const EdgeInsets.only(right: 14), child: statusIcon),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            enabledBorder: border(hasError ? tokens.danger : tokens.border),
            focusedBorder: border(hasError ? tokens.danger : tokens.accent, 1.5),
            border: border(tokens.border),
          ),
        ),
        if (hasError)
          _FieldError(errorText!)
        else if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(helperText!, style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
          ),
        ?footer,
      ],
    );
  }
}

/// The phone number is changed through an SMS-confirmed dialog, so it is a
/// read-only row with a "Change" action rather than a text field.
class _ProfilePhoneRow extends StatelessWidget {
  const _ProfilePhoneRow({required this.label, required this.action, required this.phone, required this.onTap});

  final String label;
  final String action;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                AppIcon(Icons.phone_outlined, size: 18, color: tokens.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    phone,
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: tokens.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
                  child: Text(
                    action,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Fixed bar under the form: a server error (if any), "Preview" and "Save".
class _ProfileSaveBar extends StatelessWidget {
  const _ProfileSaveBar({required this.error, required this.saving, required this.canSave, required this.previewLabel, required this.saveLabel, required this.onPreview, required this.onSave});

  final String? error;
  final bool saving;
  final bool canSave;
  final String previewLabel;
  final String saveLabel;
  final VoidCallback onPreview;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(top: BorderSide(color: tokens.border)),
        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .05), blurRadius: 14, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.danger.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.danger.withValues(alpha: .35)),
              ),
              child: Row(
                children: [
                  AppIcon(Icons.warning_amber_rounded, size: 16, color: tokens.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(error!, style: TextStyle(fontSize: 12.5, color: tokens.danger)),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: onPreview,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.textPrimary,
                    side: BorderSide(color: tokens.border),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const AppIcon(Icons.remove_red_eye_outlined, size: 18),
                  label: Text(previewLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MasterActionButton(label: saveLabel, enabled: canSave, leading: saving ? null : Icons.save_outlined, onTap: onSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Read-only, client-facing rendering of the profile being edited — lets
/// the master check what a client would see before saving.
