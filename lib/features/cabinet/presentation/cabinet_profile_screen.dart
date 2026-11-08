part of '../../../app/komekci_app.dart';

class CabinetProfileScreen extends StatefulWidget {
  const CabinetProfileScreen({super.key});

  @override
  State<CabinetProfileScreen> createState() => _CabinetProfileScreenState();
}

class _CabinetProfileScreenState extends State<CabinetProfileScreen> {
  // Controller order: name, nickname, address, about, instagram, tiktok.
  static const _nameIndex = 0;
  static const _nicknameIndex = 1;
  static const _addressIndex = 2;
  static const _aboutIndex = 3;
  static const _instagramIndex = 4;
  static const _tiktokIndex = 5;

  /// Backend limits (`POST /auth/register`, `PATCH /me/profile`).
  static const _nameMax = 50;
  static const _addressMax = 255;
  static const _aboutMax = 2000;

  late final _controllers = () {
    final p = context.read<MasterProfileProvider>();
    return [
      TextEditingController(text: p.name),
      TextEditingController(text: p.nickname),
      TextEditingController(text: p.address),
      TextEditingController(text: p.about),
      TextEditingController(text: p.instagram),
      TextEditingController(text: p.tiktok),
    ];
  }();
  File? _banner;
  bool _nicknameTaken = false;
  bool _nicknameInvalid = false;
  bool _nicknameChecking = false;
  bool _nicknameAvailable = false;
  List<String> _nicknameSuggestions = const [];
  bool _saving = false;
  String? _error;
  Timer? _nicknameDebounce;

  @override
  void initState() {
    super.initState();
    _refreshFromServer();
  }

