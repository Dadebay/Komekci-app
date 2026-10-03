import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/device_registrar.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/me_repository.dart';

enum UserRole { client, master }

enum AuthStep { signedOut, otpSent, signedIn }

/// What [AuthProvider.restoreSession] found on app start.
enum SessionRestore { signedIn, none, offline }

/// The signed-in account and everything about getting in and out of it:
/// sign-up, SMS code, token restore at launch, sign-out.
///
/// [role] doubles as the shell being shown. For a signed-in account it is
/// always the account's own role — the API has no way for one account to act
/// as both.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required ApiClient api,
    required AuthRepository auth,
    required MeRepository meRepository,
    required DeviceRegistrar devices,
  }) : _api = api,
       _auth = auth,
       _meRepository = meRepository,
       _devices = devices {
    _api.onSessionExpired = _handleSessionExpired;
  }

  final ApiClient _api;
  final AuthRepository _auth;
  final MeRepository _meRepository;
  final DeviceRegistrar _devices;

  UserRole _role = UserRole.client;
  AuthStep _step = AuthStep.signedOut;
  Me? _me;

  UserRole get role => _role;
  AuthStep get step => _step;
  bool get isMaster => _role == UserRole.master;
  bool get isSignedIn => _step == AuthStep.signedIn && _me != null;

  /// The account from `GET /me`; null until signed in.
  Me? get me => _me;

  /// Fired after the refresh token was rejected and the session is gone, so
  /// the app can send the user back to sign-in.
  VoidCallback? onSessionLost;

  /// The role chosen on the role screen. Ignored once signed in.
  void chooseRole(UserRole value) {
    if (isSignedIn) return;
    _role = value;
    notifyListeners();
  }

  /// Looks for saved tokens and validates them with `GET /me`.
  Future<SessionRestore> restoreSession() async {
    if (!await _api.restoreSession()) return SessionRestore.none;
    try {
      await refreshMe();
      return SessionRestore.signedIn;
    } on ApiException catch (e) {
      if (e.isNetwork) return SessionRestore.offline;
      return SessionRestore.none;
    }
  }

  /// Creates the account and sends the first SMS code.
  Future<void> register(RegistrationData data) async {
    await _auth.register(data);
    _step = AuthStep.otpSent;
    notifyListeners();
  }

  /// Sign-in code for an existing account.
  Future<void> requestOtp(String phone) async {
    await _auth.requestOtp(phone);
    _step = AuthStep.otpSent;
    notifyListeners();
  }

  /// Confirms the code, loads the account and switches the app to its role.
  Future<Me> verifyOtp(String phone, String code) async {
    await _auth.verifyOtp(phone, code);
    return refreshMe();
  }

  Future<Me> refreshMe() async {
    final me = await _meRepository.me();
    _setMe(me);
    return me;
  }

  /// Applies an updated account returned by a `PATCH /me`-style call.
  void applyMe(Me me) {
    _setMe(me);
  }

  void _setMe(Me me) {
    final firstTime = _me == null;
    _me = me;
    _role = me.isMaster ? UserRole.master : UserRole.client;
    _step = AuthStep.signedIn;
    if (firstTime) unawaited(_devices.onSignedIn(me.id));
    notifyListeners();
  }

  /// Revokes the session on the server (best effort) and clears it locally.
  Future<void> signOut() async {
    await _devices.onSigningOut();
    try {
      await _auth.logout();
    } on ApiException catch (error) {
      debugPrint('Logout request failed: $error');
    }
    _clear();
  }

  /// Step 1 of changing the phone number: SMS to the new number.
  Future<void> requestPhoneChange(String phone) =>
      _meRepository.requestPhoneChange(phone);

  /// Step 2: confirms the SMS code; the account now carries the new number.
  Future<void> confirmPhoneChange(String phone, String code) async {
    _setMe(await _meRepository.verifyPhoneChange(phone, code));
  }

  /// Saves the interface language/theme on the account so other devices pick
  /// them up. Best effort — the local choice already took effect.
  Future<void> savePreferences({String? locale, String? theme}) async {
    if (!isSignedIn) return;
    if ((locale == null || locale == _me!.locale) &&
        (theme == null || theme == _me!.theme)) {
      return;
    }
    try {
      _setMe(await _meRepository.updateMe(locale: locale, theme: theme));
    } on ApiException catch (error) {
      debugPrint('Saving preferences failed: $error');
    }
  }

  /// Saves notification switches: `reminders` / `earlier_slot` /
  /// `master_messages` for clients, `N-01`…`N-19` for masters. Throws
  /// `ApiException` so the caller can undo its switch.
  Future<void> updateNotificationPrefs(Map<String, bool> prefs) async {
    _setMe(await _meRepository.updateMe(notificationPrefs: prefs));
  }

  /// Deletes the account for good (`DELETE /me`).
  Future<void> deleteAccount() async {
    await _devices.onSigningOut();
    await _meRepository.deleteAccount();
    _clear();
  }

  void _handleSessionExpired() {
    _clear();
    onSessionLost?.call();
  }

  void _clear() {
    _me = null;
    _step = AuthStep.signedOut;
    _role = UserRole.client;
    notifyListeners();
  }
}
