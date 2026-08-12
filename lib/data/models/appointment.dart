enum AppointmentStatus { expected, arrived, completed, cancelled, noShow }

class Appointment {
  const Appointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.startsAt,
    required this.price,
    this.customerId,
    this.status = AppointmentStatus.expected,
    this.isLate = false,
  });
  final String id;
  final String clientName;

  /// Links back to [Customer.id] when this appointment was booked for a
  /// customer on file. Null for the client-side self-booking flow.
  final String? customerId;
  final String serviceName;
  final DateTime startsAt;
  final double price;
  final AppointmentStatus status;
  final bool isLate;

  Appointment copyWith({
    AppointmentStatus? status,
    bool? isLate,
    DateTime? startsAt,
  }) => Appointment(
    id: id,
    clientName: clientName,
    customerId: customerId,
    serviceName: serviceName,
    startsAt: startsAt ?? this.startsAt,
    price: price,
    status: status ?? this.status,
    isLate: isLate ?? this.isLate,
  );
}
