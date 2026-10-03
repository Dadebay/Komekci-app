import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/me_repository.dart';

/// The notification feed: the server inbox (`/me/notifications`) plus pushes
/// received while the app is open. A push is shown at once and replaced by
/// its inbox row after the next [load].
class NotificationProvider extends SessionScoped {
  NotificationProvider(this._repository);

  final MeRepository _repository;

  List<AppNotification> _items = const [];
  String? _cursor;
  bool _loading = false;
  bool _loadingMore = false;
  ApiException? _error;

  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.read).length;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _cursor != null;
  ApiException? get error => _error;

  @override
  void reset() {
    _items = const [];
    _cursor = null;
    _loading = _loadingMore = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) => load();

  /// Newest page of the inbox. Local-only pushes that the inbox does not
  /// (yet) contain stay on top.
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _repository.notifications();
      final server = page.items.map(AppNotification.fromApi).toList();
      final localOnly = [
        for (final n in _items)
          if (n.serverId == null &&
              !server.any((s) => s.title == n.title && s.body == n.body))
            n,
      ];
      _items = [...localOnly, ...server];
      _cursor = page.nextCursor;
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading notifications failed: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    final cursor = _cursor;
    if (cursor == null || _loadingMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final page = await _repository.notifications(cursor: cursor);
      _items = [..._items, ...page.items.map(AppNotification.fromApi)];
      _cursor = page.nextCursor;
    } on ApiException catch (e) {
      debugPrint('Loading more notifications failed: $e');
    }
    _loadingMore = false;
    notifyListeners();
  }

  /// A push arrived while the app was open.
  void add({required String title, required String body, Map<String, dynamic> data = const {}}) {
    _items = [
      AppNotification(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        receivedAt: DateTime.now(),
        data: data,
      ),
      ..._items,
    ];
    notifyListeners();
    // Fetch the server's own copy (it carries the id and payload).
    load();
  }

  Future<void> markRead(String id) async {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1 || _items[index].read) return;
    final item = _items[index];
    _items = [..._items]..[index] = item.copyWith(read: true);
    notifyListeners();
    final serverId = item.serverId;
    if (serverId == null) return;
    try {
      await _repository.markNotificationRead(serverId);
    } on ApiException catch (e) {
      debugPrint('Marking notification read failed: $e');
    }
  }

  Future<void> markAllRead() async {
    final unread = _items.where((n) => !n.read).toList();
    if (unread.isEmpty) return;
    _items = [for (final n in _items) n.copyWith(read: true)];
    notifyListeners();
    for (final n in unread) {
      final serverId = n.serverId;
      if (serverId == null) continue;
      try {
        await _repository.markNotificationRead(serverId);
      } on ApiException catch (e) {
        debugPrint('Marking notification read failed: $e');
        return;
      }
    }
  }
}
