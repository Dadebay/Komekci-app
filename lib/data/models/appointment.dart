import 'api/master_models.dart';

/// [arrived] exists only on this device: the API knows `expected`,
/// `completed`, `cancelled` and `no_show`, so "client has arrived" is a local
/// marker between `expected` and `completed`.
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
    this.serviceId,
    this.clientPhone,
    this.source = 'online',
    this.noShowSuggested = false,
    this.lateMinutes,
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

  final int? serviceId;
  final String? clientPhone;

  /// `online` (client booked) or `manual` (master typed it in).
  final String source;

  /// Still `expected` although the no-show window has passed.
  final bool noShowSuggested;

  /// Minutes the client said they would be late, if they did.
  final int? lateMinutes;

  factory Appointment.fromApi(MasterAppointment a) => Appointment(
    id: '${a.id}',
    clientName: a.client.name,
    customerId: a.client.id,
    serviceName: a.service.name,
    startsAt: a.startsAt,
    price: a.service.price,
    status: switch (a.status) {
      ApiAppointmentStatus.expected => AppointmentStatus.expected,
      ApiAppointmentStatus.completed => AppointmentStatus.completed,
      ApiAppointmentStatus.cancelled => AppointmentStatus.cancelled,
      ApiAppointmentStatus.noShow => AppointmentStatus.noShow,
    },
    isLate: a.lateMinutes != null,
    minutes: a.service.durationMin > 0
        ? a.service.durationMin
        : a.endsAt.difference(a.startsAt).inMinutes,
    note: a.note ?? '',
    serviceId: a.service.id,
    clientPhone: a.client.phone,
    source: a.source,
    noShowSuggested: a.noShowSuggested,
    lateMinutes: a.lateMinutes,
  );

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
    serviceId: serviceId,
    clientPhone: clientPhone,
    source: source,
    noShowSuggested: noShowSuggested,
    lateMinutes: lateMinutes,
  );
}
