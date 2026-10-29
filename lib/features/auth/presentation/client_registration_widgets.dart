part of '../../../app/komekci_app.dart';

/// Free nickname alternatives offered by the server after `NICKNAME_TAKEN`.
class _NicknameSuggestionChips extends StatelessWidget {
  const _NicknameSuggestionChips({required this.suggestions, required this.onPick});
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tokens.border),
                ),
                child: Text('@$s', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
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
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
        AppIcon(Icons.warning_amber_rounded, size: 13, color: context.appTokens.danger),
        const SizedBox(width: 5),
        Expanded(
          child: Text(message, style: TextStyle(fontSize: 11.5, color: context.appTokens.danger)),
        ),
      ],
    ),
  );
}

/// Shown when sign-up answers `PHONE_TAKEN`. A number belongs to one account,
/// so the way forward is to sign in with it: this requests a sign-in code and
/// opens the code screen. If the server says it has no *active* account for
/// the number, the earlier sign-up was never confirmed (a pending account),
/// which only the backend can clear.
class PhoneTakenNotice extends StatefulWidget {
  const PhoneTakenNotice({super.key, required this.phone});

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
        _message = error is ApiException && error.code == ApiErrors.phoneNotFound
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
    Navigator.push(
      context,
      pageRoute(OtpScreen(phone: widget.phone, nextBuilder: homeForAccount)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
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
              style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder()),
              onPressed: _busy ? null : _signIn,
              child: _busy
                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: tokens.surface))
                  : Text(t(tk: 'Şu belgi bilen giriş', ru: 'Войти по этому номеру', en: 'Sign in with this number')),
            ),
          ),
          if (_message != null) _FieldError(_message!),
        ],
      ),
    );
  }
}
