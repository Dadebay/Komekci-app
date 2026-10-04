import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Colour-coded request log for debug builds, e.g.
///
///     ●  200  GET   /me                         84 ms
///     ●  422  POST  /auth/register              310 ms  VALIDATION
///     ●  ERR  GET   /settings/public            8002 ms  network
///
/// Colour follows the status class: 2xx green, 3xx cyan, 4xx yellow,
/// 5xx red, no response magenta.
///
/// With [showResponseBodies] the server's JSON answer is printed under the
/// line (truncated), with token-like values masked. Request headers and
/// request bodies are never printed.
class ApiLogger {
  const ApiLogger._();

  /// Off in release builds and under `flutter test`.
  static bool enabled = kDebugMode && !Platform.environment.containsKey('FLUTTER_TEST');

  /// Print what the server answered (debug builds only).
  static bool showResponseBodies = true;

  /// Longest response body printed, in characters.
  static const _maxBody = 1800;

  static const _reset = '\x1B[0m';
  static const _dim = '\x1B[2m';
  static final _secretKey = RegExp(r'token|secret|password', caseSensitive: false);

  static String _color(int? status) => switch (status) {
    null => '\x1B[35m', // magenta: never got a response
    >= 500 => '\x1B[31m', // red
    >= 400 => '\x1B[33m', // yellow
    >= 300 => '\x1B[36m', // cyan
    >= 200 => '\x1B[32m', // green
    _ => '\x1B[37m',
  };

  /// [status] is null when the request failed before any response.
  static void log({
    required String method,
    required Uri uri,
    required Duration elapsed,
    int? status,
    List<int>? body,
    String? failure,
  }) {
    if (!enabled) return;
    final color = _color(status);
    final badge = (status?.toString() ?? 'ERR').padRight(3);
    final target = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    final code = failure ?? _errorCode(status, body);
    // ignore: avoid_print
    print(
      '$color●  \x1B[1m$badge$_reset$color  ${method.padRight(6)}'
      '${target.replaceFirst('/api', '').padRight(34)} ${elapsed.inMilliseconds} ms'
      '${code == null ? '' : '  $code'}$_reset',
    );
    if (showResponseBodies && body != null && body.isNotEmpty) {
      // ignore: avoid_print
      print('$_dim${_pretty(body)}$_reset');
    }
  }

  /// Indented JSON with secrets masked, or the raw text if it is not JSON.
  static String _pretty(List<int> body) {
    final text = utf8.decode(body, allowMalformed: true);
    String out;
    try {
      out = const JsonEncoder.withIndent('  ').convert(_mask(jsonDecode(text)));
    } catch (_) {
      out = text.trim();
    }
    return out.length > _maxBody ? '${out.substring(0, _maxBody)}\n… (${out.length - _maxBody} more characters)' : out;
  }

  static Object? _mask(Object? value) {
    if (value is Map) {
      return {
        for (final e in value.entries)
          e.key: _secretKey.hasMatch('${e.key}') && e.key != 'token_type' && e.value is String
              ? _hide(e.value as String)
              : _mask(e.value),
      };
    }
    if (value is List) return [for (final v in value) _mask(v)];
    return value;
  }

  static String _hide(String secret) =>
      secret.length <= 10 ? '••••' : '${secret.substring(0, 6)}…(${secret.length} chars)';

  static String? _errorCode(int? status, List<int>? body) {
    if (status == null || status < 400 || body == null || body.isEmpty) return null;
    try {
      final decoded = jsonDecode(utf8.decode(body));
      return decoded is Map<String, dynamic> ? decoded['error'] as String? : null;
    } catch (_) {
      return null;
    }
  }
}
