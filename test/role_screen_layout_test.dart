import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/app/komekci_app.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('role selection fits a short phone and remains scrollable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: const MaterialApp(home: RoleScreen()),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -180),
    );
    await tester.pump();
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
