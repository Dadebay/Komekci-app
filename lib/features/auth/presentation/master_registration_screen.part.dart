part of '../../../app/komekci_app.dart';

/// Step 2 of master sign-up. Submitting creates the account on the server
/// (`POST /auth/register`), which sends the SMS code for step 3.
class MasterRegistrationScreen extends StatefulWidget {
  const MasterRegistrationScreen({super.key, required this.phone});

  /// `+993XXXXXXXX`, collected on the previous step.
  final String phone;

  @override
  State<MasterRegistrationScreen> createState() =>
      _MasterRegistrationScreenState();
}

class _MasterRegistrationScreenState extends State<MasterRegistrationScreen> {
  static const _nameIndex = 0;
  static const _nicknameIndex = 1;
  static const _addressIndex = 2;
  static const _aboutIndex = 3;
  static const _instagramIndex = 4;
  static const _tiktokIndex = 5;

  /// Instagram and TikTok are the only optional fields.
  static const _firstOptionalIndex = _instagramIndex;
  static const _icons = [
    Icons.person_outline,
    Icons.account_box_outlined,
    Icons.location_on_outlined,
    Icons.edit_outlined,
    Icons.link_outlined,
    Icons.link_outlined,
  ];

  final _controllers = List.generate(6, (_) => TextEditingController());
  bool _showErrors = false;
  bool _submitting = false;
  File? _photo;
  File? _banner;

  /// Server-side complaints, keyed by field index (and `-1` for the banner,
  /// `-2` for the photo).
  final Map<int, String> _serverErrors = {};
  List<String> _nicknameSuggestions = const [];
  String? _formError;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _text(int index) => _controllers[index].text.trim();

  bool _missing(int index) =>
      index < _firstOptionalIndex && _text(index).isEmpty;

  bool get _complete =>
      !List.generate(_controllers.length, _missing).contains(true) &&
      _banner != null;

