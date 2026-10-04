import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/network/api_config.dart';
import '../../core/network/api_logger.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Throws on network errors, timeouts and non-200 responses.
  Future<AppSettings> fetchPublic() async {
    final uri = Uri.parse('$apiBaseUrl/settings/public');
    final watch = Stopwatch()..start();
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(apiTimeout);
    } catch (_) {
      ApiLogger.log(method: 'GET', uri: uri, elapsed: watch.elapsed, failure: 'network');
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
    return AppSettings.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }
}
