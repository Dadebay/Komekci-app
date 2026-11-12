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
  int _secondsLeft = 0;
  Timer? _resendTimer;

  void _startCountdown(int seconds) {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = seconds);
    if (seconds <= 0) return;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _secondsLeft <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _sms.cancel();
    _resendTimer?.cancel();
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
      if (error is ApiException && error.retryAfterSeconds != null) {
        _startCountdown(error.retryAfterSeconds!);
      }
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _sendCode() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      setState(
        () => _error = AppStrings.profileEnterTheFullNumber8.select(
          context.read<LanguageProvider>().language,
        ),
      );
      return;
    }
    final phone = toApiPhone(digits);
    final auth = context.read<AuthProvider>();
    await _run(() async {
      final retryAfter = await auth.requestPhoneChange(phone);
      if (mounted) {
        setState(() => _newPhone = phone);
        _startCountdown(retryAfter);
      }
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
    _resendTimer?.cancel();
    _codeController.clear();
    setState(() {
      _newPhone = null;
      _error = null;
    });
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final phone = _newPhone!;
    if (_secondsLeft > 0) return;
    await _run(() async {
      final retryAfter = await auth.requestPhoneChange(phone);
      if (mounted) _startCountdown(retryAfter);
    });
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
    final tokens = context.appTokens;
    final awaitingCode = _newPhone != null;
    return AlertDialog(
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        AppStrings.profileChangePhoneNumber.select(language),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            awaitingCode
                ? AppStrings.profileEnterThe6DigitCode(
                    displayPhone(_newPhone!),
                  ).select(language)
                : AppStrings.profileEnterYourNewNumberWe.select(language),
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
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
              style: const TextStyle(
                fontSize: 22,
                letterSpacing: 6,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '000000',
              ),
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
                    child: Text(
                      AppStrings.profileChangeNumber.select(language),
                    ),
                  ),
                  TextButton(
                    onPressed: _busy || _secondsLeft > 0 ? null : _resend,
                    child: Text(
                      _secondsLeft > 0
                          ? '${AppStrings.profileResendCode.select(language)} ($_secondsLeft s)'
                          : AppStrings.profileResendCode.select(language),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(AppStrings.servicesCancel.select(language)),
        ),
        FilledButton(
          onPressed: _busy ? null : (awaitingCode ? _confirm : _sendCode),
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  awaitingCode
                      ? AppStrings.profileConfirm.select(language)
                      : AppStrings.profileSendCode.select(language),
                ),
        ),
      ],
    );
  }
}