  @override
  void dispose() {
    _nicknameDebounce?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _enteredNickname => _controllers[_nicknameIndex].text.trim().toLowerCase().replaceFirst('@', '');

  /// Format first, then (after a short pause) ask the server whether the
  /// nickname is free — unless it's the master's own.
  void _checkNickname() {
    _nicknameDebounce?.cancel();
    final current = context.read<MasterProfileProvider>().nickname.toLowerCase();
    final value = _enteredNickname;
    final invalid = !nicknamePattern.hasMatch(value);
    final needsCheck = !invalid && value != current;
    setState(() {
      _nicknameInvalid = invalid;
      _nicknameTaken = false;
      _nicknameAvailable = false;
      _nicknameChecking = needsCheck;
      _nicknameSuggestions = const [];
    });
    if (!needsCheck) return;
    final repository = context.read<AuthRepository>();
    _nicknameDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final check = await repository.nicknameAvailable(value);
        if (!mounted || value != _enteredNickname) return;
        setState(() {
          _nicknameChecking = false;
          _nicknameTaken = !check.available;
          _nicknameAvailable = check.available;
          _nicknameSuggestions = check.suggestions;
        });
      } catch (_) {
        // Offline or rate limited: the server re-checks on save anyway.
        if (mounted && value == _enteredNickname) {
          setState(() => _nicknameChecking = false);
        }
      }
    });
  }

  Future<void> _changeAvatar(File file) => _uploadAvatar(context, file);

  Future<void> _pickBanner() async {
    final picked = await pickCompressedImage(context, language: context.read<LanguageProvider>().language);
    if (picked != null && mounted) setState(() => _banner = picked);
  }

  Future<void> _save() async {
    if (_nicknameTaken || _nicknameInvalid || _saving) return;
    final language = context.read<LanguageProvider>().language;
    final profile = context.read<MasterProfileProvider>();
    final toast = AppToast.of(context);
    final navigator = Navigator.of(context);
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await profile.save(
        name: _controllers[_nameIndex].text.trim(),
        nickname: _enteredNickname,
        address: _controllers[_addressIndex].text.trim(),
        about: _controllers[_aboutIndex].text.trim(),
        instagramUrl: socialUrl(_controllers[_instagramIndex].text, host: 'instagram.com') ?? '',
        tiktokUrl: socialUrl(_controllers[_tiktokIndex].text, host: 'tiktok.com', atPrefix: true) ?? '',
        banner: _banner,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (error is ApiException && error.code == ApiErrors.nicknameTaken) {
          _nicknameTaken = true;
          _nicknameAvailable = false;
          _nicknameSuggestions = error.nicknameSuggestions;
        } else {
          _error = apiErrorMessage(error, language);
        }
      });
      return;
    }
    toast.success(pickTr(language, tk: 'Profil ýatda saklandy.', ru: 'Профиль сохранён.', en: 'Profile saved.'));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final profile = context.watch<MasterProfileProvider>();
    final nicknameError = _nicknameTaken || _nicknameInvalid;

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Profil', ru: 'Профиль', en: 'Profile'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  _ProfileHero(
                    banner: _banner ?? profile.banner,
                    bannerUrl: profile.bannerUrl,
                    avatar: profile.avatar,
                    avatarUrl: profile.avatarUrl,
                    nameController: _controllers[_nameIndex],
                    nicknameController: _controllers[_nicknameIndex],
                    onPickBanner: _pickBanner,
                    onPickAvatar: _changeAvatar,
                    bannerLabel: _banner != null || profile.bannerUrl != null
                        ? t(tk: 'Banneri üýtget', ru: 'Изменить баннер', en: 'Change banner')
                        : t(tk: 'Banner goş', ru: 'Добавить баннер', en: 'Add banner'),
                    bannerHint: t(tk: 'Profiliň ýokarsynda görner', ru: 'Отображается наверху профиля', en: 'Shown at the top of the profile'),
                  ),
                  const SizedBox(height: 18),
                  _ProfileSection(
                    icon: Icons.person_outline,
                    title: t(tk: 'Esasy maglumatlar', ru: 'Основное', en: 'Basics'),
                    children: [
                      _ProfileField(
                        controller: _controllers[_nameIndex],
                        label: t(tk: 'Adyňyz', ru: 'Имя', en: 'Name'),
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [LengthLimitingTextInputFormatter(_nameMax)],
                      ),
                      _ProfileField(
                        controller: _controllers[_nicknameIndex],
                        label: t(tk: 'Lakamyňyz', ru: 'Никнейм', en: 'Nickname'),
                        icon: Icons.account_box_outlined,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        onChanged: (_) => _checkNickname(),
                        errorText: !nicknameError
                            ? null
                            : _nicknameTaken
                            ? t(tk: 'Bu lakam eýesiz däl', ru: 'Этот никнейм уже занят', en: 'This nickname is already taken')
                            : t(tk: '3-20 harp: kiçi harp, san we _', ru: '3-20 символов: строчные буквы, цифры и _', en: '3-20 chars: lowercase letters, numbers and _'),
                        helperText: nicknameError || _nicknameChecking || _nicknameAvailable
                            ? null
                            : t(tk: 'Müşderiler sizi şu at bilen tapar', ru: 'По этому имени клиенты найдут вас', en: 'Clients find you by this name'),
                        statusIcon: _nicknameChecking
                            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: tokens.accent))
                            : _nicknameAvailable
                            ? AppIcon(Icons.check_circle, size: 18, color: tokens.success)
                            : null,
                        footer: _NicknameSuggestionChips(
                          suggestions: _nicknameSuggestions,
                          onPick: (value) {
                            _controllers[_nicknameIndex].text = value;
                            _checkNickname();
                          },
                        ),
                      ),
                      _ProfilePhoneRow(
                        label: t(tk: 'Telefon belgiňiz', ru: 'Телефон', en: 'Phone number'),
                        action: t(tk: 'Üýtget', ru: 'Изменить', en: 'Change'),
                        phone: displayPhone(profile.phone),
                        onTap: _changePhone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProfileSection(
                    icon: Icons.location_on_outlined,
                    title: t(tk: 'Salgy we beýan', ru: 'Адрес и описание', en: 'Address & bio'),
                    children: [
                      _ProfileField(
                        controller: _controllers[_addressIndex],
                        label: t(tk: 'Salgysy', ru: 'Адрес', en: 'Address'),
                        icon: Icons.location_on_outlined,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [LengthLimitingTextInputFormatter(_addressMax)],
                      ),
                      _ProfileField(
                        controller: _controllers[_aboutIndex],
                        label: t(tk: 'Özüňiz barada', ru: 'О себе', en: 'About you'),
                        icon: Icons.edit_outlined,
                        maxLines: 4,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        maxLength: _aboutMax,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProfileSection(
                    icon: Icons.link_outlined,
                    title: t(tk: 'Sosial ulgamlar', ru: 'Соцсети', en: 'Social media'),
                    subtitle: t(tk: 'Islege görä', ru: 'Необязательно', en: 'Optional'),
                    children: [
                      _ProfileField(
                        controller: _controllers[_instagramIndex],
                        label: 'Instagram',
                        icon: Icons.camera_alt_outlined,
                        hint: '@${t(tk: 'lakamyňyz', ru: 'ник', en: 'handle')}',
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                      ),
                      _ProfileField(
                        controller: _controllers[_tiktokIndex],
                        label: 'TikTok',
                        icon: Icons.music_note_outlined,
                        hint: '@${t(tk: 'lakamyňyz', ru: 'ник', en: 'handle')}',
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListenableBuilder(
              listenable: Listenable.merge(_controllers),
              builder: (context, _) => _ProfileSaveBar(
                error: _error,
                saving: _saving,
                canSave: _dirty && !nicknameError && !_saving,
                previewLabel: t(tk: 'Öňünden gör', ru: 'Просмотр', en: 'Preview'),
                saveLabel: _saving ? t(tk: 'Saklanýar...', ru: 'Сохранение...', en: 'Saving...') : t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save'),
                onPreview: () => _openPreview(profile),
                onSave: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner with the avatar overlapping its lower edge and the name/nickname
/// being typed shown live underneath — the top of the page reads like the
/// profile a client will see.
