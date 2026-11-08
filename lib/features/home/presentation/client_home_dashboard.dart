part of '../../../app/komekci_app.dart';

/// Client's "Baş sahypa" tab — greeting header, service search, category
/// shortcuts, an upcoming-bookings preview and a master carousel.
class ClientHomeDashboard extends StatelessWidget {
  const ClientHomeDashboard({super.key});

  Future<void> _refresh(BuildContext context) async {
    final bookings = context.read<ClientBookingsProvider>();
    final masters = context.read<ClientMastersProvider>();
    final notifications = context.read<NotificationProvider>();
    await Future.wait<void>([
      bookings.load(),
      masters.load(),
      notifications.load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final canPop = Navigator.of(context).canPop();
    final upcoming = context
        .watch<ClientBookingsProvider>()
        .upcoming
        .take(3)
        .toList();
    return Scaffold(
      backgroundColor: tokens.surface,
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 14, 20, canPop ? 20 : 110),
            children: [
              const _ClientHomeHeader(),
              const SizedBox(height: 18),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  pageRoute(const ConnectMasterScreen()),
                ),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Row(
                    children: [
                      AppIcon(
                        Icons.search,
                        size: 22,
                        color: tokens.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t(
                            tk: 'Masteri lakamy ýa-da telefony boýunça tap',
                            ru: 'Найти мастера по никнейму или телефону',
                            en: 'Find a master by nickname or phone',
                          ),
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _SectionHeader(
                title: t(
                  tk: 'Meniň ýazgylarym',
                  ru: 'Мои записи',
                  en: 'My bookings',
                ),
                actionLabel: t(
                  tk: 'Ähli ýazgylar',
                  ru: 'Все записи',
                  en: 'All bookings',
                ),
                onAction: () => Navigator.push(
                  context,
                  pageRoute(const ClientBookingsScreen()),
                ),
              ),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: t(
                    tk: 'Ýazgy ýok',
                    ru: 'Записей нет',
                    en: 'No bookings',
                  ),
                  text: t(
                    tk: 'Master saýlap ýazylyň.',
                    ru: 'Выберите мастера и запишитесь.',
                    en: 'Choose a master and book an appointment.',
                  ),
                )
              else
                _ClientBookingsListCard(bookings: upcoming, tk: tk),
              const SizedBox(height: 22),
              _SectionHeader(
                title: t(
                  tk: 'Meniň masterlarym',
                  ru: 'Мои мастера',
                  en: 'My masters',
                ),
                actionLabel: t(
                  tk: 'Ähli masterlar',
                  ru: 'Все мастера',
                  en: 'All masters',
                ),
                onAction: () => Navigator.push(
                  context,
                  pageRoute(const ClientMastersScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _ClientMasterCarousel(tk: tk),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientHomeHeader extends StatelessWidget {
  const _ClientHomeHeader();

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    final profile = context.watch<ClientProfileProvider>();
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final greeting = pickTr(language, tk: 'Salam', ru: 'Привет', en: 'Hello');
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: _flatTintDecoration(tokens, tokens.accent),
      child: Row(
        children: [
          // The ring and white gap frame the photo, so a busy picture still
          // reads as a clean circle.
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.surface,
              border: Border.all(color: tokens.accent, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: tokens.accent.withValues(alpha: .25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: RoundPhoto(
              file: profile.avatar,
              url: profile.avatarUrl,
              radius: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting 👋',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  displayPhone(profile.phone),
                  style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              pageRoute(const ClientNotificationSettingsScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tokens.border.withValues(alpha: .7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.textPrimary.withValues(alpha: .06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AppIcon(
                    Icons.notifications_none,
                    size: 21,
                    color: tokens.textPrimary,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.surface, width: 1.5),
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: tokens.accent,
                ),
              ),
              AppIcon(Icons.chevron_right, size: 15, color: tokens.accent),
            ],
          ),
        ),
      ],
    );
  }
}
