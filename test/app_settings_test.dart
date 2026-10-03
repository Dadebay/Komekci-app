import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:komekci/core/localization/language_provider.dart';
import 'package:komekci/data/models/app_settings.dart';
import 'package:komekci/data/repositories/settings_repository.dart';
import 'package:komekci/features/app/application/app_settings_provider.dart';

const _payload = {
  'subscription_price': '20.00',
  'currency': 'TMT',
  'support_contact': '',
  'locales': ['tk', 'ru', 'en'],
};

void main() {
  test('parses the public settings payload', () {
    final settings = AppSettings.fromJson(_payload);
    expect(settings.subscriptionPrice, 20.0);
    expect(settings.currency, 'TMT');
    expect(settings.locales, AppLanguage.values);
  });

  test('ignores locales the app has no translations for', () {
    final settings = AppSettings.fromJson({
      ..._payload,
      'locales': ['ru', 'de'],
    });
    expect(settings.locales, [AppLanguage.ru]);
  });

  test('provider loads from the API and labels the currency', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/settings/public');
      return http.Response(jsonEncode(_payload), 200);
    });
    final provider = AppSettingsProvider(
      repository: SettingsRepository(client: client),
    );
    await provider.load();
    expect(provider.loaded, isTrue);
    expect(provider.monthlyFee, 20);
    expect(provider.currencyLabel(AppLanguage.tk), 'manat');
    expect(provider.currencyLabel(AppLanguage.en), 'TMT');
  });

  test('provider keeps fallback values when the request fails', () async {
    final provider = AppSettingsProvider(
      repository: SettingsRepository(
        client: MockClient((_) async => http.Response('boom', 500)),
      ),
    );
    await provider.load();
    expect(provider.loaded, isFalse);
    expect(provider.monthlyFee, 20);
    expect(provider.locales, AppLanguage.values);
  });
}
