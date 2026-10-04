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
    return InkWell(
      onTap: () =>
          context.read<NotificationProvider>().markRead(notification.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read ? tokens.surface : tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                Icons.notifications_none,
                size: 18,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: tokens.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatNotificationTime(notification.receivedAt),
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
                  if (_waitlistOfferId(notification) case final offerId?) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: tokens.textPrimary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                          ),
                          onPressed: () => runApi(
                            context,
                            () => context.read<ClientBookingsProvider>().acceptWaitlistOffer(offerId),
                          ),
                          child: Text(pickTr(
                            context.read<LanguageProvider>().language,
                            tk: 'Kabul et',
                            ru: 'Принять',
                            en: 'Accept',
                          )),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            side: BorderSide(color: tokens.border),
                          ),
                          onPressed: () => runApi(
                            context,
                            () => context.read<ClientBookingsProvider>().declineWaitlistOffer(offerId),
                          ),
                          child: Text(pickTr(
                            context.read<LanguageProvider>().language,
                            tk: 'Ret et',
                            ru: 'Отказаться',
                            en: 'Decline',
                          )),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, left: 6),
                decoration: BoxDecoration(
                  color: tokens.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
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
