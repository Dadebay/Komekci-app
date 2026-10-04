part of '../../../app/komekci_app.dart';

/// Step 3 of master sign-up: confirms the SMS code sent by
/// `POST /auth/register`. A verified code signs the account in and moves on
/// to the subscription payment.
class MasterOtpScreen extends StatefulWidget {
  const MasterOtpScreen({
    super.key,
    required this.phone,
    this.registration,
    this.smsListener = const SmsCodeListener(),
  });

  /// `+993XXXXXXXX`.
  final String phone;

  /// What was submitted, kept so "resend" can fall back to registering again
  /// if the server does not yet treat the pending account as signed-up.
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
    _startCountdown();
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
    if (_resending) return;
    final auth = context.read<AuthProvider>();
    final language = context.read<LanguageProvider>().language;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      try {
        await auth.requestOtp(widget.phone);
      } on ApiException catch (e) {
        // A pending (not yet verified) account may not count as "active" for
        // the sign-in code endpoint; registering again re-sends the code.
        if (e.code == ApiErrors.phoneNotFound && widget.registration != null) {
          await auth.register(widget.registration!);
        } else {
          rethrow;
        }
      }
      if (!mounted) return;
      _code.clear();
      _focus.requestFocus();
      setState(() => _resending = false);
      _startCountdown();
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
    try {
      await auth.verifyOtp(widget.phone, code);
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
    Navigator.of(context).pushAndRemoveUntil(
      pageRoute(const MasterSubscriptionScreen()),
      (_) => false,
    );
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
                      style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                    ),
                ],
              ),
              const SizedBox(height: 26),
              _MasterActionButton(
                label: _verifying
                    ? t(tk: 'Barlanýar...', ru: 'Проверка...', en: 'Verifying...')
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

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.surfaceElevated,
          ),
          child: AppIcon(Icons.lock_outline, color: tokens.accent, size: 15),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            pickTr(
              language,
              tk: 'Siziň maglumatlaryňyz ygtybarly saklanýar we üçünji taraplar bilen paýlaşylmaýar.',
              ru: 'Ваши данные хранятся надёжно и не передаются третьим лицам.',
              en: 'Your data is stored securely and never shared with third parties.',
            ),
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

