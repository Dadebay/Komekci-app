import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/data/models/api/client_models.dart';
import 'package:komekci/data/models/api/json_helpers.dart';
import 'package:komekci/data/models/api/master_models.dart';
import 'package:komekci/data/repositories/client_repository.dart';

Map<String, Object?> appointment(String startsAt, String endsAt) => {
  'id': 8,
  'starts_at': startsAt,
  'ends_at': endsAt,
  'status': 'expected',
  'service': {
    'id': 2,
    'name': 'Service',
    'price': '200.00',
    'duration_min': 30,
  },
  'master': {'id': 2, 'name': 'Master', 'nickname': 'master'},
  'client': {'id': 1, 'name': 'Client'},
};

void main() {
  group('Appointment API time contract — Asia/Ashgabat', () {
    for (final stamps in [
      ['2026-10-19T17:00:00+05:00', '2026-10-19T17:30:00+05:00'],
      ['2026-10-19T12:00:00Z', '2026-10-19T12:30:00Z'],
      ['2026-10-19 17:00:00', '2026-10-19 17:30:00'],
    ]) {
      test('client and master show 17:00 for ${stamps.first}', () {
        final json = appointment(stamps[0], stamps[1]);
        final client = ClientAppointment.fromJson(json);
        final master = MasterAppointment.fromJson(json);

        expect(client.startsAt, DateTime(2026, 10, 19, 17));
        expect(master.startsAt, client.startsAt);
        expect(
          client.endsAt.difference(client.startsAt),
          const Duration(minutes: 30),
        );
        expect(master.endsAt, client.endsAt);
      });
    }

    test('UTC conversion preserves the next-day booking date', () {
      expect(
        parseApiTime('2026-10-18T19:30:00Z'),
        DateTime(2026, 10, 19, 0, 30),
      );
    });

    for (final response in [
      (
        start: '2026-10-19T17:00:00+05:00',
        end: '2026-10-19T17:30:00+05:00',
        hour: 17,
      ),
      (start: '2026-10-19T12:00:00Z', end: '2026-10-19T12:30:00Z', hour: 17),
      // Response observed on 2026-10-18: the selected 17:00 wall time was
      // labelled UTC by the backend. This proves the five-hour discrepancy
      // without stripping offsets, which would break valid UTC responses.
      (
        start: '2026-10-19T17:00:00+00:00',
        end: '2026-10-19T17:30:00+00:00',
        hour: 22,
      ),
    ]) {
      test('17:00 request and response ${response.start}', () async {
        final transport = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/appointments');
          expect(jsonDecode(request.body)['starts_at'], '2026-10-19 17:00:00');
          return http.Response(
            jsonEncode({'data': appointment(response.start, response.end)}),
            201,
            headers: {'content-type': 'application/json'},
          );
        });
        addTearDown(transport.close);
        final repository = ClientRepository(
          ApiClient(
            client: transport,
            tokenStore: MemoryTokenStore(),
            baseUrl: 'https://example.test',
          ),
        );

        final booked = await repository.book(
          serviceId: 2,
          startsAt: DateTime(2026, 10, 19, 17),
        );

        expect(booked.startsAt, DateTime(2026, 10, 19, response.hour));
        expect(booked.endsAt, DateTime(2026, 10, 19, response.hour, 30));
      });
    }
  });
}
