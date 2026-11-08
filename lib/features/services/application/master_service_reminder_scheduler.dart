import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/services/local_notifications_service.dart';

/// One local reminder, three days after a master completes registration.
/// The deadline is stored per account so signing in again never restarts it.
class MasterServiceReminderScheduler {
  MasterServiceReminderScheduler({
    LocalNotificationsService? notifications,
    FlutterSecureStorage? storage,
    DateTime Function()? now,
  }) : _notifications = notifications ?? LocalNotificationsService.instance,
       _storage = storage ?? const FlutterSecureStorage(),
       _now = now ?? DateTime.now;

  final LocalNotificationsService _notifications;
  final FlutterSecureStorage _storage;
  final DateTime Function() _now;
  Future<void> _queue = Future<void>.value();

  static const _prefix = 'komekci:master-service-reminder:';
  static const _storagePrefix = 'komekci.master_service_reminder.';
  static const _delay = Duration(days: 3);

  Future<void> registered({required int masterId, required String locale}) =>
      _enqueue(() async {
        final key = '$_storagePrefix$masterId';
        final saved = int.tryParse(await _storage.read(key: key) ?? '');
        if (saved == null) {
          await _storage.write(
            key: key,
            value: _now().add(_delay).toUtc().millisecondsSinceEpoch.toString(),
          );
        }
        await _sync(masterId: masterId, hasServices: false, locale: locale);
      });

  /// Reconcile with the server's service list, or cancel after a saved service.
  Future<void> sync({
    required int? masterId,
    required bool hasServices,
    required String locale,
  }) => _enqueue(
    () => _sync(masterId: masterId, hasServices: hasServices, locale: locale),
  );

  Future<void> _sync({
    required int? masterId,
    required bool hasServices,
    required String locale,
  }) async {
    final payload = masterId == null ? null : '$_prefix$masterId';
    final pending = await _notifications.pending();
    var alreadyScheduled = false;
    for (final request in pending) {
      if (request.payload?.startsWith(_prefix) != true) continue;
      if (request.payload != payload || hasServices) {
        await _notifications.cancel(request.id);
      } else {
        alreadyScheduled = true;
      }
    }
    if (masterId == null) return;
    final key = '$_storagePrefix$masterId';
    if (hasServices) {
      await _storage.delete(key: key);
      return;
    }
    final deadlineMillis = int.tryParse(await _storage.read(key: key) ?? '');
    if (deadlineMillis == null || alreadyScheduled) return;
    final when = DateTime.fromMillisecondsSinceEpoch(
      deadlineMillis,
      isUtc: true,
    );
    if (!when.isAfter(_now().toUtc())) return;
    final (title, body) = switch (locale) {
      'ru' => (
        'Добавьте свою услугу',
        'Добавьте услугу в Kömekçi и начните пользоваться приложением.',
      ),
      'en' => (
        'Add your service',
        'Add a service in Kömekçi and start using the app.',
      ),
      _ => (
        'Hyzmatyňyzy goşuň',
        'Kömekçide hyzmatyňyzy goşuň we programmanyň mümkinçiliklerinden peýdalanyň.',
      ),
    };
    await _notifications.scheduleMasterServiceReminder(
      id: _notificationId(payload!),
      title: title,
      body: body,
      when: when,
      payload: payload,
    );
  }

  Future<void> _enqueue(Future<void> Function() task) {
    final result = _queue.then((_) => task());
    _queue = result.catchError((Object error, StackTrace stack) {
      debugPrint('Master service reminder sync failed: $error');
    });
    return result;
  }
}

int _notificationId(String payload) {
  var hash = 0x811c9dc5;
  for (final unit in payload.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
  }
  return 100000 + hash % (0x7fffffff - 100000);
}
