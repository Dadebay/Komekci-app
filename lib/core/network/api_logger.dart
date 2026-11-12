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
/// Response bodies, request bodies, headers and query values are never printed.
class ApiLogger {
  const ApiLogger._();

  /// Off in release builds and under `flutter test`.
  static bool enabled =
      kDebugMode && !Platform.environment.containsKey('FLUTTER_TEST');

  static const _reset = '\x1B[0m';
  static final _safeCode = RegExp(r'^[A-Za-z0-9_:-]{1,64}$');

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
    final target = uri.path;
    final code = failure ?? _errorCode(status, body);
    // ignore: avoid_print
    print(
      '$color●  \x1B[1m$badge$_reset$color  ${method.padRight(6)}'
      '${target.replaceFirst('/api', '').padRight(34)} ${elapsed.inMilliseconds} ms'
      '${code == null ? '' : '  $code'}$_reset',
    );
  }

  static String? _errorCode(int? status, List<int>? body) {
    if (status == null || status < 400 || body == null || body.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(utf8.decode(body));
      final code = decoded is Map<String, dynamic> ? decoded['error'] : null;
      return code is String && _safeCode.hasMatch(code) ? code : null;
    } catch (_) {
      return null;
    }
  }
}
