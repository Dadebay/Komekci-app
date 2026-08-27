part of '../../../app/komekci_app.dart';

class CabinetProfileScreen extends StatefulWidget {
  const CabinetProfileScreen({super.key});

  @override
  State<CabinetProfileScreen> createState() => _CabinetProfileScreenState();
}

class _CabinetProfileScreenState extends State<CabinetProfileScreen> {
  static const _nicknameIndex = 1;
  late final _controllers = () {
    final p = context.read<MasterProfileProvider>();
    return [
      TextEditingController(text: p.name),
      TextEditingController(text: p.nickname),
      TextEditingController(text: p.phone),
      TextEditingController(text: p.address),
      TextEditingController(text: p.about),
      TextEditingController(text: p.instagram),
      TextEditingController(text: p.tiktok),
    ];
  }();
  File? _banner;
  bool _nicknameTaken = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _checkNickname() {
    final current = context
        .read<MasterProfileProvider>()
        .nickname
        .toLowerCase();
    final value = _controllers[_nicknameIndex].text
        .trim()
        .toLowerCase()
        .replaceFirst('@', '');
    final taken = value != current && takenNicknames.contains(value);
    if (taken != _nicknameTaken) setState(() => _nicknameTaken = taken);
  }

  void _save() {
    if (_nicknameTaken) return;
    final profile = context.read<MasterProfileProvider>();
    if (_banner != null) profile.setBanner(_banner!);
    profile.update(
      name: _controllers[0].text.trim(),
      nickname: _controllers[1].text.trim().replaceFirst('@', ''),
      phone: _controllers[2].text.trim(),
      address: _controllers[3].text.trim(),
      about: _controllers[4].text.trim(),
      instagram: _controllers[5].text.trim(),
      tiktok: _controllers[6].text.trim(),
    );
    final language = context.read<LanguageProvider>().language;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pickTr(
            language,
            tk: 'Profil ýatda saklandy.',
            ru: 'Профиль сохранён.',
            en: 'Profile saved.',
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final profile = context.watch<MasterProfileProvider>();
    final labels = switch (language) {
      AppLanguage.tk => [
        'Adyňyz',
        'Lakamyňyz',
        'Telefon belgiňiz',
        'Salgysy',
        'Özüňiz barada',
        'Instagram (islege görä)',
        'TikTok (islege görä)',
      ],
      AppLanguage.ru => [
        'Имя',
        'Никнейм',
        'Телефон',
        'Адрес',
        'О себе',
        'Instagram (необязательно)',
        'TikTok (необязательно)',
      ],
      AppLanguage.en => [
        'Name',
        'Nickname',
        'Phone number',
        'Address',
        'About you',
        'Instagram (optional)',
        'TikTok (optional)',
      ],
    };
    const icons = [
      Icons.person_outline,
      Icons.account_box_outlined,
      Icons.phone_outlined,
      Icons.location_on_outlined,
      Icons.edit_outlined,
      Icons.link_outlined,
      Icons.link_outlined,
    ];
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  PhotoUploadBox(
                    file: _banner ?? profile.banner,
                    onPicked: (file) => setState(() => _banner = file),
                    title: t(
                      tk: 'Banner suraty',
                      ru: 'Фото баннера',
                      en: 'Banner photo',
                    ),
                    hint: t(
                      tk: 'Profiliň ýokarsynda görner',
                      ru: 'Отображается наверху профиля',
                      en: 'Shown at the top of the profile',
                    ),
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: AvatarPicker(
                      file: profile.avatar,
                      onPicked: (file) =>
                          context.read<MasterProfileProvider>().setAvatar(file),
                      radius: 46,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(labels.length, (index) {
                    final nicknameError =
                        index == _nicknameIndex && _nicknameTaken;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(text: labels[index]),
                          const SizedBox(height: 7),
                          TextField(
                            controller: _controllers[index],
                            maxLines: index == 4 ? 3 : 1,
                            onChanged: index == _nicknameIndex
                                ? (_) => _checkNickname()
                                : null,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              errorText: nicknameError
                                  ? t(
                                      tk: 'Bu lakam eýesiz däl',
                                      ru: 'Этот никнейм уже занят',
                                      en: 'This nickname is already taken',
                                    )
                                  : null,
                              prefixIconConstraints:
                                  const BoxConstraints.tightFor(
                                    width: 44,
                                    height: 44,
                                  ),
                              prefixIcon: SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(
                                  child: AppIcon(
                                    icons[index],
                                    color: nicknameError
                                        ? tokens.danger
                                        : tokens.textPrimary,
                                    size: 18,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: tokens.surfaceElevated,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 15,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: tokens.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: tokens.accent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: tokens.border),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        pageRoute(
                          _MasterProfilePreviewScreen(
                            name: _controllers[0].text.trim(),
                            nickname: _controllers[1].text.trim().replaceFirst(
                              '@',
                              '',
                            ),
                            address: _controllers[3].text.trim(),
                            about: _controllers[4].text.trim(),
                            instagram: _controllers[5].text.trim(),
                            tiktok: _controllers[6].text.trim(),
                            avatar: profile.avatar,
                            banner: _banner ?? profile.banner,
                          ),
                        ),
                      ),
                      child: Text(
                        t(
                          tk: 'Profili önizle',
                          ru: 'Предпросмотр профиля',
                          en: 'Preview profile',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MasterActionButton(
                    label: t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save'),
                    enabled: !_nicknameTaken,
                    leading: Icons.save_outlined,
                    onTap: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
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
    required this.banner,
  });
  final String name;
  final String nickname;
  final String address;
  final String about;
  final String instagram;
  final String tiktok;
  final File? avatar;
  final File? banner;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const AppIcon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(t(tk: 'Önizleme', ru: 'Предпросмотр', en: 'Preview')),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ClipRRect(
              child: banner != null
                  ? Image.file(
                      banner!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xffE6D2B1),
                        backgroundImage: avatar != null
                            ? FileImage(avatar!)
                            : null,
                        child: avatar == null
                            ? AppIcon(
                                Icons.person_outline,
                                size: 32,
                                color: tokens.textPrimary,
                              )
                            : null,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty
                              ? t(tk: 'Ady ýok', ru: 'Без имени', en: 'No name')
                              : name,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '@${nickname.isEmpty ? "nickname" : nickname}',
                          style: TextStyle(color: tokens.textSecondary),
                        ),
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              AppIcon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: tokens.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                address,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (about.isNotEmpty) ...[
                    Text(
                      t(tk: 'Hakynda', ru: 'О себе', en: 'About'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      about,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (instagram.isNotEmpty || tiktok.isNotEmpty) ...[
                    Text(
                      t(
                        tk: 'Sosial ulgamlar',
                        ru: 'Соцсети',
                        en: 'Social media',
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (instagram.isNotEmpty)
                      _MetaLine(
                        icon: Icons.camera_alt_outlined,
                        text: instagram,
                      ),
                    if (instagram.isNotEmpty && tiktok.isNotEmpty)
                      const SizedBox(height: 6),
                    if (tiktok.isNotEmpty)
                      _MetaLine(icon: Icons.music_note_outlined, text: tiktok),
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
