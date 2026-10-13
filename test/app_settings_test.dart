import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:komekci/core/network/api_client.dart';
import 'package:komekci/core/theme/theme_provider.dart';
import 'package:komekci/data/models/api/master_models.dart';
import 'package:komekci/data/models/app_settings.dart';
import 'package:komekci/data/repositories/auth_repository.dart';

void main() {
  test('public settings retain only enabled choices and nullable contact', () {
    final settings = AppSettings.fromJson({
      'subscription_price': '20.00',
      'currency': 'TMT',
      'locales': ['ru', 'tk'],
      'themes': [
        {'code': 'onyx', 'enabled': true},
        {'code': 'rose', 'enabled': false},
      ],
      'contact': {'phone': ' +99361112233 ', 'email': '  '},
      'about': {'locale': 'en', 'title': 'About', 'content': 'Text'},
    });

    expect(settings.locales, [AppLanguage.ru, AppLanguage.tk]);
    expect(settings.themes, [KomekciTheme.onyx]);
    expect(settings.contact.phone, '+99361112233');
    expect(settings.contact.email, isNull);
    expect(settings.about.locale, 'en');
    expect(settings.about.title, 'About');
  });

  test('empty server choice lists remain empty', () {
    final settings = AppSettings.fromJson({'locales': [], 'themes': []});
    expect(settings.locales, isEmpty);
    expect(settings.themes, isEmpty);
  });

  test('push recipient ID is read only from account_id', () {
    final withoutAccount = ClientSummary.fromJson({
      'id': 'c12',
      'offline': false,
      'name': 'Client',
    });
    final withAccount = ClientSummary.fromJson({
      'id': 'c12',
      'account_id': 45,
      'offline': false,
      'name': 'Client',
    });
    expect(withoutAccount.accountId, isNull);
    expect(withAccount.accountId, 45);
  });

  test('one OTP request uses server retry_after', () async {
    var calls = 0;
    final api = ApiClient(
      baseUrl: 'https://example.test/api',
      client: MockClient((request) async {
        calls++;
        expect(request.method, 'POST');
        expect(request.url.path, '/api/auth/otp/request');
        return http.Response('{"status":"otp_sent","retry_after":75}', 200);
      }),
    );

    expect(await AuthRepository(api).requestOtp('+99361234567'), 75);
    expect(calls, 1);
    api.close();
  });
}
