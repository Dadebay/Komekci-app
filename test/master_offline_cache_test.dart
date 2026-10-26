import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/api_exception.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/core/offline/master_offline_cache.dart';
import 'package:komekci/core/services/device_registrar.dart';
import 'package:komekci/data/repositories/auth_repository.dart';
import 'package:komekci/data/repositories/master_repository.dart';
import 'package:komekci/data/repositories/me_repository.dart';
import 'package:komekci/features/auth/application/auth_provider.dart';
import 'package:komekci/features/booking/application/booking_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'master data survives a disconnected restart and is cleared on sign-out',
    () async {
      const me = {
        'data': {'id': 41, 'role': 'master', 'name': 'Master'},
      };
      const calendar = {
        'data': [
          {
            'id': 7,
            'starts_at': '2026-10-27T10:00:00+05:00',
            'ends_at': '2026-10-27T10:30:00+05:00',
            'status': 'expected',
            'service': {
              'id': 2,
              'name': 'Haircut',
              'price': '50.00',
              'duration_min': 30,
            },
            'client': {'id': 'c12', 'name': 'Aynur'},
          },
        ],
      };
      final tokenStore = MemoryTokenStore();
      final online = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: tokenStore,
        offlineCache: MasterOfflineCache(),
        client: MockClient((request) async {
          if (request.url.path == '/api/me') {
            return http.Response(jsonEncode(me), 200);
          }
          if (request.url.path == '/api/me/calendar') {
            return http.Response(jsonEncode(calendar), 200);
          }
          return http.Response('{}', 404);
        }),
      );
      await online.saveSession(
        const AuthTokens(access: 'access', refresh: 'refresh'),
        newAccount: true,
      );
      expect(await online.get('/me'), me);
      expect(
        await online.get(
          '/me/calendar',
          query: {'from': '2026-10-01', 'to': '2026-10-31'},
        ),
        calendar,
      );
      online.close();

      final cache = MasterOfflineCache();
      final offline = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: tokenStore,
        offlineCache: cache,
        client: MockClient((_) async => throw const SocketException('offline')),
      );
      final meRepository = MeRepository(offline);
      final auth = AuthProvider(
        api: offline,
        auth: AuthRepository(offline),
        meRepository: meRepository,
        devices: DeviceRegistrar(meRepository, tokenSource: () async => null),
      );
      expect(await auth.restoreSession(), SessionRestore.signedIn);
      expect(auth.me?.isMaster, isTrue);
      expect(await offline.get('/me'), me);
      expect(
        await offline.get(
          '/me/calendar',
          query: {'to': '2026-10-31', 'from': '2026-10-01'},
        ),
        calendar,
      );
      expect(cache.usingCachedData, isTrue);
      final bookings = BookingProvider(MasterRepository(offline));
      await bookings.ensureLoaded(DateTime(2026, 10, 27));
      expect(bookings.onDay(DateTime(2026, 10, 27)).single.clientName, 'Aynur');
      await expectLater(
        offline.post(
          '/me/appointments',
          json: {'starts_at': '2026-10-27 10:00:00'},
        ),
        throwsA(isA<ApiException>()),
      );
      final forbidden = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: tokenStore,
        offlineCache: cache,
        client: MockClient(
          (_) async => http.Response('{"error":"FORBIDDEN"}', 403),
        ),
      );
      await forbidden.restoreSession();
      await expectLater(
        forbidden.get(
          '/me/calendar',
          query: {'from': '2026-10-01', 'to': '2026-10-31'},
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'status',
            403,
          ),
        ),
      );
      forbidden.close();

      await offline.clearSession();
      expect(cache.usingCachedData, isFalse);
      expect(
        (await const FlutterSecureStorage().readAll()).keys.where(
          (key) => key.startsWith('komekci.offline_master.v1.'),
        ),
        isEmpty,
      );
      await offline.saveSession(
        const AuthTokens(access: 'other-access', refresh: 'other-refresh'),
        newAccount: true,
      );
      await expectLater(offline.get('/me'), throwsA(isA<ApiException>()));
      offline.close();
    },
  );

  test('a client session is not kept in the master offline cache', () async {
    final tokens = MemoryTokenStore();
    final online = ApiClient(
      baseUrl: 'https://example.test/api',
      tokenStore: tokens,
      offlineCache: MasterOfflineCache(),
      client: MockClient(
        (_) async => http.Response(
          '{"data":{"id":42,"role":"client","name":"Client"}}',
          200,
        ),
      ),
    );
    await online.saveSession(
      const AuthTokens(access: 'client-access', refresh: 'client-refresh'),
      newAccount: true,
    );
    await online.get('/me');
    online.close();

    final offline = ApiClient(
      baseUrl: 'https://example.test/api',
      tokenStore: tokens,
      offlineCache: MasterOfflineCache(),
      client: MockClient((_) async => throw const SocketException('offline')),
    );
    expect(await offline.restoreSession(), isTrue);
    await expectLater(offline.get('/me'), throwsA(isA<ApiException>()));
    offline.close();
  });

  test(
    'a newly created booking is saved for the next offline launch',
    () async {
      final tokens = MemoryTokenStore();
      const appointment = {
        'id': 91,
        'starts_at': '2026-10-27T11:00:00+05:00',
        'ends_at': '2026-10-27T11:30:00+05:00',
        'status': 'expected',
        'service': {
          'id': 2,
          'name': 'Haircut',
          'price': '50.00',
          'duration_min': 30,
        },
        'client': {'id': 'c12', 'name': 'Aynur'},
      };
      var created = false;
      final online = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: tokens,
        offlineCache: MasterOfflineCache(),
        client: MockClient((request) async {
          if (request.url.path == '/api/me') {
            return http.Response('{"data":{"id":41,"role":"master"}}', 200);
          }
          if (request.url.path == '/api/me/calendar') {
            return http.Response(
              jsonEncode({
                'data': created ? [appointment] : [],
              }),
              200,
            );
          }
          if (request.url.path == '/api/me/appointments' &&
              request.method == 'POST') {
            created = true;
            return http.Response(jsonEncode({'data': appointment}), 201);
          }
          return http.Response('{}', 404);
        }),
      );
      await online.saveSession(
        const AuthTokens(access: 'access', refresh: 'refresh'),
        newAccount: true,
      );
      await online.get('/me');
      final bookings = BookingProvider(MasterRepository(online));
      final day = DateTime(2026, 10, 27);
      await bookings.ensureLoaded(day);
      expect(bookings.onDay(day), isEmpty);
      await bookings.create(
        serviceId: 2,
        clientName: 'Aynur',
        startsAt: DateTime(2026, 10, 27, 11),
      );
      online.close();

      final offline = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: tokens,
        offlineCache: MasterOfflineCache(),
        client: MockClient((_) async => throw const SocketException('offline')),
      );
      await offline.restoreSession();
      await offline.get('/me');
      final saved = BookingProvider(MasterRepository(offline));
      await saved.ensureLoaded(day);
      expect(saved.onDay(day).single.clientName, 'Aynur');
      offline.close();
    },
  );

  test('a failed sync after booking keeps the new booking on screen', () async {
    const appointment = {
      'id': 92,
      'starts_at': '2026-10-27T12:00:00+05:00',
      'ends_at': '2026-10-27T12:30:00+05:00',
      'status': 'expected',
      'service': {
        'id': 2,
        'name': 'Haircut',
        'price': '50.00',
        'duration_min': 30,
      },
      'client': {'id': 'c13', 'name': 'Merdan'},
    };
    var created = false;
    final api = ApiClient(
      baseUrl: 'https://example.test/api',
      tokenStore: MemoryTokenStore(),
      offlineCache: MasterOfflineCache(),
      client: MockClient((request) async {
        if (request.url.path == '/api/me') {
          return http.Response('{"data":{"id":41,"role":"master"}}', 200);
        }
        if (request.url.path == '/api/me/calendar') {
          if (created) throw const SocketException('offline');
          return http.Response('{"data":[]}', 200);
        }
        if (request.url.path == '/api/me/appointments' &&
            request.method == 'POST') {
          created = true;
          return http.Response(jsonEncode({'data': appointment}), 201);
        }
        return http.Response('{}', 404);
      }),
    );
    await api.saveSession(
      const AuthTokens(access: 'access', refresh: 'refresh'),
      newAccount: true,
    );
    await api.get('/me');
    final bookings = BookingProvider(MasterRepository(api));
    final day = DateTime(2026, 10, 27);
    await bookings.ensureLoaded(day);
    await bookings.create(
      serviceId: 2,
      clientName: 'Merdan',
      startsAt: DateTime(2026, 10, 27, 12),
    );
    expect(bookings.onDay(day).single.clientName, 'Merdan');
    api.close();
  });
}
