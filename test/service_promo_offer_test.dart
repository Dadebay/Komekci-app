import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/app/komekci_app.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/core/theme/app_theme_tokens.dart';
import 'package:komekci/data/repositories/billing_repository.dart';
import 'package:komekci/data/repositories/master_repository.dart';
import 'package:komekci/features/app/application/app_settings_provider.dart';
import 'package:komekci/features/billing/application/billing_provider.dart';
import 'package:komekci/features/services/application/service_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('adding a service offers the free month without activating it', (
    tester,
  ) async {
    var promoPosts = 0;
    final api = ApiClient(
      baseUrl: 'https://example.test/api',
      tokenStore: MemoryTokenStore(),
      client: MockClient((request) async {
        if (request.url.path == '/api/me/billing') {
          return http.Response(
            jsonEncode({
              'balance': '0.00',
              'subscription_price': '20.00',
              'subscription_status': 'suspended',
              'accepting_bookings': false,
              'promo': {
                'code': 'promo_available',
                'eligible': true,
                'used': false,
                'active': false,
                'paid_access': false,
                'topup_required': true,
              },
            }),
            200,
          );
        }
        if (request.url.path == '/api/me/billing/transactions') {
          return http.Response('{"data":[],"next_cursor":null}', 200);
        }
        if (request.url.path == '/api/me/promo' && request.method == 'POST') {
          promoPosts++;
        }
        return http.Response('{}', 404);
      }),
    );
    await api.saveSession(
      const AuthTokens(access: 'access', refresh: 'refresh'),
    );
    final billingRepository = BillingRepository(api);
    final billing = BillingProvider(billingRepository);
    await billing.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<BillingRepository>.value(value: billingRepository),
          ChangeNotifierProvider<BillingProvider>.value(value: billing),
          ChangeNotifierProvider(
            create: (_) => ServiceProvider(MasterRepository(api)),
          ),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: MaterialApp(
          theme: buildThemeData(goldTokens),
          home: const ServicesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(promoPosts, 0);

    await tester.tap(find.text('Täze hyzmat goş'));
    await tester.pumpAndSettle();
    expect(find.text('1 aý mugt'), findsOneWidget);
    expect(promoPosts, 0);

    await tester.tap(find.text('Soň'));
    await tester.pumpAndSettle();
    expect(find.byType(ServiceFormScreen), findsNothing);
    expect(promoPosts, 0);
    api.close();
  });
}
