import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'api_logger.dart';
import 'token_store.dart';

/// One file in a multipart request.
class UploadFile {
  const UploadFile(this.field, this.path);
  final String field;
  final String path;
}

/// Body for `multipart/form-data` calls. Fields are a list (not a map) so
/// array fields such as `other_links[]` can repeat.
class MultipartBody {
  const MultipartBody({this.fields = const [], this.files = const []});
  final List<MapEntry<String, String>> fields;
  final List<UploadFile> files;
}

/// Thin JSON/multipart client for the KÖMEKÇI backend.
///
/// - sends `Authorization: Bearer` + `Accept: application/json`
/// - on a 401 it refreshes the token pair once (shared by concurrent calls)
///   and replays the request; if the refresh is rejected the session is
///   cleared and [onSessionExpired] fires
/// - every failure surfaces as an [ApiException]
class ApiClient {
  ApiClient({
    http.Client? client,
    TokenStore? tokenStore,
    String baseUrl = apiBaseUrl,
    this.languageCode,
  }) : _client = client ?? http.Client(),
       _store = tokenStore ?? const SecureTokenStore(),
       _baseUrl = baseUrl;

  final http.Client _client;
  final TokenStore _store;
  final String _baseUrl;

  /// Sent as `Accept-Language` so errors before sign-in use the UI language.
  final String Function()? languageCode;

  /// Called once the refresh token is rejected and the session is gone.
  void Function()? onSessionExpired;

  AuthTokens? _tokens;
  Future<bool>? _refreshing;

  bool get hasSession => _tokens != null;

  /// Loads tokens saved by a previous run. True if a session was found.
  Future<bool> restoreSession() async {
    _tokens = await _store.read();
    return _tokens != null;
  }

  Future<void> saveSession(AuthTokens tokens) async {
    _tokens = tokens;
    await _store.write(tokens);
  }

  Future<void> clearSession() async {
    _tokens = null;
    await _store.clear();
  }

  String? get refreshToken => _tokens?.refresh;

  Future<dynamic> get(String path, {Map<String, Object?>? query, bool auth = true}) =>
      request('GET', path, query: query, auth: auth);

  Future<dynamic> post(String path, {Object? json, bool auth = true, Map<String, String>? headers}) =>
      request('POST', path, json: json, auth: auth, headers: headers);

  Future<dynamic> put(String path, {Object? json}) =>
      request('PUT', path, json: json);

  Future<dynamic> patch(String path, {Object? json}) =>
      request('PATCH', path, json: json);

  Future<dynamic> delete(String path, {Object? json}) =>
      request('DELETE', path, json: json);

  Future<dynamic> request(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? json,
    MultipartBody? multipart,
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    Future<http.Response> send() => _send(
      method,
      path,
      query: query,
      json: json,
      multipart: multipart,
      auth: auth,
      extraHeaders: headers,
    );

    final usedAccess = _tokens?.access;
    var response = await send();
    if (response.statusCode == 401 && auth && usedAccess != null) {
      // Another call may have refreshed while this one was in flight.
      final alreadyRefreshed = _tokens != null && _tokens!.access != usedAccess;
      if (alreadyRefreshed || await _refresh()) {
        response = await send();
      }
    }
    return _decode(response);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? json,
    MultipartBody? multipart,
    required bool auth,
    Map<String, String>? extraHeaders,
  }) async {
    final queryParameters = {
      for (final e in (query ?? const <String, Object?>{}).entries)
        if (e.value != null) e.key: '${e.value}',
    };
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final headers = <String, String>{
      'Accept': 'application/json',
      if (languageCode != null) 'Accept-Language': languageCode!(),
      if (auth && _tokens != null) 'Authorization': 'Bearer ${_tokens!.access}',
      ...?extraHeaders,
    };
    final watch = Stopwatch()..start();
    try {
      if (multipart != null) {
        final request = http.MultipartRequest(method, uri)
          ..headers.addAll(headers);
        // `fields` is a Map, so a key that repeats (`other_links[]`) goes in
        // as its own text parts instead.
        final counts = <String, int>{};
        for (final f in multipart.fields) {
          counts[f.key] = (counts[f.key] ?? 0) + 1;
        }
        for (final f in multipart.fields) {
          if (counts[f.key]! > 1) {
            request.files.add(http.MultipartFile.fromString(f.key, f.value));
          } else {
            request.fields[f.key] = f.value;
          }
        }
        for (final f in multipart.files) {
          request.files.add(await http.MultipartFile.fromPath(f.field, f.path));
        }
        final streamed = await _client.send(request).timeout(apiUploadTimeout);
        return _logged(method, uri, watch, await http.Response.fromStream(streamed));
      }
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (json != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(json);
      }
      final streamed = await _client.send(request).timeout(apiTimeout);
      return _logged(method, uri, watch, await http.Response.fromStream(streamed));
    } on ApiException {
      rethrow;
    } on TimeoutException catch (e) {
      throw _failed(method, uri, watch, 'timeout', e);
    } on SocketException catch (e) {
      throw _failed(method, uri, watch, 'network', e);
    } on HandshakeException catch (e) {
      throw _failed(method, uri, watch, 'tls', e);
    } on http.ClientException catch (e) {
      throw _failed(method, uri, watch, 'network', e);
    }
  }

  http.Response _logged(String method, Uri uri, Stopwatch watch, http.Response response) {
    ApiLogger.log(
      method: method,
      uri: uri,
      elapsed: watch.elapsed,
      status: response.statusCode,
      body: response.bodyBytes,
    );
    return response;
  }

  ApiException _failed(String method, Uri uri, Stopwatch watch, String reason, Object cause) {
    ApiLogger.log(method: method, uri: uri, elapsed: watch.elapsed, failure: reason);
    return ApiException.network(cause);
  }

  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    Object? body;
    if (text.isNotEmpty) {
      try {
        body = jsonDecode(text);
      } on FormatException {
        body = null;
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    throw ApiException.fromBody(response.statusCode, body);
  }

  /// Rotates the token pair. Concurrent callers share one request.
  Future<bool> _refresh() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refresh = _tokens?.refresh;
    if (refresh == null) return false;
    try {
      final response = await _send(
        'POST',
        '/auth/refresh',
        json: {'refresh_token': refresh},
        auth: false,
      );
      final body = _decode(response);
      await saveSession(AuthTokens.fromJson(body as Map<String, dynamic>));
      return true;
    } on ApiException catch (e) {
      // A dead connection says nothing about the token; keep the session.
      if (e.isNetwork) rethrow;
      await clearSession();
      onSessionExpired?.call();
      return false;
    }
  }

  void close() => _client.close();
}
