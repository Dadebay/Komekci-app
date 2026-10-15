import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/app/komekci_app.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:komekci/core/theme/app_theme_tokens.dart';
import 'package:komekci/features/app/application/app_settings_provider.dart';
import 'package:komekci/shared/utils/salon_colors.dart';
import 'package:provider/provider.dart';

void main() {
  test('Onyx calendar free slots use a dark surface', () {
    expect(freeSlotSurface(onyxTokens).computeLuminance(), lessThan(.1));
    expect(freeSlotForeground(onyxTokens), onyxTokens.success);
    expect(freeSlotSurface(ivoryTokens), freeSlotBg);
  });

  testWidgets('Onyx support hero uses a dark surface', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: MaterialApp(
          theme: buildThemeData(onyxTokens),
          home: const SupportScreen(),
        ),
      ),
    );

    final card = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Size nädip kömek edip bileris?'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (card.decoration! as BoxDecoration).color,
      onyxTokens.surfaceElevated,
    );
  });

  testWidgets('Onyx new customer info card uses a theme tint', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: MaterialApp(
          theme: buildThemeData(onyxTokens),
          home: const CustomerFormScreen(),
        ),
      ),
    );

    final card = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Täze müşderi ýazgy bilen goşulýar.'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (card.decoration! as BoxDecoration).color,
      onyxTokens.accent.withValues(alpha: .1),
    );
  });
}
