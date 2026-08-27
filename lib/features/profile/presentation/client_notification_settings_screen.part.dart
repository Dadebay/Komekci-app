part of '../../../app/komekci_app.dart';

/// Notification *preferences* — distinct from [NotificationProvider], which
/// holds the actual received-message feed. There's no backend to persist
/// these to, so they live in a session-scoped notifier the same way
/// [_favoriteMasterIds] does; the master switch gates the two category
/// switches below it, matching how a real push-permission toggle would work.
class ClientNotificationPrefs {
  const ClientNotificationPrefs({
    this.pushEnabled = true,
    this.bookingReminders = true,
    this.promotions = false,
  });

  final bool pushEnabled;
  final bool bookingReminders;
  final bool promotions;

  ClientNotificationPrefs copyWith({
    bool? pushEnabled,
    bool? bookingReminders,
    bool? promotions,
  }) => ClientNotificationPrefs(
    pushEnabled: pushEnabled ?? this.pushEnabled,
    bookingReminders: bookingReminders ?? this.bookingReminders,
    promotions: promotions ?? this.promotions,
  );
}

final _clientNotificationPrefs = ValueNotifier<ClientNotificationPrefs>(
  const ClientNotificationPrefs(),
);

/// Merges what used to be two separate destinations — "Bildiriş sazlamalary"
/// (preferences) and the [NotificationProvider] feed — into one scrollable
/// page: toggles up top, the actual received notifications below them.
class ClientNotificationSettingsScreen extends StatelessWidget {
  const ClientNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final notifications = context.watch<NotificationProvider>();
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Bildirişler', ru: 'Уведомления', en: 'Notifications'),
        action: notifications.unreadCount == 0
            ? null
            : TextButton(
                onPressed: () =>
                    context.read<NotificationProvider>().markAllRead(),
                child: Text(
                  t(
                    tk: 'Ählisini okal',
                    ru: 'Прочитать все',
                    en: 'Mark all read',
                  ),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: tokens.accent,
                  ),
                ),
              ),
      ),
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<ClientNotificationPrefs>(
          valueListenable: _clientNotificationPrefs,
          builder: (context, prefs, _) => ListView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, canPop ? 20 : 110),
            children: [
              _NotificationPrefRow(
                icon: Icons.notifications_none,
                title: t(
                  tk: 'Push bildirişler',
                  ru: 'Push-уведомления',
                  en: 'Push notifications',
                ),
                subtitle: t(
                  tk: 'Ähli bildirişleriň esasy açary',
                  ru: 'Главный переключатель всех уведомлений',
                  en: 'Master switch for every notification below',
                ),
                value: prefs.pushEnabled,
                onChanged: (value) => _clientNotificationPrefs.value = prefs
                    .copyWith(pushEnabled: value),
              ),
              const SizedBox(height: 4),
              Opacity(
                opacity: prefs.pushEnabled ? 1 : .4,
                child: IgnorePointer(
                  ignoring: !prefs.pushEnabled,
                  child: Column(
                    children: [
                      _NotificationPrefRow(
                        icon: Icons.calendar_month_outlined,
                        title: t(
                          tk: 'Duşuşyk ýatlatmalary',
                          ru: 'Напоминания о записи',
                          en: 'Booking reminders',
                        ),
                        subtitle: t(
                          tk: 'Duşuşykdan öň habar ber',
                          ru: 'Уведомлять перед визитом',
                          en: 'Notify me before my appointment',
                        ),
                        value: prefs.bookingReminders,
                        onChanged: (value) => _clientNotificationPrefs.value =
                            prefs.copyWith(bookingReminders: value),
                      ),
                      _NotificationPrefRow(
                        icon: Icons.star_border,
                        title: t(
                          tk: 'Aksiýalar',
                          ru: 'Акции и скидки',
                          en: 'Promotions',
                        ),
                        subtitle: t(
                          tk: 'Ussalardan täze teklipler',
                          ru: 'Новые предложения от мастеров',
                          en: 'New offers from masters you follow',
                        ),
                        value: prefs.promotions,
                        onChanged: (value) => _clientNotificationPrefs.value =
                            prefs.copyWith(promotions: value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t(
                  tk: 'Soňky bildirişler',
                  ru: 'Последние уведомления',
                  en: 'Recent notifications',
                ),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (notifications.items.isEmpty)
                EmptyState(
                  icon: Icons.notifications_none,
                  title: t(
                    tk: 'Heniz bildiriş ýok',
                    ru: 'Уведомлений пока нет',
                    en: 'No notifications yet',
                  ),
                  text: t(
                    tk: 'Täze bildirişler şu ýerde peýda bolar.',
                    ru: 'Новые уведомления появятся здесь.',
                    en: 'New notifications will appear here.',
                  ),
                )
              else
                ...notifications.items.map(
                  (n) => _NotificationCard(notification: n),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationPrefRow extends StatelessWidget {
  const _NotificationPrefRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeThumbColor: tokens.accent,
        secondary: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tokens.accent.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: AppIcon(icon, color: tokens.accent, size: 17),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
