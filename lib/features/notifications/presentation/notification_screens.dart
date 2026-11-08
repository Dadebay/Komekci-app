part of '../../../app/komekci_app.dart';

/// A single received push notification's card — see [NotificationProvider].
/// Rendered inline within [ClientNotificationSettingsScreen]'s "Recent
/// notifications" section.
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final unread = !notification.read;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: unread
            ? Color.alphaBlend(
                tokens.accent.withValues(alpha: .045),
                tokens.surfaceElevated,
              )
            : Color.alphaBlend(
                tokens.textPrimary.withValues(alpha: .06),
                tokens.surface,
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: unread
                ? tokens.accent.withValues(alpha: .3)
                : tokens.textPrimary.withValues(alpha: .12),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.read<NotificationProvider>().markRead(notification.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: unread
                        ? tokens.accent.withValues(alpha: .14)
                        : tokens.surface,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    unread
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_none,
                    size: 18,
                    color: unread ? tokens.accent : tokens.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: unread
                                    ? tokens.textPrimary
                                    : tokens.textSecondary,
                              ),
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 5, left: 8),
                              decoration: BoxDecoration(
                                color: tokens.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: tokens.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatNotificationTime(notification.receivedAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.textSecondary,
                        ),
                      ),
                      if (_waitlistOfferId(notification)
                          case final offerId?) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: tokens.textPrimary,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                              ),
                              onPressed: () => runApi(
                                context,
                                () => context
                                    .read<ClientBookingsProvider>()
                                    .acceptWaitlistOffer(offerId),
                              ),
                              child: Text(
                                pickTr(
                                  context.read<LanguageProvider>().language,
                                  tk: 'Kabul et',
                                  ru: 'Принять',
                                  en: 'Accept',
                                ),
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                                side: BorderSide(color: tokens.border),
                              ),
                              onPressed: () => runApi(
                                context,
                                () => context
                                    .read<ClientBookingsProvider>()
                                    .declineWaitlistOffer(offerId),
                              ),
                              child: Text(
                                pickTr(
                                  context.read<LanguageProvider>().language,
                                  tk: 'Ret et',
                                  ru: 'Отказаться',
                                  en: 'Decline',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatNotificationTime(DateTime time) {
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');
  return '${formatDate(time)} · $hh:$mm';
}

/// Id of a "better time freed up" offer carried by a notification, if any.
/// The API documents `POST /waitlist/{id}/accept|decline` but not the
/// notification payload; `waitlist_id` / `waitlist_offer_id` are the keys
/// expected there.
int? _waitlistOfferId(AppNotification n) {
  for (final key in const ['waitlist_id', 'waitlist_offer_id']) {
    final raw = n.data[key];
    final id = raw is num ? raw.toInt() : int.tryParse('$raw');
    if (id != null) return id;
  }
  return null;
}
