import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:komekci/core/theme/app_theme_tokens.dart';
import 'package:komekci/core/theme/theme_provider.dart';
import 'package:komekci/shared/widgets/glass_nav_bar.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('theme change updates the active bottom navigation slot', (
    tester,
  ) async {
    final theme = ThemeProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: theme,
        child: Builder(
          builder: (context) => MaterialApp(
            theme: buildThemeData(
              tokensFor(context.watch<ThemeProvider>().selected),
            ),
            home: Scaffold(
              bottomNavigationBar: GlassNavBar(
                docked: true,
                icons: const [
                  HugeIcons.strokeRoundedHome03,
                  HugeIcons.strokeRoundedUserCircle,
                ],
                labels: const ['Home', 'Profile'],
                currentIndex: 1,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(_hasSelectedPill(tester, ivoryTokens.accent), isTrue);
    theme.select(KomekciTheme.onyx);
    await tester.pumpAndSettle();
    expect(_hasSelectedPill(tester, onyxTokens.accent), isTrue);
    theme.select(KomekciTheme.rose);
    await tester.pumpAndSettle();
    expect(_hasSelectedPill(tester, roseTokens.accent), isTrue);
  });
}

bool _hasSelectedPill(WidgetTester tester, Color color) => tester.any(
  find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.constraints?.maxWidth == 52 &&
        widget.decoration is BoxDecoration &&
        (widget.decoration! as BoxDecoration).color == color,
  ),
);
