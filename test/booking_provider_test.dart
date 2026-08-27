import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/data/repositories/mock_appointment_repository.dart';
import 'package:komekci/features/booking/application/booking_provider.dart';

void main() {
  test('creates and cancels a mock appointment', () {
    final provider = BookingProvider(MockAppointmentRepository());
    final activeBefore = provider.active.length;
    final historyBefore = provider.history.length;
    provider.create(
      service: 'Manicure',
      startsAt: DateTime(2026, 8, 15, 10),
      price: 150,
      minutes: 30,
    );
    expect(provider.active, hasLength(activeBefore + 1));
    provider.cancel(provider.active.last.id);
    expect(provider.history, hasLength(historyBefore + 1));
  });
}
