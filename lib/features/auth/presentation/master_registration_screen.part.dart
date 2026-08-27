part of '../../../app/komekci_app.dart';

class MasterRegistrationScreen extends StatefulWidget {
  const MasterRegistrationScreen({super.key});

  @override
  State<MasterRegistrationScreen> createState() =>
      _MasterRegistrationScreenState();
}

class _MasterRegistrationScreenState extends State<MasterRegistrationScreen> {
  /// Every field except the last (social links) has to be filled before the
  /// master can move on to payment.
  static const _optionalIndex = 4;
  static const _nicknameIndex = 1;
  static const _icons = [
    Icons.person_outline,
    Icons.account_box_outlined,
    Icons.location_on_outlined,
    Icons.edit_outlined,
    Icons.link_outlined,
  ];

  final _controllers = List.generate(5, (_) => TextEditingController());
  bool _showErrors = false;
  File? _photo;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _missing(int index) =>
      index != _optionalIndex && _controllers[index].text.trim().isEmpty;

  /// Simulates the server-side uniqueness check a real signup would run —
  /// reuses the same taken-nickname mock list the client registration form
  /// checks against, since both roles would share one nickname namespace.
  bool get _nicknameTaken => takenNicknames.contains(
    _controllers[_nicknameIndex].text.trim().toLowerCase().replaceFirst(
      '@',
      '',
    ),
  );

  bool get _complete =>
      !List.generate(_controllers.length, _missing).contains(true) &&
      !_nicknameTaken;

  void _continue() {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    Navigator.push(context, pageRoute(const MasterSubscriptionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final fields = switch (language) {
      AppLanguage.tk => const [
        'Adyňyz',
        '@ lakamyňyz',
        'Iş salgyňyz',
        'Özüňiz barada',
        'Instagram / TikTok (islege görä)',
      ],
      AppLanguage.ru => const [
        'Имя',
        '@ никнейм',
        'Рабочий адрес',
        'Описание',
        'Instagram / TikTok (необязательно)',
      ],
      AppLanguage.en => const [
        'Your name',
        '@ nickname',
        'Work address',
        'About you',
        'Instagram / TikTok (optional)',
      ],
    };
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: _MasterSetupHeader(
        title: t(
          tk: 'MASTER HASABY',
          ru: 'ПРОФИЛЬ МАСТЕРА',
          en: 'MASTER PROFILE',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              const _MasterProgressIndicator(step: 3),
              const SizedBox(height: 30),
              SizedBox(
                width: 158,
                child: PhotoUploadBox(
                  file: _photo,
                  onPicked: (file) => setState(() => _photo = file),
                  title: t(
                    tk: 'Profil suraty',
                    ru: 'Фото профиля',
                    en: 'Profile photo',
                  ),
                  height: 128,
                  radius: 35,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(fields.length, (index) {
                final nicknameTaken = index == _nicknameIndex && _nicknameTaken;
                final invalid =
                    (_showErrors && _missing(index)) || nicknameTaken;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _controllers[index],
                    onChanged: (_) => setState(() {}),
                    maxLines: index == 3 ? 3 : 1,
                    decoration: InputDecoration(
                      hintText: fields[index],
                      hintStyle: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 14,
                      ),
                      errorText: nicknameTaken
                          ? t(
                              tk: 'Bu lakam eýesiz däl',
                              ru: 'Этот никнейм уже занят',
                              en: 'This nickname is taken',
                            )
                          : (_showErrors && _missing(index))
                          ? t(
                              tk: 'Bu meýdan hökmany',
                              ru: 'Обязательное поле',
                              en: 'This field is required',
                            )
                          : null,
                      errorStyle: const TextStyle(fontSize: 11.5),
                      prefixIconConstraints: const BoxConstraints.tightFor(
                        width: 44,
                        height: 44,
                      ),
                      prefixIcon: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: AppIcon(
                            _icons[index],
                            color: invalid ? tokens.danger : tokens.textPrimary,
                            size: 19,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: tokens.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 17,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: tokens.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: tokens.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: tokens.accent,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: tokens.danger),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: tokens.danger,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _complete ? 0 : 1,
                child: Text(
                  t(
                    tk: 'Töleg sahypasyna geçmek üçin ähli hökmany meýdanlary dolduryň.',
                    ru: 'Заполните обязательные поля, чтобы перейти к оплате.',
                    en: 'Fill in all required fields to continue to payment.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              RoleContinueButton(
                label: t(tk: 'Dowam et', ru: 'Продолжить', en: 'Continue'),
                fillFraction: .70,
                enabled: _complete,
                onTap: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

