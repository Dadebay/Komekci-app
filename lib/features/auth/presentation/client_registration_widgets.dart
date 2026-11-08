part of '../../../app/komekci_app.dart';

/// Free nickname alternatives offered by the server after `NICKNAME_TAKEN`.
class _NicknameSuggestionChips extends StatelessWidget {
  const _NicknameSuggestionChips({
    required this.suggestions,
    required this.onPick,
  });
  final List<String> suggestions;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in suggestions)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onPick(s),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tokens.border),
                ),
                child: Text(
                  '@$s',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Formats raw digit input as `XX XXXXXX` (max 8 digits) as the user types,
/// so the phone field reads like `+993 XX XXXXXX` end to end.
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final allDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = allDigits.length > 8 ? allDigits.substring(0, 8) : allDigits;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 4),
    child: Row(
      children: [
        AppIcon(
          Icons.warning_amber_rounded,
          size: 13,
          color: context.appTokens.danger,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            message,
            style: TextStyle(fontSize: 11.5, color: context.appTokens.danger),
          ),
        ),
      ],
    ),
  );
}

/// Pop-up version of [PhoneTakenNotice], so the message is not left below
/// the fold of a long form.
Future<void> showPhoneTakenDialog(BuildContext context, String phone) {
  return showDialog<void>(
    context: context,
    barrierColor: context.appTokens.scrim,
    builder: (dialogContext) => _PhoneTakenDialog(phone: phone),
  );
}

class _PhoneTakenDialog extends StatefulWidget {
  const _PhoneTakenDialog({required this.phone});
  final String phone;

  @override
  State<_PhoneTakenDialog> createState() => _PhoneTakenDialogState();
}

class _PhoneTakenDialogState extends State<_PhoneTakenDialog> {
  bool _busy = false;
  String? _message;

  Future<void> _signIn() async {
    if (_busy) return;
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>().language;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await auth.requestOtp(widget.phone);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message =
            error is ApiException && error.code == ApiErrors.phoneNotFound
            ? pickTr(
                language,
                tk: 'Bu belgi bilen hasap açylypdyr, ýöne tassyklanmandyr. Goldaw bilen habarlaşyň.',
                ru: 'Аккаунт с этим номером создан, но не подтверждён. Обратитесь в поддержку.',
                en: 'An account with this number was started but never confirmed. Please contact support.',
              )
            : apiErrorMessage(error, language);
      });
      return;
    }
    if (!mounted) return;
    navigator.pop();
    navigator.push(
      pageRoute(OtpScreen(phone: widget.phone, nextBuilder: homeForAccount)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                Icons.person_outline_rounded,
                size: 28,
                color: tokens.accent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              t(
                tk: 'Bu belgi eýýäm hasaba alnypdyr',
                ru: 'Этот номер уже зарегистрирован',
                en: 'This number is already registered',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: tokens.border),
              ),
              child: Text(
                displayPhone(widget.phone),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t(
                tk: 'Täze hasap açmak mümkin däl. Şol hasaba SMS kod bilen girip bilersiňiz.',
                ru: 'Создать новый аккаунт нельзя. Вы можете войти в существующий по SMS-коду.',
                en: 'A new account cannot be created. You can sign in to the existing one with an SMS code.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: tokens.textSecondary,
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xffC0392B),
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.textPrimary,
                  shape: const StadiumBorder(),
                ),
                onPressed: _busy ? null : _signIn,
                child: _busy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: tokens.surface,
                        ),
                      )
                    : Text(
                        t(
                          tk: 'Şu belgi bilen giriş',
                          ru: 'Войти по этому номеру',
                          en: 'Sign in with this number',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: tokens.surface,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: Text(
                t(
                  tk: 'Başga belgi ulan',
                  ru: 'Другой номер',
                  en: 'Use another number',
                ),
                style: TextStyle(color: tokens.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when sign-up answers `PHONE_TAKEN`. A number belongs to one account,
/// so the way forward is to sign in with it: this requests a sign-in code and
/// opens the code screen. If the server says it has no *active* account for
/// the number, the earlier sign-up was never confirmed (a pending account),
/// which only the backend can clear.
class PhoneTakenNotice extends StatefulWidget {
  const PhoneTakenNotice({super.key, required this.phone, this.beforeSignIn});

  /// Runs right before the code screen opens (e.g. to close a dialog).
  final VoidCallback? beforeSignIn;

  /// `+993XXXXXXXX`.
  final String phone;

  @override
  State<PhoneTakenNotice> createState() => _PhoneTakenNoticeState();
}

class _PhoneTakenNoticeState extends State<PhoneTakenNotice> {
  bool _busy = false;
  String? _message;

  Future<void> _signIn() async {
    if (_busy) return;
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await auth.requestOtp(widget.phone);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message =
            error is ApiException && error.code == ApiErrors.phoneNotFound
            ? pickTr(
                language,
                tk: 'Bu belgi bilen hasap açylypdyr, ýöne tassyklanmandyr. Goldaw bilen habarlaşyň.',
                ru: 'Аккаунт с этим номером создан, но не подтверждён. Обратитесь в поддержку.',
                en: 'An account with this number was started but never confirmed. Please contact support.',
              )
            : apiErrorMessage(error, language);
      });
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    widget.beforeSignIn?.call();
    Navigator.push(
      context,
      pageRoute(OtpScreen(phone: widget.phone, nextBuilder: homeForAccount)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(
              tk: 'Bu belgi bilen hasap eýýäm bar. Şol hasaba girip bilersiňiz.',
              ru: 'С этим номером уже есть аккаунт. Вы можете войти в него.',
              en: 'An account with this number already exists. You can sign in to it.',
            ),
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.textPrimary,
                shape: const StadiumBorder(),
              ),
              onPressed: _busy ? null : _signIn,
              child: _busy
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: tokens.surface,
                      ),
                    )
                  : Text(
                      t(
                        tk: 'Şu belgi bilen giriş',
                        ru: 'Войти по этому номеру',
                        en: 'Sign in with this number',
                      ),
                    ),
            ),
          ),
          if (_message != null) _FieldError(_message!),
        ],
      ),
    );
  }
}
