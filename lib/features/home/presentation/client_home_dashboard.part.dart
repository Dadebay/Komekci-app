part of '../../../app/komekci_app.dart';

/// Client's "Baş sahypa" tab — greeting header, service search, category
/// shortcuts, an upcoming-bookings preview and a master carousel.
class ClientHomeDashboard extends StatelessWidget {
  const ClientHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final canPop = Navigator.of(context).canPop();
    final upcoming = context.watch<ClientBookingsProvider>().upcoming.take(3).toList();
    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 14, 20, canPop ? 20 : 110),
          children: [
            const _ClientHomeHeader(),
            const SizedBox(height: 18),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context, pageRoute(const ConnectMasterScreen())),
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
                    AppIcon(Icons.search, size: 22, color: tokens.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t(tk: 'Ussany lakamy ýa-da telefony boýunça tap', ru: 'Найти мастера по никнейму или телефону', en: 'Find a master by nickname or phone'),
                        style: TextStyle(color: tokens.textSecondary, fontSize: 14),
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
              title: t(tk: 'Meniň ýazgylarym', ru: 'Мои записи', en: 'My bookings'),
              actionLabel: t(tk: 'Ähli ýazgylar', ru: 'Все записи', en: 'All bookings'),
              onAction: () => Navigator.push(context, pageRoute(const ClientBookingsScreen())),
            ),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              EmptyState(
                icon: Icons.event_busy_outlined,
                title: t(tk: 'Ýazgy ýok', ru: 'Записей нет', en: 'No bookings'),
                text: t(tk: 'Master saýlap ýazylyň.', ru: 'Выберите мастера и запишитесь.', en: 'Choose a master and book an appointment.'),
              )
            else
              _ClientBookingsListCard(bookings: upcoming, tk: tk),
            const SizedBox(height: 22),
            _SectionHeader(
              title: t(tk: 'Meniň masterlarym', ru: 'Мои мастера', en: 'My masters'),
              actionLabel: t(tk: 'Ähli masterlar', ru: 'Все мастера', en: 'All masters'),
              onAction: () => Navigator.push(context, pageRoute(const ClientMastersScreen())),
            ),
            const SizedBox(height: 12),
            _ClientMasterCarousel(tk: tk),
            const SizedBox(height: 16),
          ],
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
    final tokens = context.appTokens;
    return Row(
      children: [
        RoundPhoto(file: profile.avatar, url: profile.avatarUrl, radius: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(displayPhone(profile.phone), style: TextStyle(fontSize: 12.5, color: tokens.textSecondary)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, pageRoute(const ClientNotificationSettingsScreen())),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tokens.surfaceElevated, shape: BoxShape.circle),
                child: AppIcon(Icons.notifications_none, size: 20, color: tokens.textPrimary),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 17,
                    height: 17,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: tokens.textPrimary, shape: BoxShape.circle),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: TextStyle(fontSize: 9.5, color: tokens.surface, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel, required this.onAction});
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.accent),
              ),
              AppIcon(Icons.chevron_right, size: 15, color: tokens.accent),
            ],
          ),
        ),
      ],
    );
  }
}
