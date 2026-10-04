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

  /// `GET /me/profile`, then fill in the fields the master has not touched
  /// yet — anything they already typed stays.
  Future<void> _refreshFromServer() async {
    final profile = context.read<MasterProfileProvider>();
    final before = [for (final c in _controllers) c.text];
    await profile.refresh();
    if (!mounted) return;
    final fresh = [profile.name, profile.nickname, profile.address, profile.about, profile.instagram, profile.tiktok];
    for (var i = _addressIndex; i < _controllers.length; i++) {
      if (_controllers[i].text == before[i]) _controllers[i].text = fresh[i];
    }
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

  /// True once anything differs from what the server holds, so Save stays
  /// off until there is something to save.
  bool get _dirty {
    final p = context.read<MasterProfileProvider>();
    String text(int i) => _controllers[i].text.trim();
    return _banner != null ||
        text(_nameIndex) != p.name ||
        _enteredNickname != p.nickname.toLowerCase() ||
        text(_addressIndex) != p.address ||
        text(_aboutIndex) != p.about ||
        text(_instagramIndex) != p.instagram ||
        text(_tiktokIndex) != p.tiktok;
  }

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

  Future<void> _changePhone() async {
    final language = context.read<LanguageProvider>().language;
    final toast = AppToast.of(context);
    if (await showChangePhoneDialog(context)) {
      toast.success(pickTr(
              language,
              tk: 'Telefon belgisi üýtgedildi. Tölegi täze belgiden geçiriň.',
              ru: 'Номер изменён. Оплачивайте теперь с нового номера.',
              en: 'Phone number updated. Pay from the new number from now on.',
            ),);
    }
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

  void _openPreview(MasterProfileProvider profile) {
    String text(int i) => _controllers[i].text.trim();
    Navigator.push(
      context,
      pageRoute(
        _MasterProfilePreviewScreen(
          name: text(_nameIndex),
          nickname: _enteredNickname,
          address: text(_addressIndex),
          about: text(_aboutIndex),
          instagram: text(_instagramIndex),
          tiktok: text(_tiktokIndex),
          avatar: profile.avatar,
          avatarUrl: profile.avatarUrl,
          banner: _banner ?? profile.banner,
          bannerUrl: profile.bannerUrl,
        ),
      ),
    );
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
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.banner,
    required this.bannerUrl,
    required this.avatar,
    required this.avatarUrl,
    required this.nameController,
    required this.nicknameController,
    required this.onPickBanner,
    required this.onPickAvatar,
    required this.bannerLabel,
    required this.bannerHint,
  });

  final File? banner;
  final String? bannerUrl;
  final File? avatar;
  final String? avatarUrl;
  final TextEditingController nameController;
  final TextEditingController nicknameController;
  final VoidCallback onPickBanner;
  final ValueChanged<File> onPickAvatar;
  final String bannerLabel;
  final String bannerHint;

  static const _bannerHeight = 150.0;
  static const _avatarRadius = 42.0;
  static const _avatarRing = 4.0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final hasBanner = banner != null || bannerUrl != null;
    final ringSize = (_avatarRadius + _avatarRing) * 2;

    Widget bannerImage() {
      if (banner != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),

          child: Image.file(banner!, fit: BoxFit.cover),
        );
      }
      if (bannerUrl != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(bannerUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The avatar hangs half its height below the banner, so this stack
        // is taller than the banner by that overhang.
        SizedBox(
          height: _bannerHeight + ringSize / 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _bannerHeight,
                child: GestureDetector(
                  onTap: onPickBanner,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: hasBanner ? tokens.accent.withValues(alpha: .6) : tokens.border),
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tokens.accent.withValues(alpha: .20), tokens.accent.withValues(alpha: .06)]),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        bannerImage(),
                        if (!hasBanner)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppIcon(Icons.image_outlined, size: 28, color: tokens.accent),
                                const SizedBox(height: 8),
                                Text(
                                  bannerLabel,
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                                ),
                                const SizedBox(height: 3),
                                Text(bannerHint, style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
                              ],
                            ),
                          )
                        else
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: .55), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const AppIcon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    bannerLabel,
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: ringSize,
                      height: ringSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.surface,
                        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .08), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: AvatarPicker(file: avatar, networkUrl: avatarUrl, onPicked: onPickAvatar, radius: _avatarRadius),
                    ),
                    // A fresh photo uploads at once; show that it is going.
                    if (avatar != null)
                      Container(
                        width: _avatarRadius * 2,
                        height: _avatarRadius * 2,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black38),
                        child: const Center(
                          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 4, 0),
          child: ListenableBuilder(
            listenable: Listenable.merge([nameController, nicknameController]),
            builder: (context, _) {
              final name = nameController.text.trim();
              final nickname = nicknameController.text.trim().replaceFirst('@', '');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? '—' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nickname.isEmpty ? '@' : '@$nickname',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.5, color: tokens.textSecondary),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A titled card that groups related fields.
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.icon, required this.title, required this.children, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .16), borderRadius: BorderRadius.circular(10)),
                child: AppIcon(icon, size: 16, color: tokens.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                ),
              ),
              if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          for (final child in children) Padding(padding: const EdgeInsets.only(bottom: 14), child: child),
        ],
      ),
    );
  }
}

