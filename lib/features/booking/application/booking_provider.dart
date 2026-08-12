import 'package:flutter/foundation.dart';
import '../../../data/models/appointment.dart';
import '../../../data/repositories/mock_appointment_repository.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider(this._repository) : _appointments = _repository.seed();
  final MockAppointmentRepository _repository;
  List<Appointment> _appointments;
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  List<Appointment> get active => _appointments
      .where((a) => a.status == AppointmentStatus.expected)
      .toList();
  List<Appointment> get history => _appointments
      .where((a) => a.status != AppointmentStatus.expected)
      .toList();

  void resetMockData() {
    _appointments = _repository.seed();
    notifyListeners();
  }

  List<Appointment> onDay(DateTime day) =>
      _appointments
          .where(
            (a) =>
                a.startsAt.year == day.year &&
                a.startsAt.month == day.month &&
                a.startsAt.day == day.day,
          )
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  void create({
    required String service,
    required DateTime startsAt,
    required double price,
    String clientName = 'Ayna Orazova',
    String? customerId,
  }) {
    _appointments = [
      ..._appointments,
      Appointment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        clientName: clientName,
        customerId: customerId,
        serviceName: service,
        startsAt: startsAt,
        price: price,
      ),
    ];
    notifyListeners();
  }

  void complete(String id) {
    _replace(id, (a) => a.copyWith(status: AppointmentStatus.completed));
  }

  void arrive(String id) {
    _replace(id, (a) => a.copyWith(status: AppointmentStatus.arrived));
  }

  void cancel(String id) {
    _replace(id, (a) => a.copyWith(status: AppointmentStatus.cancelled));
  }

  void reschedule(String id, DateTime startsAt) {
    _replace(id, (a) => a.copyWith(startsAt: startsAt));
  }

  void toggleLate(String id) {
    _replace(id, (a) => a.copyWith(isLate: !a.isLate));
  }

  void _replace(String id, Appointment Function(Appointment) transform) {
    _appointments = _appointments
        .map((a) => a.id == id ? transform(a) : a)
        .toList();
    notifyListeners();
  }
}
