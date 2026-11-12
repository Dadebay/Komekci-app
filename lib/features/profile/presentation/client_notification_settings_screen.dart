part of '../../../app/komekci_app.dart';

/// Notification feed with client and master notification preferences.
class ClientNotificationSettingsScreen extends StatelessWidget {
  const ClientNotificationSettingsScreen({super.key});

  Future<void> _setPref(
    BuildContext context,
    Map<String, bool> current,
    String key,
    bool value,
  ) async {
    final auth = context.read<AuthProvider>();
    await runApi(
      context,
      () => auth.updateNotificationPrefs({...current, key: value}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final notifications = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();
    final prefs = auth.me?.notificationPrefs ?? const <String, bool>{};
    bool pref(String key) => prefs[key] ?? true;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.profileNotifications.select(language),
        action: notifications.unreadCount == 0
            ? null
            : TextButton(
                onPressed: () =>
                    context.read<NotificationProvider>().markAllRead(),
                child: Text(
                  AppStrings.profileMarkAllRead.select(language),
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
                  title: AppStrings.profileBookingReminders.select(language),
                  subtitle: AppStrings.profileRemindMeOneHourBefore.select(
                    language,
                  ),
                  value: pref('reminders'),
                  onChanged: (value) =>
                      _setPref(context, prefs, 'reminders', value),
                ),
                _NotificationPrefRow(
                  icon: Icons.schedule_outlined,
                  title: AppStrings.profileEarlierSlots.select(language),
                  subtitle: AppStrings.profileTellMeWhenAnEarlier.select(
                    language,
                  ),
                  value: pref('earlier_slot'),
                  onChanged: (value) =>
                      _setPref(context, prefs, 'earlier_slot', value),
                ),
                _NotificationPrefRow(
                  icon: Icons.chat_bubble_outline,
                  title: AppStrings.profileMasterMessages.select(language),
                  subtitle: AppStrings.profileMessagesFromYourMasters.select(
                    language,
                  ),
                  value: pref('master_messages'),
                  onChanged: (value) =>
                      _setPref(context, prefs, 'master_messages', value),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.profileRecentNotifications.select(language),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                  if (notifications.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.accent.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${notifications.unreadCount} ${AppStrings.profileNew.select(language)}',
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
                        title: AppStrings.profileCouldNotLoadNotifications
                            .select(language),
                        text: AppStrings.profileCheckYourConnectionAndTry
                            .select(language),
                        retryLabel: AppStrings.profileTryAgain.select(language),
                        onRetry: notifications.load,
                      )
                    : EmptyState(
                        icon: Icons.notifications_none,
                        title: AppStrings.profileNoNotificationsYet.select(
                          language,
                        ),
                        text: AppStrings.profileNewNotificationsWillAppearHere
                            .select(language),
                      )
              else ...[
                ...notifications.items.map(
                  (n) => _NotificationCard(notification: n),
                ),
                if (notifications.hasMore)
                  TextButton(
                    onPressed: notifications.loadingMore
                        ? null
                        : notifications.loadMore,
                    child: Text(
                      notifications.loadingMore
                          ? AppStrings.billingLoading.select(language)
                          : AppStrings.billingShowMore.select(language),
                    ),
                  ),
              ],
              if (auth.isMaster) ...[
                const SizedBox(height: 28),
                Text(
                  AppStrings.profileSettings.select(language),
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
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      // ListTile needs a Material ancestor between it and the decorated
      // Container, otherwise Flutter warns that splashes may be invisible.
      child: Material(
        type: MaterialType.transparency,
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
      ),
    );
  }
}

/// One control for all of the master's `N-01`…`N-19` notification preferences.
