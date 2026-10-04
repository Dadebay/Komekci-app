part of '../../../app/komekci_app.dart';

/// Six boxes showing a code typed into one hidden text field.
///
/// A single real field (instead of six) is what makes SMS auto-fill,
/// pasting the whole code and the keyboard's "from messages" suggestion work.
class _OtpCodeField extends StatelessWidget {
  const _OtpCodeField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.hasError = false,
    this.enabled = true,
    this.boxHeight = 60,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  static const length = 6;
  final bool hasError;
  final bool enabled;
  final double boxHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      height: boxHeight,
      child: Stack(
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([controller, focusNode]),
            builder: (context, _) {
              final text = controller.text;
              final active = focusNode.hasFocus ? text.length.clamp(0, length - 1) : -1;
              return Row(
                children: [
                  for (var i = 0; i < length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i < text.length ? tokens.surface : tokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: hasError
                                ? tokens.danger
                                : i == active
                                ? tokens.accent
                                : i < text.length
                                ? tokens.textPrimary.withValues(alpha: .35)
                                : tokens.border,
                            width: i == active || hasError ? 1.8 : 1,
                          ),
                        ),
                        child: i < text.length
                            ? Text(
                                text[i],
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                              )
                            : i == active
                            ? Container(width: 2, height: 24, color: tokens.accent)
                            : null,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          // The real input, invisible, covering the boxes.
          Positioned.fill(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              autofocus: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(length),
              ],
              showCursor: false,
              enableSuggestions: false,
              autocorrect: false,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