/// One labelled text field: label above, soft filled input, an optional
/// state icon on the right and hint/error/footer underneath.
class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.helperText,
    this.errorText,
    this.statusIcon,
    this.footer,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autocorrect = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? statusIcon;
  final Widget? footer;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final int maxLines;
  final int? minLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final hasError = errorText != null;
    final multiline = maxLines > 1;
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
          ),
        ),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autocorrect: autocorrect,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: tokens.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: tokens.disabled, fontWeight: FontWeight.w400),
            // The helper is shown by us below, so the error and the
            // suggestion chips can sit in one column.
            counterStyle: TextStyle(fontSize: 11, color: tokens.textSecondary),
            filled: true,
            fillColor: tokens.surface,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: multiline ? 14 : 15),
            prefixIcon: multiline
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: AppIcon(icon, size: 18, color: hasError ? tokens.danger : tokens.textSecondary),
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: statusIcon == null ? null : Padding(padding: const EdgeInsets.only(right: 14), child: statusIcon),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            enabledBorder: border(hasError ? tokens.danger : tokens.border),
            focusedBorder: border(hasError ? tokens.danger : tokens.accent, 1.5),
            border: border(tokens.border),
          ),
        ),
        if (hasError)
          _FieldError(errorText!)
        else if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(helperText!, style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
          ),
        ?footer,
      ],
    );
  }
}

/// The phone number is changed through an SMS-confirmed dialog, so it is a
/// read-only row with a "Change" action rather than a text field.
class _ProfilePhoneRow extends StatelessWidget {
  const _ProfilePhoneRow({required this.label, required this.action, required this.phone, required this.onTap});

  final String label;
  final String action;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                AppIcon(Icons.phone_outlined, size: 18, color: tokens.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    phone,
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: tokens.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
                  child: Text(
                    action,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Fixed bar under the form: a server error (if any), "Preview" and "Save".
class _ProfileSaveBar extends StatelessWidget {
  const _ProfileSaveBar({required this.error, required this.saving, required this.canSave, required this.previewLabel, required this.saveLabel, required this.onPreview, required this.onSave});

  final String? error;
  final bool saving;
  final bool canSave;
  final String previewLabel;
  final String saveLabel;
  final VoidCallback onPreview;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(top: BorderSide(color: tokens.border)),
        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .05), blurRadius: 14, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.danger.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.danger.withValues(alpha: .35)),
              ),
              child: Row(
                children: [
                  AppIcon(Icons.warning_amber_rounded, size: 16, color: tokens.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(error!, style: TextStyle(fontSize: 12.5, color: tokens.danger)),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: onPreview,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.textPrimary,
                    side: BorderSide(color: tokens.border),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const AppIcon(Icons.remove_red_eye_outlined, size: 18),
                  label: Text(previewLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MasterActionButton(label: saveLabel, enabled: canSave, leading: saving ? null : Icons.save_outlined, onTap: onSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Read-only, client-facing rendering of the profile being edited — lets
/// the master check what a client would see before saving.
class _MasterProfilePreviewScreen extends StatelessWidget {
  const _MasterProfilePreviewScreen({
    required this.name,
    required this.nickname,
    required this.address,
    required this.about,
    required this.instagram,
    required this.tiktok,
    required this.avatar,
    required this.avatarUrl,
    required this.banner,
    required this.bannerUrl,
  });
  final String name;
  final String nickname;
  final String address;
  final String about;
  final String instagram;
  final String tiktok;
  final File? avatar;
  final String? avatarUrl;
  final File? banner;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        leading: IconButton(icon: const AppIcon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        title: Text(t(tk: 'Öňünden görnüş', ru: 'Предпросмотр', en: 'Preview')),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ClipRRect(
              child: banner != null
                  ? Image.file(banner!, height: 160, width: double.infinity, fit: BoxFit.cover)
                  : bannerUrl != null
                  ? Image.network(
                      bannerUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(height: 160, color: tokens.surfaceElevated),
                    )
                  : Container(height: 160, color: tokens.surfaceElevated),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: tokens.surface,
                      child: RoundPhoto(file: avatar, url: avatarUrl, radius: 36),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? t(tk: 'Ady ýok', ru: 'Без имени', en: 'No name') : name,
                          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text('@${nickname.isEmpty ? t(tk: 'lakam', ru: 'ник', en: 'nickname') : nickname}', style: TextStyle(color: tokens.textSecondary)),
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              AppIcon(Icons.location_on_outlined, size: 14, color: tokens.textSecondary),
                              const SizedBox(width: 5),
                              Text(address, style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (about.isNotEmpty) ...[
                    Text(
                      t(tk: 'Hakynda', ru: 'О себе', en: 'About'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(about, style: TextStyle(color: tokens.textSecondary, height: 1.45)),
                    const SizedBox(height: 20),
                  ],
                  if (instagram.isNotEmpty || tiktok.isNotEmpty) ...[
                    Text(
                      t(tk: 'Sosial ulgamlar', ru: 'Соцсети', en: 'Social media'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    if (instagram.isNotEmpty) _MetaLine(icon: Icons.camera_alt_outlined, text: instagram),
                    if (instagram.isNotEmpty && tiktok.isNotEmpty) const SizedBox(height: 6),
                    if (tiktok.isNotEmpty) _MetaLine(icon: Icons.music_note_outlined, text: tiktok),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
