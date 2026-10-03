// Shared parsing for the API's JSON conventions.

/// Money arrives as a string with two decimals ("50.00"); tolerate numbers.
double parseMoney(Object? value) => double.tryParse('$value') ?? 0;

int? parseIntOrNull(Object? value) => switch (value) {
  final num n => n.toInt(),
  final String s => int.tryParse(s),
  _ => null,
};

final _hasOffset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

/// The app treats every [DateTime] as Asia/Ashgabat wall-clock time (UTC+5,
/// no DST), regardless of the phone's own zone. ISO strings carrying an
/// offset are converted to that wall clock; offset-less strings are already it.
DateTime? parseApiTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  if (!_hasOffset.hasMatch(value)) {
    return DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    );
  }
  final w = parsed.toUtc().add(const Duration(hours: 5));
  return DateTime(w.year, w.month, w.day, w.hour, w.minute, w.second);
}

String _two(int n) => n.toString().padLeft(2, '0');

/// `2026-10-02` — query and body dates.
String formatApiDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

/// `2026-10-02 10:00:00` — the server reads this in Asia/Ashgabat.
String formatApiDateTime(DateTime d) =>
    '${formatApiDate(d)} ${_two(d.hour)}:${_two(d.minute)}:00';

/// `10:30` — schedule times.
String formatApiTimeOfDay(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

/// Many responses wrap their payload as `{ "data": ... }`; accept both.
Object? unwrapData(Object? body) =>
    body is Map<String, dynamic> && body.containsKey('data') ? body['data'] : body;

Map<String, dynamic> asMap(Object? value) =>
    value is Map<String, dynamic> ? value : const {};

List<Map<String, dynamic>> asMapList(Object? value) => [
  if (value is List)
    for (final item in value)
      if (item is Map<String, dynamic>) item,
];

/// A page of a cursor-paginated list.
class ApiPage<T> {
  const ApiPage(this.items, this.nextCursor);
  final List<T> items;

  /// Null on the last page.
  final String? nextCursor;
  bool get hasMore => nextCursor != null;

  factory ApiPage.fromJson(
    Object? body,
    T Function(Map<String, dynamic>) parse,
  ) {
    final map = asMap(body);
    final cursor = map['next_cursor'];
    return ApiPage([
      for (final item in asMapList(map['data'])) parse(item),
    ], cursor == null ? null : '$cursor');
  }
}
