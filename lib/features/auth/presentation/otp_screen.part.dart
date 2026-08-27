part of '../../../app/komekci_app.dart';

/// The mock "correct" code — no SMS backend exists, so the flow needs a
/// fixed value to validate against for the wrong-code error path to be real.
const _demoOtpCode = '123456';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.next, this.phone = '+993 61 123456'});
  final Widget next;
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeNodes = List.generate(6, (_) => FocusNode());
  int _secondsLeft = 60;
  Timer? _timer;
  String? _error;
  bool _verifying = false;

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

  void _startCountdown() {
    setState(() => _secondsLeft = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _resend() {
    for (final c in _codeControllers) {
      c.clear();
    }
    setState(() => _error = null);
    _codeNodes.first.requestFocus();
    _startCountdown();
  }

  void _changeNumber() => Navigator.maybePop(context);

  Future<void> _verify(String Function({required String tk, required String ru, required String en}) t) async {
    if (!_codeReady || _verifying) return;
    final code = _codeControllers.map((c) => c.text).join();
    if (code != _demoOtpCode) {
      setState(() => _error = t(tk: 'Kod nädogry. Täzeden synanyşyň.', ru: 'Неверный код. Попробуйте снова.', en: 'Incorrect code. Please try again.'));
      return;
    }
    setState(() {
      _error = null;
      _verifying = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    context.read<AuthProvider>().verifyOtp();
    // Clears the splash/language/role/login/otp stack instead of pushing on
    // top of it, so the signed-in home's tabs correctly report canPop()
    // false (no stray back button) and swiping back can't land on the OTP
    // screen.
    Navigator.of(
      context,
    ).pushAndRemoveUntil(pageRoute(widget.next), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final countdown = '00:${_secondsLeft.toString().padLeft(2, '0')}';
    final tokens = context.appTokens;

    return AppScaffold(
      title: t(tk: 'Belgiňizi tassyklaň', ru: 'Подтвердите номер', en: 'Verify your number'),
      subtitle: t(tk: '${widget.phone} belgisine 6 sanly kod iberdik', ru: 'Мы отправили 6-значный код на ${widget.phone}', en: 'We sent a 6-digit code to ${widget.phone}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (index) => _codeBox(index, tokens))),
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
            onTap: () => _verify(t),
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
      maxLength: 1,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      onChanged: (value) {
        if (_error != null) setState(() => _error = null);
        if (value.isNotEmpty && index < 5) {
          _codeNodes[index + 1].requestFocus();
        } else if (value.isEmpty && index > 0) {
          _codeNodes[index - 1].requestFocus();
        }
        setState(() {});
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

