import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/master_models.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/master_repository.dart';

/// Clients asking to connect to this master (`/me/connection-requests`).
class ConnectionRequestsProvider extends SessionScoped {
  ConnectionRequestsProvider(this._repository);

  final MasterRepository _repository;

  List<ConnectionRequest> _requests = const [];
  bool _loading = false;
  bool _loaded = false;
  ApiException? _error;

  /// True once a load has succeeded since sign-in.
  bool get loaded => _loaded;
  List<ConnectionRequest> get requests => List.unmodifiable(_requests);
  int get count => _requests.length;
  bool get loading => _loading;
  ApiException? get error => _error;

  @override
  void reset() {
    _requests = const [];
    _loading = false;
    _loaded = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (me.isMaster) await load();
  }

  /// [silent] is for background refreshes: no loading flag, no error state
  /// and listeners (so the screens) are only notified when the list changed.
  Future<void> load({bool silent = false}) async {
    if (_loading) return;
    _loading = true;
    if (!silent) {
      _error = null;
      notifyListeners();
    }
    var changed = !silent;
    try {
      final fresh = await _repository.connectionRequests();
      if (silent) {
        changed =
            !_loaded ||
            fresh.length != _requests.length ||
            [for (final r in fresh) r.id].toString() !=
                [for (final r in _requests) r.id].toString();
      }
      _requests = fresh;
      _loaded = true;
    } on ApiException catch (e) {
      if (!silent) _error = e;
      debugPrint('Loading connection requests failed: $e');
    }
    _loading = false;
    if (changed) notifyListeners();
  }

  /// Accepts the request; the client joins the master's client list.
  Future<void> accept(int id) async {
    await _repository.acceptConnectionRequest(id);
    _remove(id);
  }

  Future<void> decline(int id) async {
    await _repository.declineConnectionRequest(id);
    _remove(id);
  }

  void _remove(int id) {
    _requests = [
      for (final r in _requests)
        if (r.id != id) r,
    ];
    notifyListeners();
  }
}
