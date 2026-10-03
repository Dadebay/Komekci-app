part of '../../../app/komekci_app.dart';

class MasterPhoneScreen extends StatefulWidget {
  const MasterPhoneScreen({super.key});

  @override
  State<MasterPhoneScreen> createState() => _MasterPhoneScreenState();
}

class _MasterPhoneScreenState extends State<MasterPhoneScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _phoneReady =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '').length == 8;

  /// The account is created (and the SMS sent) only after the profile step,
  /// so this just carries the number forward.
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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MasterProgressIndicator(step: 1),
              const SizedBox(height: 34),
              Text(
                t(
                  tk: 'Telefon belgiňizi giriziň',
                  ru: 'Введите номер телефона',
                  en: 'Enter your phone number',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t(
                  tk: 'Profilni dolduranyňyzdan soň belgiňize tassyklama kody iberiler.',
                  ru: 'После заполнения профиля на ваш номер придёт код подтверждения.',
                  en: "We'll send a verification code once your profile is filled in.",
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 30),
              Text(
                t(
                  tk: 'Telefon belgiňiz',
                  ru: 'Номер телефона',
                  en: 'Phone number',
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: tokens.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 72,
                      child: Center(
                        child: Text(
                          '+993',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 30, color: tokens.border),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: const [_TurkmenPhoneFormatter()],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '65 123456',
                          hintStyle: TextStyle(
                            color: tokens.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t(
                  tk: 'Dogry telefon belgiňizi giriziň.',
                  ru: 'Введите корректный номер телефона.',
                  en: 'Enter a valid phone number.',
                ),
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 26),
              _MasterActionButton(
                label: t(tk: 'Dowam et', ru: 'Продолжить', en: 'Continue'),
                enabled: _phoneReady,
                onTap: _continue,
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

