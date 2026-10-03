part of '../../../app/komekci_app.dart';

/// Notification feed and, for clients, the three notification switches the
/// API knows (`reminders`, `earlier_slot`, `master_messages` on
/// `PATCH /me` → `notification_prefs`). Masters see the feed only — their
/// `N-01`…`N-19` switches have no screen yet.
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
            padding: EdgeInsets.fromLTRB(20, 8, 20, canPop ? 20 : 110),
            children: [
              if (auth.isMaster) ...[
                _MasterNotificationTypes(
                  prefs: prefs,
                  onChanged: (code, value) => _setPref(context, prefs, code, value),
                ),
                const SizedBox(height: 24),
              ],
              if (!auth.isMaster) ...[
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
                    tk: 'Usta habarlary',
                    ru: 'Сообщения мастера',
                    en: 'Master messages',
                  ),
                  subtitle: t(
                    tk: 'Ussalardan gelýän habarlar',
                    ru: 'Сообщения от ваших мастеров',
                    en: 'Messages from your masters',
                  ),
                  value: pref('master_messages'),
                  onChanged: (value) => _setPref(context, prefs, 'master_messages', value),
                ),
                const SizedBox(height: 24),
              ],
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
                notifications.loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
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

/// The master's `N-01`…`N-19` switches (`notification_prefs`). Only the
/// subscription ones (13–19) are described by the API docs; the rest are
/// shown by code.
class _MasterNotificationTypes extends StatelessWidget {
  const _MasterNotificationTypes({required this.prefs, required this.onChanged});
  final Map<String, bool> prefs;
  final void Function(String code, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final known = <String, String>{
      'N-13': t(tk: 'Abuna tölegi çykaryldy', ru: 'Списание за подписку', en: 'Subscription charged'),
      'N-14': t(tk: 'Töleg ýatlatmasy (1)', ru: 'Напоминание об оплате (1)', en: 'Payment reminder (1)'),
      'N-15': t(tk: 'Töleg ýatlatmasy (2)', ru: 'Напоминание об оплате (2)', en: 'Payment reminder (2)'),
      'N-16': t(tk: 'Töleg ýatlatmasy (3)', ru: 'Напоминание об оплате (3)', en: 'Payment reminder (3)'),
      'N-17': t(tk: 'Abuna duruzyldy', ru: 'Подписка приостановлена', en: 'Subscription suspended'),
      'N-18': t(tk: 'Abuna ýene işjeň', ru: 'Подписка снова активна', en: 'Subscription active again'),
      'N-19': t(tk: 'Balans dolduryldy', ru: 'Баланс пополнен', en: 'Balance topped up'),
    };
    final codes = [for (var i = 1; i <= 19; i++) 'N-${i.toString().padLeft(2, '0')}'];
    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            t(tk: 'Bildiriş görnüşleri', ru: 'Типы уведомлений', en: 'Notification types'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          children: [
            for (final code in codes)
              SwitchListTile(
                dense: true,
                activeThumbColor: tokens.accent,
                title: Text(
                  known[code] ?? '${t(tk: 'Bildiriş', ru: 'Уведомление', en: 'Notification')} $code',
                  style: const TextStyle(fontSize: 13),
                ),
                value: prefs[code] ?? true,
                onChanged: (value) => onChanged(code, value),
              ),
          ],
        ),
      ),
    );
  }
}
