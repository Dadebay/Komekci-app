import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/data/repositories/master_repository.dart';
import 'package:komekci/features/schedule/application/schedule_provider.dart';

void main() {
  test('master calendar loads, blocks and reopens an interval', () async {
    final requests = <http.Request>[];
    final transport = MockClient((request) async {
      requests.add(request);
      if (request.method == 'GET') {
        expect(request.url.path, '/me/closed-times');
        expect(request.url.queryParameters, {
          'from': '2026-10-28',
          'to': '2026-10-28',
        });
        return http.Response(jsonEncode({'data': []}), 200);
      }
      if (request.method == 'POST') {
        expect(request.url.path, '/me/closed-times');
        expect(jsonDecode(request.body), {
          'starts_at': '2026-10-28T14:00:00+05:00',
          'ends_at': '2026-10-28T16:00:00+05:00',
          'note': 'Личные дела',
        });
        return http.Response(
          jsonEncode({
            'data': {
              'id': 1,
              'starts_at': '2026-10-28T14:00:00+05:00',
              'ends_at': '2026-10-28T16:00:00+05:00',
              'note': 'Личные дела',
            },
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      expect(request.method, 'DELETE');
      expect(request.url.path, '/me/closed-times/1');
      return http.Response(jsonEncode({'status': 'ok'}), 200);
    });
    addTearDown(transport.close);
    final provider = ScheduleProvider(
      MasterRepository(
        ApiClient(
          client: transport,
          tokenStore: MemoryTokenStore(),
          baseUrl: 'https://example.test',
        ),
      ),
    );
    final day = DateTime(2026, 10, 28);

    await provider.loadClosedTimes(day);
    expect(provider.closedTimesLoaded(day), isTrue);
    expect(provider.closedTimesOn(day), isEmpty);

    final closed = await provider.blockTime(
      DateTime(2026, 10, 28, 14),
      DateTime(2026, 10, 28, 16),
      note: 'Личные дела',
    );
    expect(closed.startsAt, DateTime(2026, 10, 28, 14));
    expect(closed.endsAt, DateTime(2026, 10, 28, 16));
    expect(provider.closedTimesOn(day).single.note, 'Личные дела');
    expect(provider.hasClosedConflict(DateTime(2026, 10, 28, 15), 30), isTrue);
    expect(provider.hasClosedConflict(DateTime(2026, 10, 28, 16), 30), isFalse);

    await provider.reopenTime(closed);
    expect(provider.closedTimesOn(day), isEmpty);
    expect(requests.map((request) => request.method), [
      'GET',
      'POST',
      'DELETE',
    ]);
  });

  test(
    'closed intervals returned by the API appear on the selected day',
    () async {
      final transport = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'data': [
              {
                'id': 7,
                'starts_at': '2026-10-28T10:00:00+05:00',
                'ends_at': '2026-10-28T11:00:00+05:00',
                'note': null,
              },
            ],
          }),
          200,
        ),
      );
      addTearDown(transport.close);
      final provider = ScheduleProvider(
        MasterRepository(
          ApiClient(
            client: transport,
            tokenStore: MemoryTokenStore(),
            baseUrl: 'https://example.test',
          ),
        ),
      );
      final day = DateTime(2026, 10, 28);

      await provider.loadClosedTimes(day);

      expect(provider.closedTimesOn(day).single.id, 7);
      expect(
        provider.hasClosedConflict(DateTime(2026, 10, 28, 10, 30), 30),
        isTrue,
      );
    },
  );
}
