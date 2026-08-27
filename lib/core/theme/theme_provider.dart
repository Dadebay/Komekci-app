import 'package:flutter/material.dart';

enum KomekciTheme { ivory, onyx, champagne, rose }

class ThemeProvider extends ChangeNotifier {
  KomekciTheme _selected = KomekciTheme.ivory;
  KomekciTheme get selected => _selected;
  void select(KomekciTheme value) {
    _selected = value;
    notifyListeners();
  }
}
