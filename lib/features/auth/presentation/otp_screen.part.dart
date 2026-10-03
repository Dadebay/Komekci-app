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
  });
  final String phone;
  final Widget Function(Me me) nextBuilder;

  /// Custom resend (used while registering); defaults to a sign-in code.
  final Future<void> Function()? onResend;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 6;
  final _codeControllers = List.generate(_length, (_) => TextEditingController());
  final _codeNodes = List.generate(_length, (_) => FocusNode());
  int _secondsLeft = 60;
  Timer? _timer;
  String? _error;
  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _codeNodes.first.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _codeNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _codeReady => _codeControllers.every((c) => c.text.isNotEmpty);

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
      for (final c in _codeControllers) {
        c.clear();
      }
      _codeNodes.first.requestFocus();
      setState(() => _resending = false);
      _startCountdown();
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

  void _changeNumber() => Navigator.maybePop(context);

  Future<void> _verify() async {
    if (!_codeReady || _verifying) return;
    final code = _codeControllers.map((c) => c.text).join();
    final language = context.read<LanguageProvider>().language;
    final auth = context.read<AuthProvider>();
    setState(() {
      _error = null;
      _verifying = true;
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
    final countdown = '00:${_secondsLeft.toString().padLeft(2, '0')}';
    final tokens = context.appTokens;
    final shownPhone = displayPhone(widget.phone);

    return AppScaffold(
      title: t(tk: 'Belgiňizi tassyklaň', ru: 'Подтвердите номер', en: 'Verify your number'),
      subtitle: t(tk: '$shownPhone belgisine 6 sanly kod iberdik', ru: 'Мы отправили 6-значный код на $shownPhone', en: 'We sent a 6-digit code to $shownPhone'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(_length, (index) => _codeBox(index, tokens))),
          if (_error != null) ...[const SizedBox(height: 10), _FieldError(_error!)],
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                t(tk: 'Kod gelmedi?', ru: 'Код не пришёл?', en: "Didn't get a code?"),
                style: TextStyle(color: tokens.textSecondary, fontSize: 13),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _secondsLeft == 0 ? _resend : null,
                child: Text(
                  t(tk: 'Täzeden iber', ru: 'Отправить снова', en: 'Resend'),
                  style: TextStyle(color: _secondsLeft == 0 ? tokens.accent : tokens.disabled, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 6),
              if (_secondsLeft > 0) Text('($countdown)', style: TextStyle(color: tokens.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _changeNumber,
            child: Text(
              t(tk: 'Belgini üýtgetmek', ru: 'Изменить номер', en: 'Change number'),
              style: TextStyle(color: tokens.textSecondary, fontSize: 13, decoration: TextDecoration.underline),
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: _verifying ? t(tk: 'Barlanýar...', ru: 'Проверка...', en: 'Verifying...') : t(tk: 'Tassykla', ru: 'Подтвердить', en: 'Verify'),
            loading: _verifying,
            onTap: _verify,
          ),
        ],
      ),
    );
  }

  Widget _codeBox(int index, AppThemeTokens tokens) => SizedBox(
    width: 44,
    height: 54,
    child: TextField(
      controller: _codeControllers[index],
      focusNode: _codeNodes[index],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 1,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      onChanged: (value) {
        if (_error != null) setState(() => _error = null);
        if (value.isNotEmpty && index < _length - 1) {
          _codeNodes[index + 1].requestFocus();
        } else if (value.isEmpty && index > 0) {
          _codeNodes[index - 1].requestFocus();
        }
        setState(() {});
        if (_codeReady) _verify();
      },
      decoration: InputDecoration(
        counterText: '',
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: _error != null ? tokens.danger : tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: _error != null ? tokens.danger : tokens.accent, width: 1.6),
        ),
      ),
    ),
  );
}
