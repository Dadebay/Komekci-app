part of '../../../app/komekci_app.dart';

/// Notification feed with client and master notification preferences.
class ClientNotificationSettingsScreen extends StatelessWidget {
  const ClientNotificationSettingsScreen({super.key});

  Future<void> _setPref(BuildContext context, Map<String, bool> current, String key, bool value) async {
    final auth = context.read<AuthProvider>();
    await runApi(context, () => auth.updateNotificationPrefs({...current, key: value}));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final notifications = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();
    final prefs = auth.me?.notificationPrefs ?? const <String, bool>{};
    bool pref(String key) => prefs[key] ?? true;
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
        child: RefreshIndicator(
          onRefresh: notifications.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 8, 20, canPop ? 20 : 110),
            children: [
              if (!auth.isMaster) ...[
                _NotificationPrefRow(
                  icon: Icons.calendar_month_outlined,
                  title: t(
                    tk: 'Duşuşyk ýatlatmalary',
                    ru: 'Напоминания о записи',
                    en: 'Booking reminders',
                  ),
                  subtitle: t(
                    tk: 'Duşuşykdan 1 sagat öň ýatlat',
                    ru: 'Напомнить за час до визита',
                    en: 'Remind me one hour before my appointment',
                  ),
                  value: pref('reminders'),
                  onChanged: (value) => _setPref(context, prefs, 'reminders', value),
                ),
                _NotificationPrefRow(
                  icon: Icons.schedule_outlined,
                  title: t(
                    tk: 'Has irki wagt',
                    ru: 'Более раннее время',
                    en: 'Earlier slots',
                  ),
                  subtitle: t(
                    tk: 'Has irki wagt boşanda habar ber',
                    ru: 'Сообщать, когда освободится время пораньше',
                    en: 'Tell me when an earlier time opens up',
                  ),
                  value: pref('earlier_slot'),
                  onChanged: (value) => _setPref(context, prefs, 'earlier_slot', value),
                ),
                _NotificationPrefRow(
                  icon: Icons.chat_bubble_outline,
                  title: t(
                    tk: 'Master habarlary',
                    ru: 'Сообщения мастера',
                    en: 'Master messages',
                  ),
                  subtitle: t(
                    tk: 'Masterlerden gelýän habarlar',
                    ru: 'Сообщения от ваших мастеров',
                    en: 'Messages from your masters',
                  ),
                  value: pref('master_messages'),
                  onChanged: (value) => _setPref(context, prefs, 'master_messages', value),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t(
                        tk: 'Soňky bildirişler',
                        ru: 'Последние уведомления',
                        en: 'Recent notifications',
                      ),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                  if (notifications.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: tokens.accent.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${notifications.unreadCount} ${t(tk: 'täze', ru: 'новых', en: 'new')}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (notifications.items.isEmpty)
                notifications.loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : notifications.error != null
                        ? RetryErrorState(
                            title: t(
                              tk: 'Bildirişleri ýükläp bolmady',
                              ru: 'Не удалось загрузить уведомления',
                              en: 'Could not load notifications',
                            ),
                            text: t(
                              tk: 'Baglanyşygy barlap, täzeden synanyşyň.',
                              ru: 'Проверьте соединение и попробуйте ещё раз.',
                              en: 'Check your connection and try again.',
                            ),
                            retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                            onRetry: notifications.load,
                          )
                    : EmptyState(
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
              else ...[
                ...notifications.items.map(
                  (n) => _NotificationCard(notification: n),
                ),
                if (notifications.hasMore)
                  TextButton(
                    onPressed: notifications.loadingMore ? null : notifications.loadMore,
                    child: Text(
                      notifications.loadingMore
                          ? t(tk: 'Ýüklenýär...', ru: 'Загрузка...', en: 'Loading...')
                          : t(tk: 'Köpräk görkez', ru: 'Показать ещё', en: 'Show more'),
                    ),
                  ),
              ],
              if (auth.isMaster) ...[
                const SizedBox(height: 28),
                Text(
                  t(tk: 'Sazlamalar', ru: 'Настройки', en: 'Settings'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _MasterNotificationToggle(prefs: prefs),
              ],
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
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: tokens.textPrimary.withValues(alpha: .07),
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

/// One control for all of the master's `N-01`…`N-19` notification preferences.
