import 'package:flutter/foundation.dart';

import '../../../data/models/app_notification.dart';

/// Holds every push notification received through FCM for the lifetime of
/// the app session — [FirebaseMessagingService.onMessage] feeds this so the
/// notification bell shows real messages instead of a hardcoded badge.
class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _items = [];

  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.read).length;

  void add({required String title, required String body, Map<String, dynamic> data = const {}}) {
    _items.insert(
      0,
      AppNotification(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        receivedAt: DateTime.now(),
        data: data,
      ),
    );
    notifyListeners();
  }

  void markRead(String id) {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1 || _items[index].read) return;
    _items[index] = _items[index].copyWith(read: true);
    notifyListeners();
  }

  void markAllRead() {
    if (unreadCount == 0) return;
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(read: true);
    }
    notifyListeners();
  }
}
