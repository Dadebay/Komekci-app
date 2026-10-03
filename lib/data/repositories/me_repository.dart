import '../../core/network/api_client.dart';
import '../models/api/client_models.dart';
import '../models/api/json_helpers.dart';
import '../models/api/user_models.dart';

/// `/me`, `/me/phone`, `/me/notifications`, `/me/devices`.
class MeRepository {
  MeRepository(this._api);
  final ApiClient _api;

  Future<Me> me() async => Me.fromJson(asMap(unwrapData(await _api.get('/me'))));

  /// Any subset of fields. A [photoPath] switches the call to multipart.
  Future<Me> updateMe({
    String? name,
    String? nickname,
    String? locale,
    String? theme,
    Map<String, bool>? notificationPrefs,
    String? photoPath,
  }) async {
    final Object? body;
    if (photoPath != null) {
      body = await _api.request(
        'PATCH',
        '/me',
        multipart: MultipartBody(
          fields: [
            if (name != null) MapEntry('name', name),
            if (nickname != null) MapEntry('nickname', nickname),
            if (locale != null) MapEntry('locale', locale),
            if (theme != null) MapEntry('theme', theme),
            if (notificationPrefs != null)
              for (final e in notificationPrefs.entries)
                MapEntry('notification_prefs[${e.key}]', e.value ? '1' : '0'),
          ],
          files: [UploadFile('photo', photoPath)],
        ),
      );
    } else {
      body = await _api.patch(
        '/me',
        json: {
          'name': ?name,
          'nickname': ?nickname,
          'locale': ?locale,
          'theme': ?theme,
          'notification_prefs': ?notificationPrefs,
        },
      );
    }
    return Me.fromJson(asMap(unwrapData(body)));
  }

  /// Step 1 of changing the phone number: sends an SMS to the new number.
  Future<void> requestPhoneChange(String phone) async {
    await _api.post('/me/phone', json: {'phone': phone});
  }

  /// Step 2: confirms the code; returns the updated account.
  Future<Me> verifyPhoneChange(String phone, String code) async {
    final body = await _api.post('/me/phone/verify', json: {'phone': phone, 'code': code});
    return Me.fromJson(asMap(unwrapData(body)));
  }

  Future<void> deleteAccount() async {
    await _api.delete('/me', json: {'confirm': true});
    await _api.clearSession();
  }

  Future<ApiPage<ApiNotification>> notifications({String? cursor}) async =>
      ApiPage.fromJson(
        await _api.get('/me/notifications', query: {'cursor': cursor}),
        ApiNotification.fromJson,
      );

  Future<void> markNotificationRead(int id) async {
    await _api.post('/me/notifications/$id/read');
  }

  /// [platform] is `android` or `ios`.
  Future<void> registerDevice(String token, String platform) async {
    await _api.post('/me/devices', json: {'token': token, 'platform': platform});
  }

  Future<void> unregisterDevice(String token) async {
    await _api.delete('/me/devices', json: {'token': token});
  }
}
