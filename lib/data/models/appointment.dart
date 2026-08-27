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
    this.minutes = 45,
    this.note = '',
    this.notifyEarlierSlot = false,
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

  /// Service duration — needed to compute [endsAt] and detect overlaps.
  final int minutes;
  final String note;

  /// Client opted in to a push if an earlier slot opens up before this time.
  final bool notifyEarlierSlot;

  DateTime get endsAt => startsAt.add(Duration(minutes: minutes));

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
    minutes: minutes,
    note: note,
    notifyEarlierSlot: notifyEarlierSlot,
  );
}
