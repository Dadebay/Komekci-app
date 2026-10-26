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
      final results = await Future.wait<Object>([repository.master(widget.master.id), repository.masterServices(widget.master.id)]);
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
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final profile = _profile;
    final services = _services?.services.where((s) => !s.isHidden).toList() ?? const <ApiService>[];
    final accepting = _services?.acceptingBookings ?? widget.master.acceptingBookings;
    final cheapest = services.isEmpty ? null : services.map((s) => s.price).reduce((a, b) => a < b ? a : b);
    final name = profile?.name ?? widget.master.name;
    final nickname = profile?.nickname ?? widget.master.nickname;
    final address = profile?.address ?? widget.master.address;
    final links = <(IconData, String, String)>[
      if ((profile?.instagramUrl ?? '').isNotEmpty) (Icons.camera_alt_outlined, 'Instagram', profile!.instagramUrl!),
      if ((profile?.tiktokUrl ?? '').isNotEmpty) (Icons.music_note_outlined, 'TikTok', profile!.tiktokUrl!),
      for (final l in profile?.otherLinks ?? const <String>[]) (Icons.link_outlined, _linkHost(l), l),
    ];
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    final shortest = services.isEmpty ? null : services.map((s) => s.durationMin).reduce((a, b) => a < b ? a : b);

    Widget sectionTitle(String text, {int? count}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(color: tokens.accent, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(9)),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: tokens.surface,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _MasterProfileHero(bannerUrl: profile?.bannerUrl, photoUrl: profile?.photoUrl ?? widget.master.photoUrl),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.15),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ProfilePill(label: '@$nickname'),
                        if (address.isNotEmpty) _ProfilePill(icon: Icons.location_on_outlined, label: address),
                        _ProfilePill(
                          dotColor: accepting ? tokens.success : tokens.warning,
                          label: accepting ? t(tk: 'Ýazgy açyk', ru: 'Запись открыта', en: 'Taking bookings') : t(tk: 'Wagtlaýyn ýapyk', ru: 'Запись закрыта', en: 'Bookings paused'),
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 20),
                      RetryErrorState(
                        title: t(tk: 'Ýalňyşlyk', ru: 'Ошибка', en: 'Something went wrong'),
                        text: apiErrorMessage(_error!, language),
                        retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                        onRetry: _load,
                      ),
                    ],
                    if (_services != null) ...[
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileStat(
                              icon: Icons.content_cut,
                              caption: t(tk: 'Hyzmat', ru: 'Услуг', en: 'Services'),
                              value: '${services.length}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ProfileStat(
                              icon: Icons.payments_outlined,
                              caption: t(tk: 'Başlangyç', ru: 'От', en: 'From'),
                              value: cheapest == null ? '—' : '${formatMoney(cheapest)} $currency',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ProfileStat(
                              icon: Icons.schedule_outlined,
                              caption: t(tk: 'Iň gysga', ru: 'От', en: 'Shortest'),
                              value: shortest == null ? '—' : '$shortest ${t(tk: 'min', ru: 'мин', en: 'min')}',
                            ),
                          ),
                        ],
                      ),
                    ],
                    if ((profile?.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 28),
                      sectionTitle(t(tk: 'Hakynda', ru: 'О мастере', en: 'About')),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: _bookingCardDecoration(tokens),
                        child: Text(profile!.description, style: TextStyle(fontSize: 13.5, color: tokens.textSecondary, height: 1.6)),
                      ),
                    ],
                    if (links.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      sectionTitle(t(tk: 'Sosial ulgamlar', ru: 'Соцсети', en: 'Social media')),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final link in links)
                            GestureDetector(
                              onTap: () => launchUrl(Uri.parse(link.$3), mode: LaunchMode.externalApplication),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: tokens.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: tokens.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppIcon(link.$1, size: 16, color: tokens.accent),
                                    const SizedBox(width: 8),
                                    Text(link.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 28),
                    sectionTitle(
                      t(tk: 'Hyzmatlar', ru: 'Услуги', en: 'Services'),
                      count: _services == null ? null : services.length,
                    ),
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
                          description: s.description,
                          price: s.price,
                          minutes: s.durationMin,
                          onTap: accepting ? () => Navigator.push(context, pageRoute(BookingPage(master: widget.master, preselectedServiceId: s.id))) : null,
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
                  children: [_MasterProfileIconButton(icon: Icons.arrow_back, onTap: () => Navigator.maybePop(context))],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BookingBottomBar(
        caption: t(tk: 'Başlangyç bahasy', ru: 'Цена от', en: 'Starting from'),
        value: cheapest == null ? '—' : '${formatMoney(cheapest)} $currency',
        label: accepting ? t(tk: 'Ýazyl', ru: 'Записаться', en: 'Book') : t(tk: 'Wagtlaýyn ýapyk', ru: 'Запись закрыта', en: 'Bookings paused'),
        onPressed: accepting ? () => Navigator.push(context, pageRoute(BookingPage(master: widget.master))) : null,
      ),
    );
  }
}

/// `https://www.example.com/path` -> `example.com`.
String _linkHost(String url) {
  final host = Uri.tryParse(url)?.host ?? '';
  return (host.isEmpty ? url : host).replaceFirst('www.', '');
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.label, this.icon, this.dotColor});
  final String label;
  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border.withValues(alpha: .6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[AppIcon(icon!, size: 13, color: tokens.textSecondary), const SizedBox(width: 5)],
          if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.icon, required this.caption, required this.value});
  final IconData icon;
  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: _bookingCardDecoration(tokens),
      child: Column(
        children: [
          AppIcon(icon, size: 18, color: tokens.accent),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: tokens.textSecondary),
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
      height: 246,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 196,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              color: tokens.surfaceElevated,
              border: Border.all(color: tokens.border),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (bannerUrl != null) Image.network(bannerUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                // Keeps the back button readable on a photo banner.
                if (bannerUrl != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [tokens.textPrimary.withValues(alpha: .28), Colors.transparent, tokens.textPrimary.withValues(alpha: .12)],
                        stops: const [0, .45, 1],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.surface,
                  boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .14), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(BorderSide(color: tokens.accent, width: 2)),
                  ),
                  child: MasterAvatar(url: photoUrl, radius: 44),
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
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.surface.withValues(alpha: .92),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: AppIcon(icon, size: 19, color: tokens.textPrimary),
      ),
    );
  }
}

class _MasterServiceRow extends StatelessWidget {
  const _MasterServiceRow({required this.name, required this.price, required this.minutes, this.description = '', this.onTap});
  final String name;
  final String description;
  final double price;
  final int minutes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final bookable = onTap != null;
    return Opacity(
      opacity: bookable ? 1 : .6,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: _bookingCardDecoration(tokens),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tokens.accent.withValues(alpha: .13), borderRadius: BorderRadius.circular(15)),
                child: AppIcon(Icons.content_cut, size: 20, color: tokens.accent),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        AppIcon(Icons.schedule_outlined, size: 12, color: tokens.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '$minutes ${pickTr(language, tk: 'min', ru: 'мин', en: 'min')}',
                          style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatMoney(price)} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: tokens.accent),
                  ),
                  if (bookable) ...[const SizedBox(height: 4), AppIcon(Icons.chevron_right, size: 16, color: tokens.disabled)],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
