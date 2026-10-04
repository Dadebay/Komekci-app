part of '../../../app/komekci_app.dart';

// ── Master profile (client view) ───────────────────────────────────────────

/// A connected master as the client sees them: banner, photo, address,
/// description, links and the services they offer, with a book button.
/// Loads `GET /masters/{id}` and `GET /masters/{id}/services` — both only
/// answer once the master has accepted the connection.
class MasterProfileScreen extends StatefulWidget {
  const MasterProfileScreen({super.key, required this.master});
  final MasterBrief master;

  @override
  State<MasterProfileScreen> createState() => _MasterProfileScreenState();
}

class _MasterProfileScreenState extends State<MasterProfileScreen> {
  MasterProfile? _profile;
  MasterServices? _services;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final repository = context.read<ClientRepository>();
    try {
      final results = await Future.wait<Object>([
        repository.master(widget.master.id),
        repository.masterServices(widget.master.id),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as MasterProfile;
        _services = results[1] as MasterServices;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final profile = _profile;
    final services = _services?.services.where((s) => !s.isHidden).toList() ?? const <ApiService>[];
    final accepting = _services?.acceptingBookings ?? widget.master.acceptingBookings;
    final cheapest = services.isEmpty
        ? null
        : services.map((s) => s.price).reduce((a, b) => a < b ? a : b);
    final name = profile?.name ?? widget.master.name;
    final nickname = profile?.nickname ?? widget.master.nickname;
    final address = profile?.address ?? widget.master.address;
    final links = <(IconData, String)>[
      if ((profile?.instagramUrl ?? '').isNotEmpty) (Icons.camera_alt_outlined, profile!.instagramUrl!),
      if ((profile?.tiktokUrl ?? '').isNotEmpty) (Icons.music_note_outlined, profile!.tiktokUrl!),
      for (final l in profile?.otherLinks ?? const <String>[]) (Icons.link_outlined, l),
    ];

    return Scaffold(
      backgroundColor: tokens.surface,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _MasterProfileHero(
                bannerUrl: profile?.bannerUrl,
                photoUrl: profile?.photoUrl ?? widget.master.photoUrl,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text('@$nickname', style: TextStyle(fontSize: 13.5, color: tokens.textSecondary)),
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(Icons.location_on_outlined, size: 13, color: tokens.textSecondary),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(address, style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 20),
                      RetryErrorState(
                        title: t(tk: 'Ýalňyşlyk', ru: 'Ошибка', en: 'Something went wrong'),
                        text: apiErrorMessage(_error!, language),
                        retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                        onRetry: _load,
                      ),
                    ],
                    if ((profile?.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        t(tk: 'Hakynda', ru: 'О мастере', en: 'About'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile!.description,
                        style: TextStyle(fontSize: 13, color: tokens.textSecondary, height: 1.55),
                      ),
                    ],
                    if (links.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        t(tk: 'Sosial ulgamlar', ru: 'Соцсети', en: 'Social media'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      for (final link in links)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () => launchUrl(Uri.parse(link.$2), mode: LaunchMode.externalApplication),
                            child: Row(
                              children: [
                                AppIcon(link.$1, size: 15, color: tokens.accent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    link.$2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13, color: tokens.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      t(tk: 'Hyzmatlar', ru: 'Услуги', en: 'Services'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    if (_services == null && _error == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (services.isEmpty && _error == null)
                      Text(
                        t(tk: 'Heniz hyzmat goşulmady.', ru: 'Услуги пока не добавлены.', en: 'No services yet.'),
                        style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                      )
                    else
                      ...services.map(
                        (s) => _MasterServiceRow(
                          name: s.name,
                          price: s.price,
                          minutes: s.durationMin,
                          onTap: accepting
                              ? () => Navigator.push(
                                  context,
                                  pageRoute(BookingPage(master: widget.master, preselectedServiceId: s.id)),
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _MasterProfileIconButton(icon: Icons.arrow_back, onTap: () => Navigator.maybePop(context)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  border: Border(top: BorderSide(color: tokens.border)),
                ),
                child: Row(
                  children: [
                    if (cheapest != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(tk: 'Başlangyç bahasy', ru: 'Цена от', en: 'Starting from'),
                            style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                          ),
                          Text(
                            '${formatMoney(cheapest)} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    const Spacer(),
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.textPrimary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                        ),
                        onPressed: accepting
                            ? () => Navigator.push(context, pageRoute(BookingPage(master: widget.master)))
                            : null,
                        child: Text(
                          accepting
                              ? t(tk: 'Ýazyl', ru: 'Записаться', en: 'Book')
                              : t(tk: 'Wagtlaýyn ýapyk', ru: 'Запись закрыта', en: 'Bookings paused'),
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterProfileHero extends StatelessWidget {
  const _MasterProfileHero({this.bannerUrl, this.photoUrl});
  final String? bannerUrl;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      height: 194,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xffFBF1D8), tokens.surface]),
            ),
            child: bannerUrl == null
                ? null
                : Image.network(
                    bannerUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: tokens.surface),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(BorderSide(color: tokens.accent, width: 2)),
                  ),
                  child: MasterAvatar(url: photoUrl, radius: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterProfileIconButton extends StatelessWidget {
  const _MasterProfileIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.surface.withValues(alpha: .85),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .08), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: AppIcon(icon, size: 18, color: tokens.textPrimary),
      ),
    );
  }
}

class _MasterServiceRow extends StatelessWidget {
  const _MasterServiceRow({required this.name, required this.price, required this.minutes, this.onTap});
  final String name;
  final double price;
  final int minutes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const AppIcon(Icons.schedule_outlined, size: 12, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        '$minutes ${pickTr(language, tk: 'min', ru: 'мин', en: 'min')}',
                        style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${formatMoney(price)} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: tokens.accent),
            ),
          ],
        ),
      ),
    );
  }
}
