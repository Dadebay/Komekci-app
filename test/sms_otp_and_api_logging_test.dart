import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/api_exception.dart';
import 'package:komekci/core/network/api_logger.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/data/repositories/auth_repository.dart';

void main() {
  test('temporary refresh rejection keeps the saved session', () async {
    final tokens = MemoryTokenStore();
    final api = ApiClient(
      baseUrl: 'https://example.test/api',
      tokenStore: tokens,
      client: MockClient((request) async {
        if (request.url.path == '/api/auth/refresh') {
          return http.Response('{"error":"RATE_LIMITED"}', 429);
        }
        return http.Response('{"error":"UNAUTHENTICATED"}', 401);
      }),
    );
    addTearDown(api.close);
    await api.saveSession(const AuthTokens(access: 'old', refresh: 'valid'));
    var expiredCallbacks = 0;
    api.onSessionExpired = () => expiredCallbacks++;

    await expectLater(
      api.get('/me'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 429)),
    );
    expect(api.hasSession, isTrue);
    expect((await tokens.read())?.refresh, 'valid');
    expect(expiredCallbacks, 0);
  });

  test('SMS challenge rejects missing required fields and invalid expiry', () {
    final response = <String, dynamic>{
      'verification_id': 'verification-1',
      'poll_secret': 'secret-1',
      'otp': '123456',
      'sms_destination': '+99361000000',
      'expires_in': 180,
    };

    expect(SmsOtpChallenge.fromJson(response).otp, '123456');
    for (final key in [
      'verification_id',
      'poll_secret',
      'otp',
      'sms_destination',
    ]) {
      final invalid = Map<String, dynamic>.of(response)..remove(key);
      expect(() => SmsOtpChallenge.fromJson(invalid), throwsFormatException);
    }
    expect(
      () => SmsOtpChallenge.fromJson({...response, 'expires_in': 0}),
      throwsFormatException,
    );
  });

  test('API diagnostics omit query values and response data', () {
    final previous = ApiLogger.enabled;
    ApiLogger.enabled = true;
    addTearDown(() => ApiLogger.enabled = previous);
    final lines = <String>[];

    runZoned(
      () => ApiLogger.log(
        method: 'POST',
        uri: Uri.parse(
          'https://example.test/api/v1/auth/otp/status?phone=secret-phone-123',
        ),
        elapsed: const Duration(milliseconds: 12),
        status: 400,
        body: utf8.encode(
          jsonEncode({'error': 'invalid_otp', 'otp': 'secret-otp-456'}),
        ),
      ),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => lines.add(line),
      ),
    );

    final output = lines.join('\n');
    expect(output, contains('/v1/auth/otp/status'));
    expect(output, contains('invalid_otp'));
    expect(output, isNot(contains('secret-phone-123')));
    expect(output, isNot(contains('secret-otp-456')));
  });
}
