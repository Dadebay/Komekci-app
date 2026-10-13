import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/network/api_config.dart';
import '../../core/network/api_logger.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _storage;
  static const _cacheKey = 'komekci.public_settings';

  Future<AppSettings?> cached() async {
    try {
      final json = await _storage.read(key: _cacheKey);
      return json == null
          ? null
          : AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Throws on network errors, timeouts and non-200 responses.
  Future<AppSettings> fetchPublic({String locale = 'tk'}) async {
    final uri = Uri.parse(
      '$apiBaseUrl/settings/public',
    ).replace(queryParameters: {'locale': locale});
    final watch = Stopwatch()..start();
    final http.Response response;
    try {
      response = await _client
          .get(
            uri,
            headers: {'Accept': 'application/json', 'Accept-Language': locale},
          )
          .timeout(apiTimeout);
    } catch (_) {
      ApiLogger.log(
        method: 'GET',
        uri: uri,
        elapsed: watch.elapsed,
        failure: 'network',
      );
      rethrow;
    }
    ApiLogger.log(
      method: 'GET',
      uri: uri,
      elapsed: watch.elapsed,
      status: response.statusCode,
      body: response.bodyBytes,
    );
    if (response.statusCode != 200) {
      throw http.ClientException(
        'GET /settings/public failed: ${response.statusCode}',
      );
    }
    final body = utf8.decode(response.bodyBytes);
    final settings = AppSettings.fromJson(
      jsonDecode(body) as Map<String, dynamic>,
    );
    try {
      await _storage.write(key: _cacheKey, value: body);
    } catch (_) {
      // The live response is usable even if local storage is unavailable.
    }
    return settings;
  }
}
