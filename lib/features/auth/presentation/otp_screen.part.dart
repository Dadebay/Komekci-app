part of '../../../app/komekci_app.dart';

/// Six-digit SMS code entry, shared by sign-in and the client sign-up.
///
/// [phone] is the API form (`+993XXXXXXXX`). On success the account is loaded
/// and [nextBuilder] decides where to go; the whole stack is replaced so back
/// can't return to the code screen.
class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.nextBuilder,
    this.onResend,
    this.smsListener = const SmsCodeListener(),
  });
  final String phone;
  final Widget Function(Me me) nextBuilder;

  /// Custom resend (used while registering); defaults to a sign-in code.
  final Future<void> Function()? onResend;

  /// Fills the code in from the incoming SMS (Android).
  final SmsCodeListener smsListener;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 6;
  final _code = TextEditingController();
  final _focus = FocusNode();
  int _secondsLeft = 60;
  Timer? _timer;
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
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _codeReady => _code.text.length == _length;

  void _startCountdown([int seconds = 60]) {
    setState(() => _secondsLeft = seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _resend() async {
    if (_resending) return;
    final language = context.read<LanguageProvider>().language;
    final auth = context.read<AuthProvider>();
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await (widget.onResend ?? () => auth.requestOtp(widget.phone))();
      if (!mounted) return;
      _code.clear();
      _focus.requestFocus();
      setState(() => _resending = false);
      _startCountdown();
      // A new SMS is on its way: listen for it.
      widget.smsListener.cancel().then((_) => _listenForSms());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _error = apiErrorMessage(error, language);
      });
      // The server may say how long to wait before another code.
      if (error is ApiException && error.retryAfterSeconds != null) {
        _startCountdown(error.retryAfterSeconds!);
      }
    }
  }

  Future<void> _verify() async {
    if (!_codeReady || _verifying) return;
    final language = context.read<LanguageProvider>().language;
    final auth = context.read<AuthProvider>();
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _verifying = true;
    });
    final Me me;
    try {
      me = await auth.verifyOtp(widget.phone, _code.text);
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
    // Clears the splash/language/role/login/otp stack instead of pushing on
    // top of it, so the signed-in home's tabs correctly report canPop()
    // false (no stray back button) and swiping back can't land on the OTP
    // screen.
    Navigator.of(context).pushAndRemoveUntil(pageRoute(widget.nextBuilder(me)), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final shownPhone = displayPhone(widget.phone);
    final countdown = '00:${_secondsLeft.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        leading: IconButton(icon: const AppIcon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              AppIcon(Icons.sms_outlined, size: 72, color: tokens.accent),
              const SizedBox(height: 18),
              Text(
                t(tk: 'Belgiňizi tassyklaň', ru: 'Подтвердите номер', en: 'Verify your number'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -.3),
              ),
              const SizedBox(height: 10),
              Text(
                t(tk: '6 sanly kody şu belgä iberdik', ru: 'Мы отправили 6-значный код на номер', en: 'We sent a 6-digit code to'),
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 4),
              Text(
                shownPhone,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: .3),
              ),
              TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: Text(
                  t(tk: 'Belgini üýtgetmek', ru: 'Изменить номер', en: 'Change number'),
                  style: TextStyle(color: tokens.accent, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 18),
              _OtpCodeField(
                controller: _code,
                focusNode: _focus,
                hasError: _error != null,
                enabled: !_verifying,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                  if (_codeReady) _verify();
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(Icons.error_outline, size: 15, color: tokens.danger),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: tokens.danger),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              if (_secondsLeft > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t(
                      tk: 'Kody täzeden ibermek: $countdown',
                      ru: 'Отправить код повторно: $countdown',
                      en: 'Resend code in $countdown',
                    ),
                    style: TextStyle(fontSize: 12.5, color: tokens.textSecondary, fontWeight: FontWeight.w600),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: _resending ? null : _resend,
                  icon: AppIcon(Icons.refresh, size: 18, color: tokens.accent),
                  label: Text(
                    _resending
                        ? t(tk: 'Iberilýär...', ru: 'Отправка...', en: 'Sending...')
                        : t(tk: 'Kody täzeden iber', ru: 'Отправить код снова', en: 'Resend code'),
                    style: TextStyle(color: tokens.accent, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
      ),
      // Sits above the keyboard (the scaffold resizes for it), so the page
      // body scrolls instead of overflowing.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
          child: PrimaryButton(
            label: _verifying
                ? t(tk: 'Barlanýar...', ru: 'Проверка...', en: 'Verifying...')
                : t(tk: 'Tassykla', ru: 'Подтвердить', en: 'Verify'),
            loading: _verifying,
            onTap: _codeReady ? _verify : () => _focus.requestFocus(),
          ),
        ),
      ),
    );
  }
}
