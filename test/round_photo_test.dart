import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/core/theme/app_theme_tokens.dart';
import 'package:komekci/core/theme/theme_provider.dart';
import 'package:komekci/shared/widgets/app_icon.dart';
import 'package:komekci/shared/widgets/photo_picker.dart';

void main() {
  testWidgets('a photo that fails to download shows the placeholder and throws nothing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildThemeData(tokensFor(KomekciTheme.ivory)),
        // Flutter's test HTTP client answers every request with 400, like a
        // server returning an error for a missing file.
        home: const Scaffold(body: Center(child: RoundPhoto(url: 'https://example.test/missing.jpg', radius: 30))),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.byType(AppIcon), findsOneWidget);
  });

  testWidgets('without a url or file it shows the placeholder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildThemeData(tokensFor(KomekciTheme.ivory)),
        home: const Scaffold(body: Center(child: RoundPhoto(radius: 30))),
      ),
    );
    expect(find.byType(AppIcon), findsOneWidget);
  });
}
