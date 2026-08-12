import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/data/repositories/mock_appointment_repository.dart';
import 'package:komekci/features/booking/application/booking_provider.dart';

void main() {
  test('creates and cancels a mock appointment', () {
    final provider = BookingProvider(MockAppointmentRepository());
    final before = provider.active.length;
    provider.create(
      service: 'Manicure',
      startsAt: DateTime(2026, 8, 15, 10),
      price: 150,
    );
    expect(provider.active, hasLength(before + 1));
    provider.cancel(provider.active.last.id);
    expect(provider.history, hasLength(1));
  });
}
