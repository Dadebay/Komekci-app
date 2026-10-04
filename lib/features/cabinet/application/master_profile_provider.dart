import 'dart:io';

import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/master_repository.dart';
import '../../../data/repositories/me_repository.dart';
import '../../../shared/utils/image_url.dart';

/// The signed-in master's own profile — single source of truth for
/// everywhere their name/nickname/photo appear (cabinet home card, profile
/// edit form, dashboard greeting). Mirrors `GET /me` and `GET /me/profile`;
/// [sync] keeps it in step with the account held by `AuthProvider`.
class MasterProfileProvider extends SessionScoped {
  MasterProfileProvider({
    required MeRepository me,
    required MasterRepository master,
    required void Function(Me) onMeChanged,
  }) : _me = me,
       _master = master,
       _onMeChanged = onMeChanged;

  final MeRepository _me;
  final MasterRepository _master;
  final void Function(Me) _onMeChanged;

  String _name = '';
  String _nickname = '';
  String _phone = '';
  String _address = '';
  String _about = '';
  String _instagram = '';
  String _tiktok = '';
  List<String> _otherLinks = const [];
  String? _avatarUrl;
  String? _bannerUrl;

  /// Bumped after each upload so the replaced picture is not served from the
  /// image cache (the server reuses the same URL); see [withImageRevision].
  int _avatarRevision = 0;
  int _bannerRevision = 0;

  /// Just-picked images, shown until the upload lands and the server URL
  /// replaces them.
  File? _avatar;
  File? _banner;
  bool _saving = false;

  String get name => _name;
  String get nickname => _nickname;

  /// `+993XXXXXXXX`.
  String get phone => _phone;
  String get address => _address;
  String get about => _about;
  String get instagram => _instagram;
  String get tiktok => _tiktok;
  List<String> get otherLinks => _otherLinks;
  String? get avatarUrl => withImageRevision(_avatarUrl, _avatarRevision);
  String? get bannerUrl => withImageRevision(_bannerUrl, _bannerRevision);
  File? get avatar => _avatar;
  File? get banner => _banner;
  bool get saving => _saving;

  /// Called from the provider tree whenever the account changes.
  void sync(Me? me) {
    onSession(me);
    if (me == null || !me.isMaster) return;
    final profile = me.profile;
    _name = me.name;
    _nickname = me.nickname;
    _phone = me.phone;
    _avatarUrl = me.photoUrl;
    if (profile != null) {
      _address = profile.address;
      _about = profile.description;
      _instagram = profile.instagramUrl ?? '';
      _tiktok = profile.tiktokUrl ?? '';
      _otherLinks = profile.otherLinks;
      _bannerUrl = profile.bannerUrl;
    }
    // Called while the widget tree is building.
    Future.microtask(notifyListeners);
  }

  @override
  void reset() {
    _name = _nickname = _phone = _address = _about = '';
    _instagram = _tiktok = '';
    _otherLinks = const [];
    _avatarUrl = _bannerUrl = null;
    _avatarRevision = _bannerRevision = 0;
    _avatar = _banner = null;
    _saving = false;
  }

  @override
  Future<void> onSignedIn(Me me) async {}

  /// Re-reads the public profile from `GET /me/profile`, so the edit form
  /// opens on what the server holds rather than on the copy that came with
  /// `GET /me`. Name and nickname stay with the account (`PATCH /me`). On
  /// failure the data from `/me` stays on screen.
  Future<void> refresh() async {
    if (_saving) return;
    try {
      final profile = await _master.profile();
      if (_saving) return;
      _address = profile.address;
      _about = profile.description;
      _instagram = profile.instagramUrl ?? '';
      _tiktok = profile.tiktokUrl ?? '';
      _otherLinks = profile.otherLinks;
      _bannerUrl = profile.bannerUrl ?? _bannerUrl;
      _avatarUrl = profile.photoUrl ?? _avatarUrl;
      notifyListeners();
    } catch (_) {
      // Offline or rate limited: keep what `/me` gave us.
    }
  }

  /// Uploads a new profile photo right away (`PATCH /me`, multipart).
  Future<void> setAvatar(File file) async {
    _avatar = file;
    notifyListeners();
    try {
      final me = await _me.updateMe(photoPath: file.path);
      _avatar = null;
      _avatarRevision = newImageRevision();
      _onMeChanged(me);
    } catch (_) {
      _avatar = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Saves the whole profile form: account fields on `PATCH /me`, the public
  /// profile on `PATCH /me/profile`. Throws `ApiException` on failure.
  Future<void> save({
    required String name,
    required String nickname,
    required String address,
    required String about,
    required String instagramUrl,
    required String tiktokUrl,
    File? banner,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      final accountChanged = name != _name || nickname != _nickname;
      if (accountChanged) {
        final me = await _me.updateMe(
          name: name != _name ? name : null,
          nickname: nickname != _nickname ? nickname : null,
        );
        _onMeChanged(me);
      }
      if (banner != null) _banner = banner;
      final profile = await _master.updateProfile(
        address: address,
        description: about,
        instagramUrl: instagramUrl,
        tiktokUrl: tiktokUrl,
        bannerPath: banner?.path,
      );
      _address = profile.address;
      _about = profile.description;
      _instagram = profile.instagramUrl ?? '';
      _tiktok = profile.tiktokUrl ?? '';
      _otherLinks = profile.otherLinks;
      _bannerUrl = profile.bannerUrl ?? _bannerUrl;
      if (banner != null) _bannerRevision = newImageRevision();
      _banner = null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
