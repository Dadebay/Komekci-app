part of '../../../app/komekci_app.dart';

extension _CabinetProfileActions on _CabinetProfileScreenState {
  /// `GET /me/profile`, then fill in the fields the master has not touched
  /// yet — anything they already typed stays.
  Future<void> _refreshFromServer() async {
    final profile = context.read<MasterProfileProvider>();
    final before = [for (final c in _controllers) c.text];
    await profile.refresh();
    if (!mounted) return;
    final fresh = [profile.name, profile.nickname, profile.address, profile.about, profile.instagram, profile.tiktok];
    for (var i = _CabinetProfileScreenState._addressIndex; i < _controllers.length; i++) {
      if (_controllers[i].text == before[i]) _controllers[i].text = fresh[i];
    }
  }

  /// True once anything differs from what the server holds, so Save stays
  /// off until there is something to save.
  bool get _dirty {
    final p = context.read<MasterProfileProvider>();
    String text(int i) => _controllers[i].text.trim();
    return _banner != null ||
        text(_CabinetProfileScreenState._nameIndex) != p.name ||
        _enteredNickname != p.nickname.toLowerCase() ||
        text(_CabinetProfileScreenState._addressIndex) != p.address ||
        text(_CabinetProfileScreenState._aboutIndex) != p.about ||
        text(_CabinetProfileScreenState._instagramIndex) != p.instagram ||
        text(_CabinetProfileScreenState._tiktokIndex) != p.tiktok;
  }

  Future<void> _changePhone() async {
    final language = context.read<LanguageProvider>().language;
    final toast = AppToast.of(context);
    if (await showChangePhoneDialog(context)) {
      toast.success(pickTr(
              language,
              tk: 'Telefon belgisi üýtgedildi. Tölegi täze belgiden geçiriň.',
              ru: 'Номер изменён. Оплачивайте теперь с нового номера.',
              en: 'Phone number updated. Pay from the new number from now on.',
            ),);
    }
  }

  void _openPreview(MasterProfileProvider profile) {
    String text(int i) => _controllers[i].text.trim();
    Navigator.push(
      context,
      pageRoute(
        _MasterProfilePreviewScreen(
          name: text(_CabinetProfileScreenState._nameIndex),
          nickname: _enteredNickname,
          address: text(_CabinetProfileScreenState._addressIndex),
          about: text(_CabinetProfileScreenState._aboutIndex),
          instagram: text(_CabinetProfileScreenState._instagramIndex),
          tiktok: text(_CabinetProfileScreenState._tiktokIndex),
          avatar: profile.avatar,
          avatarUrl: profile.avatarUrl,
          banner: _banner ?? profile.banner,
          bannerUrl: profile.bannerUrl,
        ),
      ),
    );
  }

}
