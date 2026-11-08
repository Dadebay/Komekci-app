part of '../../../app/komekci_app.dart';

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false, this.optionalLabel});
  final String text;
  final bool required;
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      if (required)
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '*',
            style: TextStyle(fontSize: 14, color: Color(0xffC0392B), fontWeight: FontWeight.w700),
          ),
        ),
      if (optionalLabel != null)
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(optionalLabel!, style: TextStyle(fontSize: 12.5, color: context.appTokens.textSecondary)),
        ),
    ],
  );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.language});
  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 7, left: 4),
    child: Text(pickTr(language, tk: 'Bu meýdan hökmany', ru: 'Обязательное поле', en: 'Required field'), style: const TextStyle(fontSize: 11.5, color: Color(0xffC0392B))),
  );
}

class _FormField extends StatelessWidget {
  const _FormField({required this.controller, required this.hint, required this.onChanged, this.maxLines = 1, this.maxLength, this.keyboardType, this.textInputAction, this.onSubmitted, this.inputFormatters, this.prefixIcon, this.invalid = false, this.enabled = true, this.fillColor});

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final bool invalid;
  final bool enabled;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      onChanged: (_) => onChanged(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon,
        prefixIconConstraints: prefixIcon == null ? null : phonePrefixConstraints,
        hintStyle: TextStyle(color: tokens.textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
        errorText: invalid ? pickTr(language, tk: 'Bu meýdan hökmany', ru: 'Обязательное поле', en: 'This field is required') : null,
        errorStyle: const TextStyle(fontSize: 11.5),
        counterStyle: TextStyle(fontSize: 11, color: tokens.textSecondary),
        filled: true,
        fillColor: fillColor ?? tokens.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tokens.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffC0392B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffC0392B), width: 1.5),
        ),
      ),
    );
  }
}
