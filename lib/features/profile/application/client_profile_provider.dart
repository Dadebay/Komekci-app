import 'dart:io';

import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/me_repository.dart';

/// The signed-in client's own profile — single source of truth for
/// everywhere their name/phone/photo appear (home greeting, profile tab,
/// edit form). Mirrors `GET /me`; [sync] keeps it in step with the account
/// held by `AuthProvider`.
class ClientProfileProvider extends SessionScoped {
  ClientProfileProvider({
    required MeRepository me,
    required void Function(Me) onMeChanged,
  }) : _me = me,
       _onMeChanged = onMeChanged;

  final MeRepository _me;
  final void Function(Me) _onMeChanged;

  String _name = '';
  String _nickname = '';
  String _phone = '';
  String? _avatarUrl;
  File? _avatar;

  String get name => _name;
  String get nickname => _nickname;

  /// `+993XXXXXXXX`.
  String get phone => _phone;
  String? get avatarUrl => _avatarUrl;

  /// Just-picked photo, shown until the upload lands.
  File? get avatar => _avatar;

  void sync(Me? me) {
    onSession(me);
    if (me == null || me.isMaster) return;
    _name = me.name;
    _nickname = me.nickname;
    _phone = me.phone;
    _avatarUrl = me.photoUrl;
    Future.microtask(notifyListeners);
  }

  @override
  void reset() {
    _name = _nickname = _phone = '';
    _avatarUrl = null;
    _avatar = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {}

  /// Uploads a new profile photo right away (`PATCH /me`, multipart).
  Future<void> setAvatar(File file) async {
    _avatar = file;
    notifyListeners();
    try {
      _onMeChanged(await _me.updateMe(photoPath: file.path));
      _avatar = null;
    } catch (_) {
      _avatar = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Saves the name (and nickname when given). Throws `ApiException`.
  Future<void> save({String? name, String? nickname}) async {
    final me = await _me.updateMe(
      name: name != null && name != _name ? name : null,
      nickname: nickname != null && nickname != _nickname ? nickname : null,
    );
    _onMeChanged(me);
  }
}
