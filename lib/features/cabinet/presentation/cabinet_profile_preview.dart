part of '../../../app/komekci_app.dart';

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
