part of '../../../app/komekci_app.dart';

/// Step 1 of master sign-up. The number is only carried forward here; the
/// account is created (and the SMS sent) after the profile step.
class MasterPhoneScreen extends StatefulWidget {
  const MasterPhoneScreen({super.key});

  @override
  State<MasterPhoneScreen> createState() => _MasterPhoneScreenState();
}

class _MasterPhoneScreenState extends State<MasterPhoneScreen> {
  final _phoneController = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _phoneReady =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '').length == 8;

  void _continue() {
    if (!_phoneReady) return;
    Navigator.push(
      context,
      pageRoute(MasterRegistrationScreen(phone: toApiPhone(_phoneController.text))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final focused = _focus.hasFocus;
    final ready = _phoneReady;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: _MasterSetupHeader(
        title: t(
          tk: 'MASTER BELLIGI',
          ru: 'РЕГИСТРАЦИЯ МАСТЕРА',
          en: 'MASTER REGISTRATION',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            children: [
              const _MasterProgressIndicator(step: 1),
              const SizedBox(height: 40),
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.surfaceElevated,
                ),
                child: AppIcon(Icons.smartphone_outlined, size: 34, color: tokens.accent),
              ),
              const SizedBox(height: 22),
              Text(
                t(
                  tk: 'Telefon belgiňizi giriziň',
                  ru: 'Введите номер телефона',
                  en: 'Enter your phone number',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t(
                  tk: 'Profiliňizi dolduranyňyzdan soň şu belgä tassyklama kody iberiler.',
                  ru: 'После заполнения профиля на этот номер придёт код подтверждения.',
                  en: "We'll text a verification code to this number once your profile is filled in.",
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, height: 1.45, fontSize: 14),
              ),
              const SizedBox(height: 34),
              // One bordered box holding the prefix and the input, so there is
              // no second border inside the first.
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 64,
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: focused ? tokens.accent : tokens.border,
                    width: focused ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    Text(
                      '+993',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(width: 1, height: 28, color: tokens.border),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        focusNode: _focus,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        inputFormatters: const [_TurkmenPhoneFormatter()],
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _continue(),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .6,
                        ),
                        decoration: InputDecoration(
                          hintText: '65 65 65 65',
                          hintStyle: TextStyle(
                            color: tokens.disabled,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: ready
                          ? Padding(
                              key: const ValueKey('ok'),
                              padding: const EdgeInsets.only(right: 16),
                              child: AppIcon(Icons.check_circle, size: 22, color: tokens.success),
                            )
                          : const SizedBox(key: ValueKey('no'), width: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    ready
                        ? t(tk: 'Belgi dogry görünýär', ru: 'Номер выглядит верно', en: 'Number looks good')
                        : t(tk: '8 sanly belgini giriziň', ru: 'Введите 8 цифр номера', en: 'Enter the 8-digit number'),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: ready ? tokens.success : tokens.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const _PrivacyNote(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
          child: _MasterActionButton(
            label: t(tk: 'Dowam et', ru: 'Продолжить', en: 'Continue'),
            enabled: ready,
            trailingArrow: true,
            onTap: _continue,
          ),
        ),
      ),
    );
  }
}
