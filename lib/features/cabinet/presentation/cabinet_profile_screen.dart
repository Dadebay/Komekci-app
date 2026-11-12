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

  String get _enteredNickname => _controllers[_nicknameIndex].text
      .trim()
      .toLowerCase()
      .replaceFirst('@', '');

  /// Format first, then (after a short pause) ask the server whether the
  /// nickname is free — unless it's the master's own.
  void _checkNickname() {
    _nicknameDebounce?.cancel();
    final current = context
        .read<MasterProfileProvider>()
        .nickname
        .toLowerCase();
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
    final picked = await pickCompressedImage(
      context,
      language: context.read<LanguageProvider>().language,
    );
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
        instagramUrl:
            socialUrl(
              _controllers[_instagramIndex].text,
              host: 'instagram.com',
            ) ??
            '',
        tiktokUrl:
            socialUrl(
              _controllers[_tiktokIndex].text,
              host: 'tiktok.com',
              atPrefix: true,
            ) ??
            '',
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
    toast.success(AppStrings.profileProfileSaved.select(language));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final profile = context.watch<MasterProfileProvider>();
    final nicknameError = _nicknameTaken || _nicknameInvalid;

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(title: AppStrings.profileProfile.select(language)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                        ? AppStrings.cabinetChangeBanner.select(language)
                        : AppStrings.cabinetAddBanner.select(language),
                    bannerHint: AppStrings.cabinetShownAtTheTopOf.select(
                      language,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProfileSection(
                    icon: Icons.person_outline,
                    title: AppStrings.cabinetBasics.select(language),
                    children: [
                      _ProfileField(
                        controller: _controllers[_nameIndex],
                        label: AppStrings.profileName.select(language),
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(_nameMax),
                        ],
                      ),
                      _ProfileField(
                        controller: _controllers[_nicknameIndex],
                        label: AppStrings.cabinetNickname2.select(language),
                        icon: Icons.account_box_outlined,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        onChanged: (_) => _checkNickname(),
                        errorText: !nicknameError
                            ? null
                            : _nicknameTaken
                            ? AppStrings.cabinetThisNicknameIsAlreadyTaken
                                  .select(language)
                            : AppStrings.cabinet320CharsLowercaseLetters.select(
                                language,
                              ),
                        helperText:
                            nicknameError ||
                                _nicknameChecking ||
                                _nicknameAvailable
                            ? null
                            : AppStrings.cabinetClientsFindYouByThis.select(
                                language,
                              ),
                        statusIcon: _nicknameChecking
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: tokens.accent,
                                ),
                              )
                            : _nicknameAvailable
                            ? AppIcon(
                                Icons.check_circle,
                                size: 18,
                                color: tokens.success,
                              )
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
                        label: AppStrings.cabinetPhoneNumber.select(language),
                        action: AppStrings.profileChange.select(language),
                        phone: displayPhone(profile.phone),
                        onTap: _changePhone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProfileSection(
                    icon: Icons.location_on_outlined,
                    title: AppStrings.cabinetAddressBio.select(language),
                    children: [
                      _ProfileField(
                        controller: _controllers[_addressIndex],
                        label: AppStrings.cabinetAddress.select(language),
                        icon: Icons.location_on_outlined,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(_addressMax),
                        ],
                      ),
                      _ProfileField(
                        controller: _controllers[_aboutIndex],
                        label: AppStrings.cabinetAboutYou.select(language),
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
                    title: AppStrings.cabinetSocialMedia.select(language),
                    subtitle: AppStrings.cabinetOptional.select(language),
                    children: [
                      _ProfileField(
                        controller: _controllers[_instagramIndex],
                        label: 'Instagram',
                        icon: Icons.camera_alt_outlined,
                        hint: '@${AppStrings.cabinetHandle.select(language)}',
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                      ),
                      _ProfileField(
                        controller: _controllers[_tiktokIndex],
                        label: 'TikTok',
                        icon: Icons.music_note_outlined,
                        hint: '@${AppStrings.cabinetHandle.select(language)}',
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
                previewLabel: AppStrings.cabinetPreview2.select(language),
                saveLabel: _saving
                    ? AppStrings.servicesSaving.select(language)
                    : AppStrings.servicesSave.select(language),
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
