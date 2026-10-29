part of '../../../app/komekci_app.dart';

/// Makes sure every month between [from] and [to] is in the calendar cache,
/// so "bookings in this period" is counted from real data.
Future<void> _loadMonthsBetween(
  BookingProvider bookings,
  DateTime from,
  DateTime to,
) async {
  var cursor = DateTime(from.year, from.month);
  final last = DateTime(to.year, to.month);
  while (!cursor.isAfter(last)) {
    await bookings.ensureLoaded(cursor);
    cursor = DateTime(cursor.year, cursor.month + 1);
  }
}

