import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/api_exception.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/data/repositories/auth_repository.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

ApiClient _client(MockClient mock, {TokenStore? store, void Function()? onExpired}) {
  final api = ApiClient(client: mock, tokenStore: store ?? MemoryTokenStore());
  api.onSessionExpired = onExpired;
  return api;
}

void main() {
  test('sends Bearer token and Accept header', () async {
    late http.BaseRequest seen;
    final api = _client(
      MockClient((req) async {
        seen = req;
        return _json({'ok': true});
      }),
    );
    await api.saveSession(const AuthTokens(access: 'A1', refresh: 'R1'));
    await api.get('/me');
    expect(seen.headers['Authorization'], 'Bearer A1');
    expect(seen.headers['Accept'], 'application/json');
    expect(seen.url.path, '/api/me');
  });

  test('omits Authorization for public calls', () async {
    late http.BaseRequest seen;
    final api = _client(
      MockClient((req) async {
        seen = req;
        return _json({'available': true, 'suggestions': []});
      }),
    );
    await api.saveSession(const AuthTokens(access: 'A1', refresh: 'R1'));
    await AuthRepository(api).nicknameAvailable('ayna');
    expect(seen.headers.containsKey('Authorization'), isFalse);
    expect(seen.url.queryParameters['nickname'], 'ayna');
  });

  test('401 refreshes once, stores the new pair and replays the call', () async {
    final calls = <String>[];
    final store = MemoryTokenStore();
    final api = _client(
      MockClient((req) async {
        calls.add('${req.method} ${req.url.path} ${req.headers['Authorization']}');
        if (req.url.path == '/api/auth/refresh') {
          expect(jsonDecode(req.body), {'refresh_token': 'R1'});
          return _json({'access_token': 'A2', 'refresh_token': 'R2', 'token_type': 'Bearer', 'expires_in': 900});
        }
        return req.headers['Authorization'] == 'Bearer A2'
            ? _json({'data': {'id': 1}})
            : _json({'error': 'UNAUTHENTICATED', 'message': 'no'}, 401);
      }),
      store: store,
    );
    await api.saveSession(const AuthTokens(access: 'A1', refresh: 'R1'));
    final body = await api.get('/me');
    expect(body, {'data': {'id': 1}});
    expect(calls, [
      'GET /api/me Bearer A1',
      'POST /api/auth/refresh null',
      'GET /api/me Bearer A2',
    ]);
    expect((await store.read())!.refresh, 'R2');
  });

  test('parallel 401s share a single refresh', () async {
    var refreshes = 0;
    final api = _client(
      MockClient((req) async {
        if (req.url.path == '/api/auth/refresh') {
          refreshes++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return _json({'access_token': 'A2', 'refresh_token': 'R2'});
        }
        return req.headers['Authorization'] == 'Bearer A2'
            ? _json({'ok': true})
            : _json({'error': 'UNAUTHENTICATED', 'message': 'x'}, 401);
      }),
    );
    await api.saveSession(const AuthTokens(access: 'A1', refresh: 'R1'));
    await Future.wait([api.get('/me'), api.get('/me/billing'), api.get('/me/services')]);
    expect(refreshes, 1);
  });

  test('rejected refresh clears the session and signals expiry', () async {
    var expired = 0;
    final store = MemoryTokenStore();
    final api = _client(
      MockClient((req) async => _json({'error': 'UNAUTHENTICATED', 'message': 'bad'}, 401)),
      store: store,
      onExpired: () => expired++,
    );
    await api.saveSession(const AuthTokens(access: 'A1', refresh: 'R1'));
    await expectLater(
      api.get('/me'),
      throwsA(isA<ApiException>().having((e) => e.isUnauthenticated, '401', isTrue)),
    );
    expect(expired, 1);
    expect(api.hasSession, isFalse);
    expect(await store.read(), isNull);
  });

  test('a network failure during refresh keeps the session', () async {
    final api = _client(
      MockClient((req) async {
        if (req.url.path == '/api/auth/refresh') throw http.ClientException('offline');
        return _json({'error': 'UNAUTHENTICATED', 'message': 'x'}, 401);
      }),
    );
    await api.saveSession(const AuthTokens(access: 'A1', refresh: 'R1'));
    await expectLater(
      api.get('/me'),
      throwsA(isA<ApiException>().having((e) => e.isNetwork, 'network', isTrue)),
    );
    expect(api.hasSession, isTrue);
  });

  test('parses the documented error body', () async {
    final api = _client(
      MockClient(
        (req) async => _json({
          'error': 'NICKNAME_TAKEN',
          'message': 'Bu lakam eýesiz däl',
          'message_tk': 'Bu lakam eýesiz däl',
          'message_ru': 'Никнейм занят',
          'message_en': 'Nickname taken',
          'details': {
            'suggestions': ['ayna1', 'ayna_tm', 'ayna07'],
          },
        }, 422),
      ),
    );
    try {
      await api.post('/auth/register', auth: false);
      fail('expected ApiException');
    } on ApiException catch (e) {
      expect(e.statusCode, 422);
      expect(e.code, ApiErrors.nicknameTaken);
      expect(e.nicknameSuggestions, ['ayna1', 'ayna_tm', 'ayna07']);
      expect(e.messages['ru'], 'Никнейм занят');
    }
  });

  test('VALIDATION details expose per-field messages', () {
    final e = ApiException.fromBody(422, {
      'error': 'VALIDATION',
      'message': 'bad',
      'details': {
        'phone': ['The phone field format is invalid.'],
      },
    });
    expect(e.fieldErrors, {'phone': 'The phone field format is invalid.'});
  });

  test('SLOT_TAKEN exposes suggested slots; RATE_LIMITED retry_after', () {
    final slot = ApiException.fromBody(409, {
      'error': 'SLOT_TAKEN',
      'message': 'x',
      'details': {
        'suggested_slots': ['10:15', '10:30'],
      },
    });
    expect(slot.suggestedSlots, ['10:15', '10:30']);
    final limited = ApiException.fromBody(429, {
      'error': 'RATE_LIMITED',
      'message': 'x',
      'details': {'retry_after': 42},
    });
    expect(limited.retryAfterSeconds, 42);
  });

  test('register sends multipart with array fields and files', () async {
    late http.Request seen;
    final api = _client(
      MockClient((req) async {
        seen = req;
        return _json({'status': 'otp_sent'}, 201);
      }),
    );
    await AuthRepository(api).register(
      const RegistrationData(
        role: 'master',
        name: 'Ayna',
        nickname: 'ayna_style',
        phone: '+99361234567',
        locale: 'tk',
        address: 'Ashgabat',
        description: 'Barber',
        otherLinks: ['https://a.example', 'https://b.example'],
      ),
    );
    expect(seen.method, 'POST');
    expect(seen.url.path, '/api/auth/register');
    expect(seen.headers['content-type'], startsWith('multipart/form-data'));
    final body = seen.body;
    expect(RegExp('name="role"\\r\\n\\r\\nmaster').hasMatch(body), isTrue);
    expect(RegExp('name="phone"\\r\\n\\r\\n\\+99361234567').hasMatch(body), isTrue);
    expect('name="other_links[]"'.allMatches(body), hasLength(2));
    expect(body.contains('name="instagram_url"'), isFalse);
  });

  test('verifyOtp stores the token pair', () async {
    final store = MemoryTokenStore();
    final api = _client(
      MockClient((req) async {
        expect(jsonDecode(req.body), {'phone': '+99361234567', 'code': '123456'});
        return _json({'access_token': 'A', 'refresh_token': 'R', 'token_type': 'Bearer', 'expires_in': 900});
      }),
      store: store,
    );
    await AuthRepository(api).verifyOtp('+99361234567', '123456');
    expect(api.hasSession, isTrue);
    expect((await store.read())!.access, 'A');
  });

  test('logout always clears the local session', () async {
    final store = MemoryTokenStore();
    final api = _client(
      MockClient((req) async => _json({'error': 'ERROR', 'message': 'down'}, 500)),
      store: store,
    );
    await api.saveSession(const AuthTokens(access: 'A', refresh: 'R'));
    await expectLater(AuthRepository(api).logout(), throwsA(isA<ApiException>()));
    expect(api.hasSession, isFalse);
    expect(await store.read(), isNull);
  });
}
