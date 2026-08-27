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

  /// True when [start]..[start]+[minutes] overlaps an existing, non-cancelled
  /// appointment. The UI must call this again right before submitting a
  /// booking — a slot can only be trusted at the moment it's reserved.
  bool hasConflict(DateTime start, int minutes, {String? excludeId}) {
    final end = start.add(Duration(minutes: minutes));
    for (final a in _appointments) {
      if (a.id == excludeId || a.status == AppointmentStatus.cancelled) {
        continue;
      }
      if (start.isBefore(a.endsAt) && a.startsAt.isBefore(end)) return true;
    }
    return false;
  }

  /// Returns the created appointment, or null if [startsAt] now conflicts —
  /// checked again here so a slot picked earlier in a wizard can't silently
  /// double-book if something else claimed it in the meantime.
  Appointment? create({
    required String service,
    required DateTime startsAt,
    required double price,
    required int minutes,
    String clientName = 'Ayna Orazova',
    String? customerId,
    String note = '',
    bool notifyEarlierSlot = false,
  }) {
    if (hasConflict(startsAt, minutes)) return null;
    final appointment = Appointment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      clientName: clientName,
      customerId: customerId,
      serviceName: service,
      startsAt: startsAt,
      price: price,
      minutes: minutes,
      note: note,
      notifyEarlierSlot: notifyEarlierSlot,
    );
    _appointments = [..._appointments, appointment];
    notifyListeners();
    return appointment;
  }

  void complete(String id) {
    _replace(id, (a) => a.copyWith(status: AppointmentStatus.completed));
  }

  void arrive(String id) {
    _replace(id, (a) => a.copyWith(status: AppointmentStatus.arrived));
  }

  void markNoShow(String id) {
    _replace(id, (a) => a.copyWith(status: AppointmentStatus.noShow));
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
