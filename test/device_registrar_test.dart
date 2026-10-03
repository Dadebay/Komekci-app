import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/network/token_store.dart';
import 'package:komekci/core/services/device_registrar.dart';
import 'package:komekci/data/repositories/me_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> calls;
  late DeviceRegistrar registrar;
  var token = 'tok-1';

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    calls = [];
    token = 'tok-1';
    final api = ApiClient(
      tokenStore: MemoryTokenStore(),
      client: MockClient((request) async {
        calls.add('${request.method} ${request.url.path} ${request.body}');
        return http.Response(jsonEncode({'status': 'ok'}), 200);
      }),
    );
    await api.saveSession(const AuthTokens(access: 'A', refresh: 'R'));
    registrar = DeviceRegistrar(MeRepository(api), tokenSource: () async => token);
  });

  test('registers the current token on sign-in without waiting for Firebase callbacks', () async {
    await registrar.onSignedIn(12);
    expect(calls, hasLength(1));
    expect(calls.single, startsWith('POST /api/me/devices'));
    expect(jsonDecode(calls.single.split(' ').skip(2).join(' ')), containsPair('token', 'tok-1'));
  });

  test('does not resend a token the server already has, but sends a refreshed one', () async {
    await registrar.onSignedIn(12);
    await registrar.syncCurrentToken();
    expect(calls, hasLength(1));

    token = 'tok-2';
    registrar.onToken('tok-2');
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(calls, hasLength(2));
  });

  test('a token that arrives while signed out is sent once someone signs in', () async {
    registrar.onToken('tok-1');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(calls, isEmpty);
    await registrar.onSignedIn(12);
    expect(calls, hasLength(1));
  });

  test('sign-out unregisters and the next sign-in registers again', () async {
    await registrar.onSignedIn(12);
    await registrar.onSigningOut();
    expect(calls.last, startsWith('DELETE /api/me/devices'));
    await registrar.onSignedIn(13);
    expect(calls.last, startsWith('POST /api/me/devices'));
    expect(calls, hasLength(3));
  });
}
