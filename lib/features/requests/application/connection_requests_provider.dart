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
  ApiException? _error;

  List<ConnectionRequest> get requests => List.unmodifiable(_requests);
  int get count => _requests.length;
  bool get loading => _loading;
  ApiException? get error => _error;

  @override
  void reset() {
    _requests = const [];
    _loading = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (me.isMaster) await load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _requests = await _repository.connectionRequests();
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading connection requests failed: $e');
    }
    _loading = false;
    notifyListeners();
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
