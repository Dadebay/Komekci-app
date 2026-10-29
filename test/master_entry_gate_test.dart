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
import 'package:komekci/data/models/api/billing_models.dart';
import 'package:komekci/data/models/api/user_models.dart';
import 'package:komekci/data/repositories/auth_repository.dart';
import 'package:komekci/data/repositories/billing_repository.dart';
import 'package:komekci/data/repositories/me_repository.dart';
import 'package:komekci/features/app/application/app_settings_provider.dart';
import 'package:komekci/features/auth/application/auth_provider.dart';
import 'package:komekci/features/billing/application/billing_provider.dart';
import 'package:provider/provider.dart';

void main() {
  test('master entry accepts positive balance or a paid subscription', () {
    Billing billing(double balance, SubscriptionStatus status) => Billing(
      balance: balance,
      subscriptionPrice: 20,
      status: status,
      acceptingBookings: status == SubscriptionStatus.active,
    );

    expect(billing(0, SubscriptionStatus.suspended).permitsMasterEntry, false);
    expect(billing(1, SubscriptionStatus.suspended).permitsMasterEntry, true);
    // The server can charge the first month immediately, leaving zero balance.
    expect(billing(0, SubscriptionStatus.active).permitsMasterEntry, true);
    expect(billing(0, SubscriptionStatus.grace).permitsMasterEntry, true);
  });

  testWidgets('restored unpaid master returns to the payment screen', (
    tester,
  ) async {
    var billingCalls = 0;
    final api = ApiClient(
      baseUrl: 'https://example.test/api',
      tokenStore: MemoryTokenStore(),
      client: MockClient((request) async {
        if (request.url.path == '/api/me/billing') {
          billingCalls++;
          return http.Response(
            jsonEncode({
              'balance': '0.00',
              'subscription_price': '20.00',
              'subscription_status': 'suspended',
              'accepting_bookings': false,
              'payment_methods': ['mobile', 'card'],
              'phone': null,
            }),
            200,
          );
        }
        if (request.url.path == '/api/me/billing/transactions') {
          return http.Response('{"data":[],"next_cursor":null}', 200);
        }
        if (request.url.path == '/api/auth/logout') {
          return http.Response('{}', 200);
        }
        return http.Response('{}', 404);
      }),
    );
    await api.saveSession(
      const AuthTokens(access: 'access', refresh: 'refresh'),
    );
    final repository = BillingRepository(api);
    const master = Me(
      id: 15,
      role: ApiRole.master,
      name: 'Master',
      nickname: 'master',
      phone: '+99365000000',
      locale: 'tk',
      theme: 'ivory',
    );
    final meRepository = MeRepository(api);
    final auth = AuthProvider(
      api: api,
      auth: AuthRepository(api),
      meRepository: meRepository,
      devices: DeviceRegistrar(meRepository, tokenSource: () async => null),
    )..applyMe(master);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<BillingRepository>.value(value: repository),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider(create: (_) => BillingProvider(repository)),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: MaterialApp(home: homeForAccount(master)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MasterSubscriptionScreen), findsOneWidget);
    expect(find.byType(MasterHome), findsNothing);
    final beforeResume = billingCalls;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(billingCalls, greaterThan(beforeResume));
    expect(find.byType(MasterSubscriptionScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Başga hasaba geçmelimi?'), findsOneWidget);
    await tester.tap(find.text('Ýatyr'));
    await tester.pumpAndSettle();
    expect(find.byType(MasterSubscriptionScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Başga hasaba geçmelimi?'), findsOneWidget);
    await tester.tap(find.text('Çyk'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(RoleScreen), findsOneWidget);
    expect(auth.isSignedIn, false);
    api.close();
  });
}
