part of '../../../app/komekci_app.dart';

/// Step 3 of master sign-up: confirms the SMS code sent by
/// `POST /auth/register`. A verified code signs the account in; the entry
/// gate decides whether payment is still needed.
class MasterOtpScreen extends StatefulWidget {
  const MasterOtpScreen({
    super.key,
    required this.phone,
    this.registration,
    this.smsListener = const SmsCodeListener(),
  });

  /// `+993XXXXXXXX`.
  final String phone;

  /// What was submitted, reused for a single registration resend request.
  final RegistrationData? registration;

  /// Fills the code in from the incoming SMS (Android).
  final SmsCodeListener smsListener;

  @override
  State<MasterOtpScreen> createState() => _MasterOtpScreenState();
}

class _MasterOtpScreenState extends State<MasterOtpScreen> {
  static const _length = 6;
  final _code = TextEditingController();
  final _focus = FocusNode();
  int _secondsLeft = 60;
  Timer? _resendTimer;
  String? _error;
  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown(context.read<AuthProvider>().lastOtpRetryAfter);
    _listenForSms();
  }

  /// Waits for the SMS and, when it arrives, types the code and submits it.
  Future<void> _listenForSms() async {
    final code = await widget.smsListener.listen();
    if (!mounted || code == null || _verifying) return;
    _code.text = code;
    if (_codeReady) _verify();
  }

  @override
  void dispose() {
    widget.smsListener.cancel();
    _resendTimer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _codeReady => _code.text.length == _length;

  void _startCountdown([int seconds = 60]) {
    setState(() => _secondsLeft = seconds);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _resend() async {
    if (_resending || _secondsLeft > 0) return;
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      if (widget.registration case final registration?) {
        await auth.register(registration);
      } else {
        await auth.requestOtp(widget.phone);
      }
      if (!mounted) return;
      _code.clear();
      _focus.requestFocus();
      setState(() => _resending = false);
      _startCountdown(auth.lastOtpRetryAfter);
      widget.smsListener.cancel().then((_) => _listenForSms());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _error = apiErrorMessage(error, language);
      });
      if (error is ApiException && error.retryAfterSeconds != null) {
        _startCountdown(error.retryAfterSeconds!);
      }
    }
  }

  Future<void> _verify() async {
    if (!_codeReady || _verifying) return;
    final code = _code.text;
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _verifying = true;
      _error = null;
    });
    final Me me;
    try {
      me = await auth.verifyOtp(widget.phone, code);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = apiErrorMessage(error, language);
      });
      _code.clear();
      _focus.requestFocus();
      return;
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushAndRemoveUntil(pageRoute(homeForAccount(me)), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final countdown =
        '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: _MasterSetupHeader(
        title: t(tk: 'TASSYKLAMA', ru: 'ПОДТВЕРЖДЕНИЕ', en: 'VERIFICATION'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MasterProgressIndicator(step: 3),
              const SizedBox(height: 34),
              Text(
                t(
                  tk: 'Telefon belgiňizi tassyklaň',
                  ru: 'Подтвердите номер телефона',
                  en: 'Verify your phone number',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: tokens.textSecondary,
                    height: 1.45,
                    fontFamily: 'Gilroy',
                  ),
                  children: [
                    TextSpan(
                      text: t(
                        tk: 'Size SMS arkaly iberilen 6 belgili kody giriziň.\n',
                        ru: 'Введите 6-значный код из SMS.\n',
                        en: 'Enter the 6-digit code sent to you by SMS.\n',
                      ),
                    ),
                    TextSpan(
                      text: displayPhone(widget.phone),
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _OtpCodeField(
                controller: _code,
                focusNode: _focus,
                hasError: _error != null,
                enabled: !_verifying,
                boxHeight: 64,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                  if (_codeReady) _verify();
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                _FieldError(_error!),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    t(
                      tk: 'Kod gelmedi?',
                      ru: 'Код не пришёл?',
                      en: "Didn't get a code?",
                    ),
                    style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _secondsLeft == 0 ? _resend : null,
                    child: Text(
                      t(
                        tk: 'Kody täzeden iber',
                        ru: 'Отправить снова',
                        en: 'Resend',
                      ),
                      style: TextStyle(
                        color: _secondsLeft == 0
                            ? tokens.accent
                            : tokens.disabled,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (_secondsLeft > 0)
                    Text(
                      '($countdown)',
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 26),
              MasterActionButton(
                label: _verifying
                    ? t(
                        tk: 'Barlanýar...',
                        ru: 'Проверка...',
                        en: 'Verifying...',
                      )
                    : t(tk: 'Tassyklaň', ru: 'Подтвердить', en: 'Verify'),
                enabled: _codeReady && !_verifying,
                onTap: _verify,
              ),
              const SizedBox(height: 26),
              const _PrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }
}
