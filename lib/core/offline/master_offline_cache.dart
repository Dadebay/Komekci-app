import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Last successful master GET responses, kept in the device's secure store.
/// Cache entries are only used after a request fails because of connectivity.
class MasterOfflineCache extends ChangeNotifier {
  MasterOfflineCache({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _prefix = 'komekci.offline_master.v1.';
  static const _meKey = '${_prefix}me';

  int? _masterId;
  final Set<String> _staleKeys = {};

  bool get usingCachedData => _staleKeys.isNotEmpty;

  Future<Object?> read(String path, Map<String, Object?>? query) async {
    if (path != '/me' && !_canCache(path)) return null;
    try {
      if (path == '/me') {
        final raw = await _storage.read(key: _meKey);
        if (raw == null) return null;
        final body = jsonDecode(raw);
        final id = _masterIdOf(body);
        if (id == null) return null;
        _masterId = id;
        _markCached(_meKey);
        return body;
      }
      final id = _masterId;
      if (id == null) return null;
      final key = _key(id, path, query);
      final raw = await _storage.read(key: key);
      if (raw == null) return null;
      final body = jsonDecode(raw);
      _markCached(key);
      return body;
    } catch (error) {
      debugPrint('Reading offline master data failed: $error');
      return null;
    }
  }

  Future<void> write(
    String path,
    Map<String, Object?>? query,
    Object? body,
  ) async {
    if (path != '/me' && !_canCache(path)) return;
    try {
      if (path == '/me') {
        final id = _masterIdOf(body);
        if (id == null) {
          _masterId = null;
          await _storage.delete(key: _meKey);
          _markLive(_meKey);
          return;
        }
        _masterId = id;
        await _storage.write(key: _meKey, value: jsonEncode(body));
        _markLive(_meKey);
      } else {
        final id = _masterId;
        if (id == null) return;
        final key = _key(id, path, query);
        await _storage.write(key: key, value: jsonEncode(body));
        _markLive(key);
      }
    } catch (error) {
      // A storage failure must never turn a successful API response into an error.
      debugPrint('Saving offline master data failed: $error');
    }
  }

  /// Called when the user signs out, deletes the account, or starts a new
  /// token session. iOS Keychain entries can survive reinstall, so remove all
  /// master snapshots explicitly rather than relying on app uninstall.
  Future<void> clear() async {
    _masterId = null;
    final hadCachedData = _staleKeys.isNotEmpty;
    _staleKeys.clear();
    if (hadCachedData) notifyListeners();
    try {
      final values = await _storage.readAll();
      for (final key in values.keys.toList()) {
        if (key.startsWith(_prefix)) await _storage.delete(key: key);
      }
    } catch (error) {
      debugPrint('Clearing offline master data failed: $error');
    }
  }

  bool _canCache(String path) => path.startsWith('/me/');

  int? _masterIdOf(Object? body) {
    final outer = body is Map<String, dynamic> ? body : null;
    final data = outer?['data'];
    final me = data is Map<String, dynamic> ? data : outer;
    if (me?['role'] != 'master') return null;
    final rawId = me?['id'];
    final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId');
    return id != null && id > 0 ? id : null;
  }

  String _key(int id, String path, Map<String, Object?>? query) {
    final params = <String, String>{};
    final paramsSource = query ?? const <String, Object?>{};
    final keys = paramsSource.keys.toList()..sort();
    for (final key in keys) {
      final value = paramsSource[key];
      if (value != null) params[key] = '$value';
    }
    final request = Uri(
      path: path,
      queryParameters: params.isEmpty ? null : params,
    ).toString();
    return '$_prefix$id.${base64Url.encode(utf8.encode(request))}';
  }

  void _markCached(String key) {
    if (_staleKeys.add(key)) notifyListeners();
  }

  void _markLive(String key) {
    if (_staleKeys.remove(key)) notifyListeners();
  }
}
