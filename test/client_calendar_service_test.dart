import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/features/booking/application/client_calendar_service.dart';

void main() {
  test('17:00–18:00 Ashgabat booking becomes 12:00–13:00 UTC', () {
    final start = ashgabatTimeOnDevice(DateTime(2030, 3, 14, 17));
    final end = ashgabatTimeOnDevice(DateTime(2030, 3, 14, 18));

    expect(start.toUtc(), DateTime.utc(2030, 3, 14, 12));
    expect(end.toUtc(), DateTime.utc(2030, 3, 14, 13));
    expect(
      start.subtract(const Duration(hours: 1)).toUtc(),
      DateTime.utc(2030, 3, 14, 11),
    );
  });

  test('calendar link signature changes when a booking moves', () {
    final original = CalendarBookingDetails(
      id: '42',
      masterName: 'Ayna',
      serviceName: 'Haircut',
      startsAt: _start,
      endsAt: _end,
    );
    final moved = CalendarBookingDetails(
      id: original.id,
      masterName: original.masterName,
      serviceName: original.serviceName,
      startsAt: _start.add(const Duration(hours: 1)),
      endsAt: _end.add(const Duration(hours: 1)),
    );

    expect(original.signature, isNot(moved.signature));
    expect(original.title, 'Haircut — Ayna master');
    expect(
      original.description,
      '14 mart · 17:00–18:00\n'
      'Ýazgyňyz 17:00-da. Haýyş edýäris, bellenen wagtyňyzda geliň.',
    );
  });

  test('calendar text matches the booking shown on the phone', () {
    final booking = CalendarBookingDetails(
      id: '43',
      masterName: 'Suleyman',
      serviceName: 'Saç daramak',
      startsAt: DateTime(2026, 10, 27, 14, 30),
      endsAt: DateTime(2026, 10, 27, 15),
    );

    expect(booking.title, 'Saç daramak — Suleyman master');
    expect(
      booking.description,
      '27 oktýabr · 14:30–15:00\n'
      'Ýazgyňyz 14:30-da. Haýyş edýäris, bellenen wagtyňyzda geliň.',
    );
  });

  test('Ashgabat time before 05:00 maps to previous UTC day', () {
    final start = ashgabatTimeOnDevice(DateTime(2030, 3, 14, 0, 30));
    expect(start.toUtc(), DateTime.utc(2030, 3, 13, 19, 30));
  });
}

final _start = DateTime(2030, 3, 14, 17);
final _end = DateTime(2030, 3, 14, 18);
