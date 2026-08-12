import 'package:flutter/foundation.dart';

enum UserRole { client, master }

enum AuthStep { signedOut, otpSent, signedIn }

class AuthProvider extends ChangeNotifier {
  UserRole _role = UserRole.client;
  AuthStep _step = AuthStep.signedOut;
  UserRole get role => _role;
  AuthStep get step => _step;
  bool get isMaster => _role == UserRole.master;

  void chooseRole(UserRole value) {
    _role = value;
    notifyListeners();
  }

  void sendOtp() {
    _step = AuthStep.otpSent;
    notifyListeners();
  }

  void verifyOtp() {
    _step = AuthStep.signedIn;
    notifyListeners();
  }

  void signOut() {
    _step = AuthStep.signedOut;
    notifyListeners();
  }
}
