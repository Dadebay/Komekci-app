import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/data/repositories/billing_repository.dart';
import 'package:komekci/data/repositories/master_repository.dart';
import 'package:komekci/features/billing/application/billing_provider.dart';
import 'package:komekci/features/booking/application/booking_provider.dart';

Map<String, Object?> _appointment(int id) => {
  'id': id,
  'starts_at': '2026-10-22 11:00:00',
  'ends_at': '2026-10-22 11:30:00',
  'status': 'expected',
  'service': {'id': 1, 'name': 'Service', 'price': '50.00', 'duration_min': 30},
  'client': {'id': id, 'name': 'Client $id'},
};

void main() {
  test(
    'refreshDay re-fetches the cached month and replaces dashboard counts',
    () async {
      var calendarRequests = 0;
      final transport = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/me/calendar');
        expect(request.url.queryParameters['from'], '2026-10-01');
        expect(request.url.queryParameters['to'], '2026-10-31');
        calendarRequests++;
        final rows = switch (calendarRequests) {
          1 => [_appointment(1)],
          2 => [_appointment(1), _appointment(2)],
          _ => <Map<String, Object?>>[],
        };
        return http.Response(jsonEncode({'data': rows}), 200);
      });
      addTearDown(transport.close);
      final bookings = BookingProvider(
        MasterRepository(
          ApiClient(
            client: transport,
            tokenStore: MemoryTokenStore(),
            baseUrl: 'https://example.test',
          ),
        ),
      );
      final day = DateTime(2026, 10, 22);

      await bookings.ensureLoaded(day);
      expect(bookings.onDay(day).length, 1);

      await bookings.refreshDay(day);
      expect(bookings.onDay(day).length, 2);

      await bookings.refreshDay(day);
      expect(bookings.onDay(day), isEmpty);
      expect(calendarRequests, 3);
    },
  );

  test(
    'billing refresh replaces the visible balance from a new API response',
    () async {
      var billingRequests = 0;
      final transport = MockClient((request) async {
        expect(request.method, 'GET');
        if (request.url.path == '/me/billing/transactions') {
          return http.Response(
            jsonEncode({'data': [], 'next_cursor': null}),
            200,
          );
        }
        expect(request.url.path, '/me/billing');
        billingRequests++;
        return http.Response(
          jsonEncode({
            'data': {
              'balance': billingRequests == 1 ? '120.00' : '180.00',
              'subscription_price': '50.00',
              'subscription_status': 'active',
              'accepting_bookings': true,
            },
          }),
          200,
        );
      });
      addTearDown(transport.close);
      final billing = BillingProvider(
        BillingRepository(
          ApiClient(
            client: transport,
            tokenStore: MemoryTokenStore(),
            baseUrl: 'https://example.test',
          ),
        ),
      );

      await billing.load();
      expect(billing.balance, '120');

      await billing.refresh();
      expect(billing.balance, '180');
      expect(billingRequests, 2);
    },
  );
}
