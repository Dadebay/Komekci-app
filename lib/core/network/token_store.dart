import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokens {
  const AuthTokens({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    access: json['access_token'] as String,
    refresh: json['refresh_token'] as String,
  );
}

abstract class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

/// Keychain on iOS, Keystore-backed encrypted preferences on Android.
class SecureTokenStore implements TokenStore {
  const SecureTokenStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'komekci.access_token';
  static const _refreshKey = 'komekci.refresh_token';

  @override
  Future<AuthTokens?> read() async {
    try {
      final access = await _storage.read(key: _accessKey);
      final refresh = await _storage.read(key: _refreshKey);
      if (access == null || refresh == null) return null;
      return AuthTokens(access: access, refresh: refresh);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.access);
    await _storage.write(key: _refreshKey, value: tokens.refresh);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

class MemoryTokenStore implements TokenStore {
  AuthTokens? _tokens;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> write(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
