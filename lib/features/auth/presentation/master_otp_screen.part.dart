part of '../../../app/komekci_app.dart';

class MasterOtpScreen extends StatefulWidget {
  const MasterOtpScreen({super.key, required this.phone});
  final String phone;

  @override
  State<MasterOtpScreen> createState() => _MasterOtpScreenState();
}

class _MasterOtpScreenState extends State<MasterOtpScreen> {
  final _codeControllers = List.generate(4, (_) => TextEditingController());
  final _codeNodes = List.generate(4, (_) => FocusNode());
  int _secondsLeft = 45;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _codeNodes.first.requestFocus(),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _codeNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _codeReady =>
      _codeControllers.every((controller) => controller.text.isNotEmpty);

  void _startCountdown() {
    setState(() => _secondsLeft = 45);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _resend() {
    context.read<AuthProvider>().sendOtp();
    _startCountdown();
  }

  void _verify() {
    if (!_codeReady) return;
    context.read<AuthProvider>().verifyOtp();
    Navigator.push(context, pageRoute(const MasterRegistrationScreen()));
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
              const _MasterProgressIndicator(step: 2),
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
                        tk: 'Size SMS arkaly iberilen 4 belgili kody giriziň.\n',
                        ru: 'Введите 4-значный код из SMS.\n',
                        en: 'Enter the 4-digit code sent to you by SMS.\n',
                      ),
                    ),
                    TextSpan(
                      text: widget.phone,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) => _codeBox(index, tokens)),
              ),
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
                  Text(
                    '($countdown)',
                    style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _MasterActionButton(
                label: t(tk: 'Tassyklaň', ru: 'Подтвердить', en: 'Verify'),
                enabled: _codeReady,
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

  Widget _codeBox(int index, AppThemeTokens tokens) => SizedBox(
    width: 66,
    height: 92,
    child: TextField(
      controller: _codeControllers[index],
      focusNode: _codeNodes[index],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      onChanged: (value) {
        if (value.isNotEmpty && index < 3) {
          _codeNodes[index + 1].requestFocus();
        } else if (value.isEmpty && index > 0) {
          _codeNodes[index - 1].requestFocus();
        }
        setState(() {});
      },
      decoration: InputDecoration(
        counterText: '',
        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: tokens.accent, width: 1.6),
        ),
      ),
    ),
  );
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

