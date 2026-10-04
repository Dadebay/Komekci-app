part of '../../../app/komekci_app.dart';

/// Two-step phone change: new number → SMS code. Resolves true when the
/// account now carries the new number.
Future<bool> showChangePhoneDialog(BuildContext context) async {
  final changed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ChangePhoneDialog(),
  );
  return changed ?? false;
}

class _ChangePhoneDialog extends StatefulWidget {
  const _ChangePhoneDialog();
  @override
  State<_ChangePhoneDialog> createState() => _ChangePhoneDialogState();
}

class _ChangePhoneDialogState extends State<_ChangePhoneDialog> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _sms = const SmsCodeListener();
  String? _newPhone;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _sms.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = apiErrorMessage(error, language);
      });
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _sendCode() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      setState(() => _error = pickTr(
        context.read<LanguageProvider>().language,
        tk: 'Telefon belgini dolduryň (8 san)',
        ru: 'Введите номер полностью (8 цифр)',
        en: 'Enter the full number (8 digits)',
      ));
      return;
    }
    final phone = toApiPhone(digits);
    final auth = context.read<AuthProvider>();
    await _run(() async {
      await auth.requestPhoneChange(phone);
      if (mounted) setState(() => _newPhone = phone);
    });
    if (_newPhone != null) _listenForSms();
  }

  /// Android: fills in and submits the code from the incoming SMS.
  Future<void> _listenForSms() async {
    await _sms.cancel();
    final code = await _sms.listen();
    if (!mounted || code == null || _newPhone == null || _busy) return;
    _codeController.text = code;
    _confirm();
  }

  /// Back to the number field (typed it wrong).
  void _editNumber() {
    _sms.cancel();
    _codeController.clear();
    setState(() {
      _newPhone = null;
      _error = null;
    });
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final phone = _newPhone!;
    await _run(() => auth.requestPhoneChange(phone));
    if (mounted && _error == null) _listenForSms();
  }

  Future<void> _confirm() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;
    final auth = context.read<AuthProvider>();
    final phone = _newPhone!;
    await _run(() async {
      await auth.confirmPhoneChange(phone, code);
      if (mounted) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final awaitingCode = _newPhone != null;
    return AlertDialog(
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        t(tk: 'Telefon belgisini üýtgetmek', ru: 'Смена номера', en: 'Change phone number'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            awaitingCode
                ? t(
                    tk: '${displayPhone(_newPhone!)} belgisine iberilen 6 sanly kody giriziň.',
                    ru: 'Введите 6-значный код, отправленный на ${displayPhone(_newPhone!)}.',
                    en: 'Enter the 6-digit code sent to ${displayPhone(_newPhone!)}.',
                  )
                : t(
                    tk: 'Täze belgiňizi giriziň. Oňa tassyklama kody iberiler.',
                    ru: 'Введите новый номер. На него придёт код подтверждения.',
                    en: "Enter your new number. We'll text it a confirmation code.",
                  ),
            style: TextStyle(color: tokens.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          if (awaitingCode)
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
              onChanged: (value) {
                if (value.length == 6) _confirm();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(counterText: '', hintText: '000000'),
            )
          else
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [_PhoneNumberFormatter()],
              decoration: InputDecoration(
                prefixIcon: phonePrefix(context),
                prefixIconConstraints: phonePrefixConstraints,
                hintText: '65 123456',
              ),
            ),
          if (_error != null) _FieldError(_error!),
          if (awaitingCode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: _busy ? null : _editNumber,
                    child: Text(t(tk: 'Belgini üýtget', ru: 'Изменить номер', en: 'Change number')),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _resend,
                    child: Text(t(tk: 'Kody täzeden iber', ru: 'Отправить код снова', en: 'Resend code')),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel')),
        ),
        FilledButton(
          onPressed: _busy ? null : (awaitingCode ? _confirm : _sendCode),
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(awaitingCode
                    ? t(tk: 'Tassykla', ru: 'Подтвердить', en: 'Confirm')
                    : t(tk: 'Kod iber', ru: 'Отправить код', en: 'Send code')),
        ),
      ],
    );
  }
}
