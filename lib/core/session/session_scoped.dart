import 'package:flutter/foundation.dart';

import '../../data/models/api/user_models.dart';

/// Base for providers whose data belongs to the signed-in account.
///
/// Feed it from a `ChangeNotifierProxyProvider<AuthProvider, …>` by calling
/// [onSession] with `auth.me`: the first time a given account appears,
/// [onSignedIn] loads its data; when the account disappears (sign-out,
/// expired session) or changes, [reset] drops everything so nothing from the
/// previous account stays on screen.
abstract class SessionScoped extends ChangeNotifier {
  int? _userId;

  /// Account the data currently belongs to.
  int? get sessionUserId => _userId;

  void onSession(Me? me) {
    final id = me?.id;
    if (id == _userId) return;
    final hadUser = _userId != null;
    _userId = id;
    // Provider calls this while building; defer so listeners may notify.
    Future.microtask(() async {
      if (hadUser) {
        reset();
        notifyListeners();
      }
      if (me != null) await onSignedIn(me);
    });
  }

  /// Drop all cached data.
  @protected
  void reset();

  /// Load whatever this provider needs for [me]'s role. Must catch its own
  /// errors; it is fire-and-forget.
  @protected
  Future<void> onSignedIn(Me me);
}
