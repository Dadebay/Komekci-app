import 'api/client_models.dart';
import '../../core/localization/app_strings.dart';

/// A notification shown in the bell/feed: either one from the server inbox
/// (`GET /me/notifications`) or a push received while the app was open.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.data = const {},
    this.read = false,
    this.eventCode = '',
    this.serverId,
  });

  /// Stable key for the UI. `n<serverId>` for inbox rows, a timestamp for
  /// pushes that have no inbox row (yet).
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, dynamic> data;
  final bool read;

  /// `N-01` … `N-19` for server-originated events.
  final String eventCode;

  /// Id on the server; null for local-only pushes.
  final int? serverId;

  factory AppNotification.fromApi(ApiNotification n) => AppNotification(
    id: 'n${n.id}',
    title: _fixWording(n.title),
    body: _fixWording(n.body),
    receivedAt: n.sentAt,
    data: n.payload,
    read: n.readAt != null,
    eventCode: n.eventCode,
    serverId: n.id,
  );

  /// The server still words appointments as "kabul" (reception); the app
  /// calls them "nobat" (turn/appointment).
  static String _fixWording(String text) {
    var result = text;
    for (final (source, replacement) in AppStrings.notificationWording) {
      result = result.replaceAll(source, replacement);
    }
    return result;
  }

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    title: title,
    body: body,
    receivedAt: receivedAt,
    data: data,
    read: read ?? this.read,
    eventCode: eventCode,
    serverId: serverId,
  );
}