  void _clearError(int index) {
    if (_serverErrors.containsKey(index) || _formError != null) {
      setState(() {
        _serverErrors.remove(index);
        if (index == _nicknameIndex) _nicknameSuggestions = const [];
        _formError = null;
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _continue(
    String Function({required String tk, required String ru, required String en})
    t,
  ) async {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    final language = context.read<LanguageProvider>().language;
    final auth = context.read<AuthProvider>();
    final authRepository = context.read<AuthRepository>();
    final nickname = _text(_nicknameIndex).toLowerCase().replaceFirst('@', '');
    if (!nicknamePattern.hasMatch(nickname)) {
      setState(() {
        _showErrors = true;
        _serverErrors[_nicknameIndex] = t(
          tk: '3-20 harp: kiçi harp, san we _ (sanly başlanyp bilmez)',
          ru: '3-20 символов: строчные буквы, цифры и _ (не с цифры)',
          en: '3-20 chars: lowercase letters, numbers and _ (no leading digit)',
        );
      });
      return;
    }
    setState(() {
      _submitting = true;
      _formError = null;
      _serverErrors.clear();
    });
    final data = RegistrationData(
      role: 'master',
      name: _text(_nameIndex),
      nickname: nickname,
      phone: widget.phone,
      locale: language.name,
      photoPath: _photo?.path,
      address: _text(_addressIndex),
      description: _text(_aboutIndex),
      bannerPath: _banner?.path,
      instagramUrl: socialUrl(_text(_instagramIndex), host: 'instagram.com'),
      tiktokUrl: socialUrl(
        _text(_tiktokIndex),
        host: 'tiktok.com',
        atPrefix: true,
      ),
    );
    try {
      final check = await authRepository.nicknameAvailable(nickname);
      if (!check.available) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _nicknameSuggestions = check.suggestions;
          _serverErrors[_nicknameIndex] = t(
            tk: 'Bu lakam eýesiz däl',
            ru: 'Этот никнейм уже занят',
            en: 'This nickname is taken',
          );
        });
        return;
      }
      await auth.register(data);
    } catch (error) {
      if (!mounted) return;
      _showRegistrationError(error, language);
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.push(
      context,
      pageRoute(MasterOtpScreen(phone: widget.phone, registration: data)),
    );
  }

  void _showRegistrationError(Object error, AppLanguage language) {
    setState(() {
      _submitting = false;
      if (error is ApiException) {
        if (error.code == ApiErrors.nicknameTaken) {
          _nicknameSuggestions = error.nicknameSuggestions;
          _serverErrors[_nicknameIndex] = error.localized(language);
          return;
        }
        if (error.code == ApiErrors.validation) {
          const fieldIndex = {
            'name': _nameIndex,
            'nickname': _nicknameIndex,
            'address': _addressIndex,
            'description': _aboutIndex,
            'instagram_url': _instagramIndex,
            'tiktok_url': _tiktokIndex,
            'banner': -1,
            'photo': -2,
          };
          for (final e in error.fieldErrors.entries) {
            final index = fieldIndex[e.key];
            if (index != null) _serverErrors[index] = e.value;
          }
          if (_serverErrors.isNotEmpty) return;
        }
      }
      _formError = apiErrorMessage(error, language);
    });
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
        'Instagram (islege görä)',
        'TikTok (islege görä)',
      ],
      AppLanguage.ru => const [
        'Имя',
        '@ никнейм',
        'Рабочий адрес',
        'Описание',
        'Instagram (необязательно)',
        'TikTok (необязательно)',
      ],
      AppLanguage.en => const [
        'Your name',
        '@ nickname',
        'Work address',
        'About you',
        'Instagram (optional)',
        'TikTok (optional)',
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
              const _MasterProgressIndicator(step: 2),
              const SizedBox(height: 30),
              SizedBox(
                width: 158,
                child: PhotoUploadBox(
                  file: _photo,
                  onPicked: (file) => setState(() {
                    _photo = file;
                    _serverErrors.remove(-2);
                  }),
                  title: t(
                    tk: 'Profil suraty',
                    ru: 'Фото профиля',
                    en: 'Profile photo',
                  ),
                  height: 128,
                  radius: 35,
                ),
              ),
              if (_serverErrors[-2] != null)
                _FieldError(_serverErrors[-2]!),
              const SizedBox(height: 14),
              PhotoUploadBox(
                file: _banner,
                onPicked: (file) => setState(() {
                  _banner = file;
                  _serverErrors.remove(-1);
                }),
                title: t(tk: 'Baner suraty', ru: 'Баннер профиля', en: 'Profile banner'),
                hint: t(
                  tk: 'Hökmany · 8 MB çenli',
                  ru: 'Обязательно · до 8 МБ',
                  en: 'Required · up to 8 MB',
                ),
                height: 120,
                radius: 20,
              ),
              if (_serverErrors[-1] != null) _FieldError(_serverErrors[-1]!),
              if (_showErrors && _banner == null)
                _FieldError(
                  t(
                    tk: 'Baner suraty hökmany',
                    ru: 'Баннер обязателен',
                    en: 'A banner image is required',
                  ),
                ),
              const SizedBox(height: 24),
              ...List.generate(fields.length, (index) {
                final serverError = _serverErrors[index];
                final missing = _showErrors && _missing(index);
                final invalid = missing || serverError != null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controllers[index],
                        onChanged: (_) => _clearError(index),
                        maxLines: index == _aboutIndex ? 3 : 1,
                        keyboardType: index == _instagramIndex || index == _tiktokIndex
                            ? TextInputType.url
                            : TextInputType.text,
                        decoration: InputDecoration(
                          hintText: fields[index],
                          hintStyle: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 14,
                          ),
                          errorText: serverError ??
                              (missing
                                  ? t(
                                      tk: 'Bu meýdan hökmany',
                                      ru: 'Обязательное поле',
                                      en: 'This field is required',
                                    )
                                  : null),
                          errorMaxLines: 3,
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
                      if (index == _nicknameIndex && _nicknameSuggestions.isNotEmpty)
                        _NicknameSuggestionChips(
                          suggestions: _nicknameSuggestions,
                          onPick: (value) => setState(() {
                            _controllers[_nicknameIndex].text = value;
                            _nicknameSuggestions = const [];
                            _serverErrors.remove(_nicknameIndex);
                          }),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 6),
              if (_formError != null) ...[
                _FieldError(_formError!),
                const SizedBox(height: 10),
              ],
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _complete ? 0 : 1,
                child: Text(
                  t(
                    tk: 'Dowam etmek üçin ähli hökmany meýdanlary dolduryň.',
                    ru: 'Заполните обязательные поля, чтобы продолжить.',
                    en: 'Fill in all required fields to continue.',
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
                label: _submitting
                    ? t(tk: 'Iberilýär...', ru: 'Отправка...', en: 'Sending...')
                    : t(tk: 'Kod iber', ru: 'Отправить код', en: 'Send code'),
                fillFraction: .70,
                enabled: _complete && !_submitting,
                onTap: () => _continue(t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
