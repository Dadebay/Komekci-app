import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/app/komekci_app.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/core/services/device_registrar.dart';
import 'package:komekci/core/theme/app_theme_tokens.dart';
import 'package:komekci/core/theme/theme_provider.dart';
import 'package:komekci/data/repositories/auth_repository.dart';
import 'package:komekci/data/repositories/me_repository.dart';
import 'package:komekci/features/auth/application/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('master profile form lays out on a small phone and flags missing fields', (tester) async {
    final api = ApiClient(
      tokenStore: MemoryTokenStore(),
      client: MockClient((_) async => http.Response('{"error":"NOT_FOUND","message":"x"}', 404)),
    );
    final me = MeRepository(api);
    final auth = AuthProvider(
      api: api,
      auth: AuthRepository(api),
      meRepository: me,
      devices: DeviceRegistrar(me, tokenSource: () async => null),
    );
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()..select(AppLanguage.en)),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          Provider<AuthRepository>.value(value: AuthRepository(api)),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            theme: buildThemeData(tokensFor(context.watch<ThemeProvider>().selected)),
            home: const MasterRegistrationScreen(phone: '+99365123456'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Create your profile'), findsOneWidget);

    await tester.tap(find.text('Send code'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Fill in the fields marked * to continue.'), findsOneWidget);
    expect(find.text('A profile photo is required'), findsNothing); // photo hint is the header caption, in red
    expect(find.text('This field is required'), findsWidgets);
  });
}
