part of '../../../app/komekci_app.dart';

/// Step 2 of master sign-up. Submitting creates the account on the server
/// (`POST /auth/register`), which sends the SMS code for step 3.
class MasterRegistrationScreen extends StatefulWidget {
  const MasterRegistrationScreen({super.key, required this.phone});

  /// `+993XXXXXXXX`, collected on the previous step.
  final String phone;

  @override
  State<MasterRegistrationScreen> createState() => _MasterRegistrationScreenState();
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
  _NicknameState _nicknameState = _NicknameState.idle;
  Timer? _nicknameDebounce;

  @override
  void dispose() {
    _nicknameDebounce?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _text(int index) => _controllers[index].text.trim();

  bool _missing(int index) => index < _firstOptionalIndex && _text(index).isEmpty;

  bool get _complete => !List.generate(_controllers.length, _missing).contains(true) && _photo != null && _banner != null;

  String get _nickname => _text(_nicknameIndex).toLowerCase().replaceFirst('@', '');

  /// Format first, then (after a pause in typing) ask the server whether the
  /// nickname is free.
  void _onNicknameChanged() {
    _nicknameDebounce?.cancel();
    final value = _nickname;
    _serverErrors.remove(_nicknameIndex);
    if (value.isEmpty) {
      setState(() {
        _nicknameState = _NicknameState.idle;
        _nicknameSuggestions = const [];
      });
      return;
    }
    if (!nicknamePattern.hasMatch(value)) {
      setState(() {
        _nicknameState = _NicknameState.invalid;
        _nicknameSuggestions = const [];
      });
      return;
    }
    setState(() {
      _nicknameState = _NicknameState.checking;
      _nicknameSuggestions = const [];
    });
    final repository = context.read<AuthRepository>();
    _nicknameDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final check = await repository.nicknameAvailable(value);
        if (!mounted || value != _nickname) return;
        setState(() {
          _nicknameState = check.available ? _NicknameState.free : _NicknameState.taken;
          _nicknameSuggestions = check.suggestions;
        });
      } catch (_) {
        // Offline or rate limited: the server re-checks on submit.
        if (mounted && value == _nickname) setState(() => _nicknameState = _NicknameState.idle);
      }
    });
  }

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

  Future<void> _continue(String Function({required String tk, required String ru, required String en}) t) async {
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
      tiktokUrl: socialUrl(_text(_tiktokIndex), host: 'tiktok.com', atPrefix: true),
    );
    try {
      final check = await authRepository.nicknameAvailable(nickname);
      if (!check.available) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _nicknameSuggestions = check.suggestions;
          _nicknameState = _NicknameState.taken;
          _serverErrors[_nicknameIndex] = t(tk: 'Bu lakam eýesiz däl', ru: 'Этот никнейм уже занят', en: 'This nickname is taken');
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
    Navigator.push(context, pageRoute(MasterOtpScreen(phone: widget.phone, registration: data)));
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

  Widget _label(AppThemeTokens tokens, String text, {bool required = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        if (required)
          Text(
            ' *',
            style: TextStyle(fontSize: 13, color: tokens.danger, fontWeight: FontWeight.w700),
          ),
      ],
    ),
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 16),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
  );

  Future<void> _pickBanner() async {
    final language = context.read<LanguageProvider>().language;
    final picked = await pickCompressedImage(context, language: language);
    if (picked != null) {
      setState(() {
        _banner = picked;
        _serverErrors.remove(-1);
      });
    }
  }

  /// Wide banner with the round profile photo overlapping its bottom edge.
  Widget _photoHeader(AppThemeTokens tokens, _Tr t) {
    final bannerError = _serverErrors[-1] != null || (_showErrors && _banner == null);
    final photoError = _serverErrors[-2] != null || (_showErrors && _photo == null);
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: _pickBanner,
              child: Container(
                height: 150,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: bannerError ? tokens.danger : (_banner != null ? tokens.accent : tokens.border), width: bannerError || _banner != null ? 2.5 : 1.5),
                ),
                child: _banner != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(21),
                            child: Image.file(_banner!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const AppIcon(Icons.edit_outlined, color: Colors.white, size: 15),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 34),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(Icons.image_outlined, size: 30, color: bannerError ? tokens.danger : tokens.textSecondary),
                            const SizedBox(height: 8),
                            Text(
                              t(tk: 'Baner suraty goşuň *', ru: 'Добавьте баннер *', en: 'Add a banner *'),
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: bannerError ? tokens.danger : tokens.textPrimary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t(tk: 'Profiliňiziň ýokarsynda görner', ru: 'Отображается вверху профиля', en: 'Shown at the top of your profile'),
                              style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: -52,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.surface,
                  border: Border.all(color: photoError ? tokens.danger : (_photo != null ? tokens.accent : tokens.border), width: 1.6),
                ),
                child: AvatarPicker(
                  file: _photo,
                  radius: 46,
                  onPicked: (file) => setState(() {
                    _photo = file;
                    _serverErrors.remove(-2);
                  }),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 62),
        Text(
          _photo == null
              ? t(tk: 'Profil suratyny goşuň *', ru: 'Добавьте фото профиля *', en: 'Add a profile photo *')
              : t(tk: 'Suraty üýtgetmek üçin basyň', ru: 'Нажмите, чтобы изменить фото', en: 'Tap to change the photo'),
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: photoError ? tokens.danger : tokens.textSecondary),
        ),
        if (_serverErrors[-1] != null) _FieldError(_serverErrors[-1]!),
        if (_serverErrors[-2] != null) _FieldError(_serverErrors[-2]!),
      ],
    );
  }

  /// One filled text field with its label and any error underneath.
  Widget _field(
    AppThemeTokens tokens,
    _Tr t, {
    required int index,
    required String label,
    required String hint,
    required IconData icon,
    bool required = true,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? formatters,
  }) {
    final serverError = _serverErrors[index];
    final missing = _showErrors && _missing(index);
    final message = serverError ?? (missing ? t(tk: 'Bu meýdan hökmany', ru: 'Обязательное поле', en: 'This field is required') : null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(tokens, label, required: required),
          TextField(
            controller: _controllers[index],
            maxLines: maxLines,
            minLines: maxLines > 1 ? maxLines : null,
            maxLength: maxLength,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            inputFormatters: formatters,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
            decoration: registrationDecoration(tokens, hint: hint, icon: icon, suffix: suffix, error: message != null),
            onChanged: (value) {
              _clearError(index);
              onChanged?.call(value);
            },
          ),
          if (message != null) _FieldError(message),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;

    final nicknameSuffix = switch (_nicknameState) {
      _NicknameState.checking => SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: tokens.textSecondary)),
      _NicknameState.free => AppIcon(Icons.check_circle, size: 20, color: tokens.success),
      _NicknameState.taken || _NicknameState.invalid => AppIcon(Icons.cancel, size: 20, color: tokens.danger),
      _NicknameState.idle => null,
    };
    final nicknameNote = switch (_nicknameState) {
      _NicknameState.free => (t(tk: 'Bu lakam elýeterli', ru: 'Никнейм свободен', en: 'Nickname is available'), tokens.success),
      _NicknameState.taken => (t(tk: 'Bu lakam eýesiz däl', ru: 'Этот никнейм уже занят', en: 'This nickname is taken'), tokens.danger),
      _NicknameState.invalid => (
        t(tk: '3–20 simwol: a–z, 0–9 we _ (sanly başlap bilmez)', ru: '3–20 символов: a–z, 0–9 и _ (не с цифры)', en: '3–20 characters: a–z, 0–9 and _ (no leading digit)'),
        tokens.danger,
      ),
      _ => (t(tk: 'Müşderiler sizi şu lakam bilen tapar', ru: 'Клиенты найдут вас по этому никнейму', en: 'Clients will find you by this nickname'), tokens.textSecondary),
    };

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: _MasterSetupHeader(
        title: t(tk: 'MASTER HASABY', ru: 'ПРОФИЛЬ МАСТЕРА', en: 'MASTER PROFILE'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MasterProgressIndicator(step: 2),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  t(tk: 'Profiliňizi dörediň', ru: 'Создайте профиль', en: 'Create your profile'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -.3),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  t(tk: 'Müşderiler sizi şeýle görer', ru: 'Так вас увидят клиенты', en: 'This is how clients will see you'),
                  style: TextStyle(fontSize: 13.5, color: tokens.textSecondary),
                ),
              ),
              const SizedBox(height: 22),
              _photoHeader(tokens, t),
              const SizedBox(height: 26),
              _section(t(tk: 'Esasy maglumat', ru: 'Основное', en: 'Basics')),
              _field(
                tokens,
                t,
                index: _nameIndex,
                label: t(tk: 'Adyňyz', ru: 'Имя', en: 'Your name'),
                hint: t(tk: 'Adyňyzy ýazyň', ru: 'Введите имя', en: 'Enter your name'),
                icon: Icons.person_outline,
                capitalization: TextCapitalization.words,
                maxLength: 50,
              ),
              _field(
                tokens,
                t,
                index: _nicknameIndex,
                label: t(tk: 'Lakam (nickname)', ru: 'Никнейм', en: 'Nickname'),
                hint: 'ayna_style',
                icon: Icons.alternate_email,
                suffix: nicknameSuffix,
                maxLength: 21,
                formatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_@]'))],
                onChanged: (_) => _onNicknameChanged(),
              ),
              Transform.translate(
                offset: const Offset(0, -12),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(_serverErrors[_nicknameIndex] == null ? nicknameNote.$1 : '', style: TextStyle(fontSize: 11.5, height: 1.35, color: nicknameNote.$2)),
                ),
              ),
              if (_nicknameSuggestions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _NicknameSuggestionChips(
                    suggestions: _nicknameSuggestions,
                    onPick: (value) => setState(() {
                      _controllers[_nicknameIndex].text = value;
                      _onNicknameChanged();
                    }),
                  ),
                ),
              _field(
                tokens,
                t,
                index: _addressIndex,
                label: t(tk: 'Iş salgyňyz', ru: 'Рабочий адрес', en: 'Work address'),
                hint: t(tk: 'Şäher, etrap, köçe', ru: 'Город, район, улица', en: 'City, district, street'),
                icon: Icons.location_on_outlined,
                maxLength: 255,
              ),
              _field(
                tokens,
                t,
                index: _aboutIndex,
                label: t(tk: 'Özüňiz barada', ru: 'О себе', en: 'About you'),
                hint: t(tk: 'Tejribäňiz, hyzmatlaryňyz barada gysgaça ýazyň', ru: 'Коротко об опыте и услугах', en: 'A few words about your experience and services'),
                icon: Icons.edit_outlined,
                maxLines: 4,
                maxLength: 2000,
                capitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 4),
              _section(t(tk: 'Sosial ulgamlar', ru: 'Соцсети', en: 'Social media')),
              _field(tokens, t, index: _instagramIndex, label: 'Instagram', hint: '@instagram_lakam', icon: Icons.camera_alt_outlined, required: false, keyboardType: TextInputType.url),
              _field(tokens, t, index: _tiktokIndex, label: 'TikTok', hint: '@tiktok_lakam', icon: Icons.music_note_outlined, required: false, keyboardType: TextInputType.url),
              if (_formError != null) ...[_FieldError(_formError!), const SizedBox(height: 10)],
              if (_showErrors && !_complete)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    t(tk: 'Dowam etmek üçin * bilen bellenen meýdanlary dolduryň.', ru: 'Заполните поля, отмеченные *, чтобы продолжить.', en: 'Fill in the fields marked * to continue.'),
                    style: TextStyle(fontSize: 12, color: tokens.danger),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
          child: _MasterActionButton(
            label: _submitting ? t(tk: 'Iberilýär...', ru: 'Отправка...', en: 'Sending...') : t(tk: 'Kod iber', ru: 'Отправить код', en: 'Send code'),
            enabled: !_submitting,
            trailingArrow: true,
            onTap: () => _continue(t),
          ),
        ),
      ),
    );
  }
}
