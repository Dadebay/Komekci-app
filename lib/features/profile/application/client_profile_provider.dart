import 'dart:io';

import 'package:flutter/foundation.dart';

/// The signed-in client's own profile — single source of truth for
/// everywhere their name/phone/photo appear (home greeting, profile tab,
/// edit form), mirroring [MasterProfileProvider] on the master side so both
/// roles share the same pattern instead of drifting local copies.
class ClientProfileProvider extends ChangeNotifier {
  String _name = 'Aýjemal';
  String _phone = '+993 61 234567';
  File? _avatar;

  String get name => _name;
  String get phone => _phone;
  File? get avatar => _avatar;

  void setAvatar(File file) {
    _avatar = file;
    notifyListeners();
  }

  void update({required String name, required String phone}) {
    _name = name;
    _phone = phone;
    notifyListeners();
  }
}
