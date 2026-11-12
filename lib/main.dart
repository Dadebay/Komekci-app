import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app/komekci_app.dart';

export 'app/komekci_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the screen on while the app is open; the system lifts this by
  // itself when the app goes to the background.
  WakelockPlus.enable().catchError((Object _) {});
  runApp(const KomekciApp());
}
