import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/api_exception.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/core/services/device_registrar.dart';
import 'package:komekci/data/repositories/auth_repository.dart';
import 'package:komekci/data/repositories/me_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'master notification sends account IDs and preserves rejected IDs',
    () async {
      final requests = <http.Request>[];
      final api = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: MemoryTokenStore(),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({
              'error': 'FORBIDDEN',
              'details': {
                'rejected': [42],
              },
            }),
            403,
          );
        }),
      );
      await api.saveSession(
        const AuthTokens(access: 'access', refresh: 'refresh'),
      );

      await expectLater(
        MeRepository(api).sendClientNotification(
          title: 'Hello',
          body: 'Appointment tomorrow',
          accountIds: [15, 42],
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.details['rejected'],
            'rejected IDs',
            [42],
          ),
        ),
      );
      expect(requests, hasLength(1));
      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/api/me/notifications/send');
      expect(requests.single.headers['Authorization'], 'Bearer access');
      expect(jsonDecode(requests.single.body), {
        'title': 'Hello',
        'body': 'Appointment tomorrow',
        'account_ids': [15, 42],
      });
    },
  );

  test('one OTP request returns the server cooldown', () async {
    var calls = 0;
    final api = ApiClient(
      baseUrl: 'https://example.test/api',
      client: MockClient((request) async {
        calls++;
        expect(request.url.path, '/api/auth/otp/request');
        expect(request.headers.containsKey('Authorization'), false);
        expect(jsonDecode(request.body), {'phone': '+99361234567'});
        return http.Response('{"status":"otp_sent","retry_after":75}', 200);
      }),
    );

    expect(await AuthRepository(api).requestOtp('+99361234567'), 75);
    expect(calls, 1);
  });

  test(
    'sign-out waits for device registration before removing its token',
    () async {
      final postStarted = Completer<void>();
      final finishPost = Completer<http.Response>();
      final methods = <String>[];
      final api = ApiClient(
        baseUrl: 'https://example.test/api',
        tokenStore: MemoryTokenStore(),
        client: MockClient((request) async {
          methods.add(request.method);
          expect(request.url.path, '/api/me/devices');
          expect(jsonDecode(request.body)['token'], 'device-token');
          if (request.method == 'POST') {
            postStarted.complete();
            return finishPost.future;
          }
          return http.Response('{"status":"ok"}', 200);
        }),
      );
      await api.saveSession(
        const AuthTokens(access: 'access', refresh: 'refresh'),
      );
      final registrar = DeviceRegistrar(
        MeRepository(api),
        tokenSource: () async => null,
      );
      await registrar.onSignedIn(15);
      registrar.onToken('device-token');
      await postStarted.future;

      final signOut = registrar.onSigningOut();
      await Future<void>.delayed(Duration.zero);
      expect(methods, ['POST']);
      finishPost.complete(http.Response('{"status":"ok"}', 200));
      await signOut;
      expect(methods, ['POST', 'DELETE']);
    },
  );
}
