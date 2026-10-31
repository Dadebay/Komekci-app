import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/data/models/api/billing_models.dart';
import 'package:komekci/data/repositories/billing_repository.dart';

void main() {
  test(
    'promo code can come from its endpoint and activation uses an install id',
    () async {
      final requests = <http.Request>[];
      final api = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: MemoryTokenStore(),
        client: MockClient((request) async {
          requests.add(request);
          if (request.url.path == '/api/me/billing') {
            return http.Response(
              jsonEncode({
                'balance': '0.00',
                'subscription_price': '20.00',
                'subscription_status': 'suspended',
                'accepting_bookings': false,
              }),
              200,
            );
          }
          if (request.url.path == '/api/me/promo' && request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'code': 'promo_available',
                'eligible': true,
                'used': false,
                'active': false,
                'paid_access': false,
                'topup_required': true,
              }),
              200,
            );
          }
          if (request.url.path == '/api/me/promo' && request.method == 'POST') {
            return http.Response(
              jsonEncode({
                'code': 'promo_active',
                'eligible': false,
                'used': true,
                'active': true,
                'paid_access': false,
                'topup_required': false,
                'days_left': 31,
              }),
              200,
            );
          }
          return http.Response('{}', 404);
        }),
      );
      await api.saveSession(
        const AuthTokens(access: 'access', refresh: 'refresh'),
      );
      final repository = BillingRepository(api);

      final summary = await repository.billing();
      expect(summary.promo?.isAvailable, true);
      expect(summary.permitsMasterEntry, true);
      expect(requests.map((r) => r.url.path), [
        '/api/me/billing',
        '/api/me/promo',
      ]);

      const installId = 'install-12345678';
      final activated = await repository.activatePromo(installId);
      expect(activated.active, true);
      expect(requests.last.headers['Authorization'], 'Bearer access');
      expect(jsonDecode(requests.last.body), {'device_id': installId});
      api.close();
    },
  );

  test(
    'card top-up sends the selected bank and checks the transaction',
    () async {
      final requests = <http.Request>[];
      final api = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: MemoryTokenStore(),
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'POST') {
            return http.Response(
              jsonEncode({
                'card_transaction_id': 15,
                'bank_order_id': 'bank-order',
                'form_url': 'https://bank.test/pay',
                'amount': '40.00',
                'balance': '0.00',
                'subscription_status': 'suspended',
                'status': 'unfinished',
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'card_transaction_id': 15,
              'status': 'success',
              'amount': '40.00',
              'balance': '40.00',
              'subscription_status': 'active',
            }),
            200,
          );
        }),
      );
      await api.saveSession(
        const AuthTokens(access: 'access', refresh: 'refresh'),
      );
      final billing = BillingRepository(api);

      for (final bank in CardBank.values) {
        final topup = await billing.topUpCard(40, bank);
        expect(topup.cardTransactionId, 15);
        expect(topup.formUrl, 'https://bank.test/pay');
        final request = requests.last;
        expect(request.url.path, '/api/me/billing/topup');
        expect(request.headers['Authorization'], 'Bearer access');
        expect(jsonDecode(request.body), {
          'amount': 40,
          'method': 'card',
          'bank': bank.apiValue,
        });
      }

      final status = await billing.cardStatus(15);
      expect(status.status, CardPaymentStatus.success);
      expect(requests.last.url.path, '/api/me/billing/cards/15');
      expect(requests.last.headers['Authorization'], 'Bearer access');
    },
  );
}
