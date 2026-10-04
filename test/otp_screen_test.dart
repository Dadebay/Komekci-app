import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/app/komekci_app.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/core/services/device_registrar.dart';
import 'package:komekci/core/services/sms_code_listener.dart';
import 'package:komekci/core/theme/app_theme_tokens.dart';
import 'package:komekci/core/theme/theme_provider.dart';
import 'package:komekci/data/repositories/auth_repository.dart';
import 'package:komekci/data/repositories/me_repository.dart';
import 'package:komekci/features/auth/application/auth_provider.dart';
import 'package:komekci/shared/widgets/app_icon.dart';
import 'package:provider/provider.dart';

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

void main() {
  testWidgets('typing six digits verifies the code; a wrong code shows the server error', (tester) async {
    final verified = <String>[];
    final api = ApiClient(
      tokenStore: MemoryTokenStore(),
      client: MockClient((request) async {
        if (request.url.path.endsWith('/auth/otp/verify')) {
          final code = (jsonDecode(request.body) as Map)['code'] as String;
          verified.add(code);
          return code == '123456'
              ? _json({'access_token': 'A', 'refresh_token': 'R'})
              : _json({
                  'error': 'OTP_INVALID',
                  'message': 'Kod nädogry',
                  'message_tk': 'Kod nädogry',
                  'message_ru': 'Неверный код',
                  'message_en': 'Wrong code',
                }, 422);
        }
        return _json({'error': 'NOT_FOUND', 'message': 'x'}, 404);
      }),
    );
    final me = MeRepository(api);
    final auth = AuthProvider(
      api: api,
      auth: AuthRepository(api),
      meRepository: me,
      devices: DeviceRegistrar(me, tokenSource: () async => null),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()..select(AppLanguage.en)),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            theme: buildThemeData(tokensFor(context.watch<ThemeProvider>().selected)),
            home: OtpScreen(phone: '+99365123456', nextBuilder: (_) => const SizedBox()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('+993 65 123456'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();
    expect(verified, isEmpty); // not complete yet

    await tester.enterText(find.byType(TextField), '999999');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(verified, ['999999']);
    expect(find.text('Wrong code'), findsOneWidget);
    // The field is cleared so the user can type again.
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });

  testWidgets('does not overflow on a short screen with the keyboard open', (tester) async {
    final api = ApiClient(
      tokenStore: MemoryTokenStore(),
      client: MockClient((_) async => _json({'error': 'NOT_FOUND', 'message': 'x'}, 404)),
    );
    final me = MeRepository(api);
    final auth = AuthProvider(
      api: api,
      auth: AuthRepository(api),
      meRepository: me,
      devices: DeviceRegistrar(me, tokenSource: () async => null),
    );
    // 360x640 phone with a ~300 px keyboard.
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1
      ..viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            theme: buildThemeData(tokensFor(context.watch<ThemeProvider>().selected)),
            home: OtpScreen(phone: '+99365123456', nextBuilder: (_) => const SizedBox()),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      find.byWidgetPredicate((w) => w is AppIcon && w.material == Icons.sms_outlined),
      findsOneWidget,
    );
  });

  testWidgets('a code read from the incoming SMS is entered and submitted by itself', (tester) async {
    final verified = <String>[];
    final api = ApiClient(
      tokenStore: MemoryTokenStore(),
      client: MockClient((request) async {
        if (request.url.path.endsWith('/auth/otp/verify')) {
          verified.add((jsonDecode(request.body) as Map)['code'] as String);
        }
        return _json({'error': 'OTP_INVALID', 'message': 'x'}, 422);
      }),
    );
    final me = MeRepository(api);
    final auth = AuthProvider(
      api: api,
      auth: AuthRepository(api),
      meRepository: me,
      devices: DeviceRegistrar(me, tokenSource: () async => null),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            theme: buildThemeData(tokensFor(context.watch<ThemeProvider>().selected)),
            home: OtpScreen(
              phone: '+99365123456',
              nextBuilder: (_) => const SizedBox(),
              smsListener: const _FakeSms('482913'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(verified, ['482913']);
  });
}

class _FakeSms extends SmsCodeListener {
  const _FakeSms(this.code);
  final String code;

  @override
  Future<String?> listen() async => code;

  @override
  Future<void> cancel() async {}
}
