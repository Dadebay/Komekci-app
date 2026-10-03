import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/client_models.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/client_repository.dart';

/// The client's masters: pending requests and accepted connections, plus
/// the exact-match search used to find a new one.
class ClientMastersProvider extends SessionScoped {
  ClientMastersProvider(this._repository);

  final ClientRepository _repository;

  List<ClientConnection> _connections = const [];
  bool _loading = false;
  ApiException? _error;

  List<ClientConnection> get connections => List.unmodifiable(_connections);
  List<ClientConnection> get accepted => [
    for (final c in _connections)
      if (c.status == ConnectionStatus.accepted) c,
  ];
  List<ClientConnection> get pending => [
    for (final c in _connections)
      if (c.status == ConnectionStatus.pending) c,
  ];

  /// The master the client books with by default.
  ClientConnection? get active {
    for (final c in accepted) {
      if (c.active) return c;
    }
    return null;
  }

  bool get loading => _loading;
  ApiException? get error => _error;

  @override
  void reset() {
    _connections = const [];
    _loading = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (!me.isMaster) await load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _connections = await _repository.connections();
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading connections failed: $e');
    }
    _loading = false;
    notifyListeners();
  }

  /// Exact nickname/phone match; null when [query] is too short. Throws
  /// `MASTER_NOT_FOUND` (404) when nothing matches.
  Future<MasterBrief?> lookup(String query) => _repository.lookupMaster(query.trim());

  Future<ClientConnection> connect(int masterId) async {
    final connection = await _repository.connect(masterId);
    _connections = [
      for (final c in _connections)
        if (c.id != connection.id) c,
      connection,
    ];
    notifyListeners();
    return connection;
  }

  Future<void> setActive(int connectionId) async {
    await _repository.setActiveConnection(connectionId);
    await load();
  }

  Future<void> remove(int connectionId) async {
    await _repository.removeConnection(connectionId);
    _connections = [
      for (final c in _connections)
        if (c.id != connectionId) c,
    ];
    notifyListeners();
  }
}
