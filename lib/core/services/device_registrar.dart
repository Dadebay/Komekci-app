import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/repositories/me_repository.dart';

/// Keeps this device's FCM token registered with the backend
/// (`POST /me/devices`) while someone is signed in, and removes it on
/// sign-out so pushes meant for the previous account stop arriving.
///
/// Same approach as the aykitap app's `FirebaseMessagingService`:
/// - [onSignedIn] fetches the token itself, so a login right after launch
///   does not depend on the splash screen having captured it;
/// - [onToken] handles `onTokenRefresh`;
/// - the last token that actually reached the server is remembered across
///   launches, so an unchanged token is not sent again;
/// - nothing here ever throws — push registration must never get in the way
///   of signing in.
class DeviceRegistrar {
  DeviceRegistrar(
    this._repository, {
    Future<String?> Function()? tokenSource,
    FlutterSecureStorage? storage,
  }) : _tokenSource = tokenSource ?? _firebaseToken,
       _storage = storage ?? const FlutterSecureStorage();

  final MeRepository _repository;
  final Future<String?> Function() _tokenSource;
  final FlutterSecureStorage _storage;

  static const _lastSyncedKey = 'komekci.last_synced_device_token';

  String? _token;
  int? _userId;

  static Future<String?> _firebaseToken() async {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseMessaging.instance.getToken();
  }

  /// Firebase handed over (or refreshed) the device token.
  void onToken(String token) {
    _token = token;
    unawaited(_sync(token));
  }

  /// Call right after a successful sign-in / session restore.
  Future<void> onSignedIn(int userId) async {
    _userId = userId;
    await syncCurrentToken();
  }

  /// Re-sends whatever token this device currently holds (no-op when signed
  /// out or when the server already has it).
  Future<void> syncCurrentToken() async {
    try {
      final token = await _tokenSource() ?? _token;
      if (token != null) {
        _token = token;
        await _sync(token);
      }
    } catch (error) {
      debugPrint('FCM token fetch failed: $error');
    }
  }

  /// Must run *before* the session is dropped: the DELETE needs the token.
  Future<void> onSigningOut() async {
    final token = _token;
    _userId = null;
    await _remember(null);
    if (token == null) return;
    try {
      await _repository.unregisterDevice(token);
    } catch (error) {
      debugPrint('Unregistering FCM token failed: $error');
    }
  }

  Future<void> _sync(String token) async {
    final userId = _userId;
    if (userId == null) return;
    final key = '$userId:$token';
    if (await _lastSynced() == key) return;
    try {
      await _repository.registerDevice(token, Platform.isIOS ? 'ios' : 'android');
      await _remember(key);
    } catch (error) {
      debugPrint('Registering FCM token failed: $error');
    }
  }

  Future<String?> _lastSynced() async {
    try {
      return await _storage.read(key: _lastSyncedKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _remember(String? key) async {
    try {
      if (key == null) {
        await _storage.delete(key: _lastSyncedKey);
      } else {
        await _storage.write(key: _lastSyncedKey, value: key);
      }
    } catch (_) {}
  }
}
