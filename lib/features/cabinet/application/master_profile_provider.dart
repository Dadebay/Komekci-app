import 'dart:io';

import 'package:flutter/foundation.dart';

/// The signed-in master's own profile — single source of truth for
/// everywhere their name/nickname/photo appear (cabinet home card, profile
/// edit form, dashboard greeting). Previously these were three separate
/// hardcoded/local copies that could drift out of sync with each other.
class MasterProfileProvider extends ChangeNotifier {
  String _name = 'Anna';
  String _nickname = 'anna_master';
  String _phone = '+993 65 123456';
  String _address = 'Aşgabat, Büzmeýin etraby';
  String _about = 'Saç ussasy · 6 ýyl tejribe';
  String _instagram = '';
  String _tiktok = '';
  File? _avatar;
  File? _banner;

  String get name => _name;
  String get nickname => _nickname;
  String get phone => _phone;
  String get address => _address;
  String get about => _about;
  String get instagram => _instagram;
  String get tiktok => _tiktok;
  File? get avatar => _avatar;
  File? get banner => _banner;

  void setAvatar(File file) {
    _avatar = file;
    notifyListeners();
  }

  void setBanner(File file) {
    _banner = file;
    notifyListeners();
  }

  void update({
    required String name,
    required String nickname,
    required String phone,
    required String address,
    required String about,
    String instagram = '',
    String tiktok = '',
  }) {
    _name = name;
    _nickname = nickname;
    _phone = phone;
    _address = address;
    _about = about;
    _instagram = instagram;
    _tiktok = tiktok;
    notifyListeners();
  }
}
