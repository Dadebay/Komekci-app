import 'json_helpers.dart';
import 'master_models.dart';
import 'user_models.dart';

enum ConnectionStatus {
  pending,
  accepted,
  declined,
  removed;

  static ConnectionStatus parse(Object? value) => switch (value) {
    'accepted' => accepted,
    'declined' => declined,
    'removed' => removed,
    _ => pending,
  };
}

/// A client's link to a master (`/connections`).
class ClientConnection {
  const ClientConnection({
    required this.id,
    required this.status,
    required this.active,
    required this.master,
  });
  final int id;
  final ConnectionStatus status;
  final bool active;
  final MasterBrief master;

  factory ClientConnection.fromJson(Map<String, dynamic> json) => ClientConnection(
    id: parseIntOrNull(json['id']) ?? 0,
    status: ConnectionStatus.parse(json['status']),
    active: json['active'] as bool? ?? false,
    master: MasterBrief.fromJson(asMap(json['master'])),
  );
}

/// Services of a connected master as a client sees them.
class MasterServices {
  const MasterServices({required this.acceptingBookings, required this.services});
  final bool acceptingBookings;
  final List<ApiService> services;

  factory MasterServices.fromJson(Map<String, dynamic> json) => MasterServices(
    acceptingBookings: json['accepting_bookings'] as bool? ?? false,
    services: [for (final s in asMapList(json['data'])) ApiService.fromJson(s)],
  );
}

/// Free slots. A single `date` fills [slots]; a `from`/`to` range fills
/// [dates]. When the master is suspended the server still answers 200 with
/// [acceptingBookings] false and an [error] code.
class Availability {
  const Availability({
    required this.acceptingBookings,
    this.date,
    this.slots = const [],
    this.dates = const {},
    this.error,
    this.message,
  });

  final bool acceptingBookings;
  final String? date;
  final List<String> slots;
  final Map<String, List<String>> dates;
  final String? error;
  final String? message;

  factory Availability.fromJson(Map<String, dynamic> json) {
    final dates = asMap(json['dates']);
    return Availability(
      acceptingBookings: json['accepting_bookings'] as bool? ?? true,
      date: json['date'] as String?,
      slots: [for (final s in (json['slots'] as List? ?? const [])) '$s'],
      dates: {
        for (final e in dates.entries)
          e.key: [for (final s in (e.value as List? ?? const [])) '$s'],
      },
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// An appointment as its client sees it (`/appointments`).
class ClientAppointment {
  const ClientAppointment({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.service,
    required this.master,
    this.note,
    this.lateMinutes,
    this.waitlistEarlier = false,
  });

  final int id;
  final DateTime startsAt;
  final DateTime endsAt;
  final ApiAppointmentStatus status;
  final String? note;
  final int? lateMinutes;
  final bool waitlistEarlier;
  final ServiceSnapshot service;
  final MasterBrief master;

  factory ClientAppointment.fromJson(Map<String, dynamic> json) {
    final start = parseApiTime(json['starts_at']) ?? DateTime.now();
    return ClientAppointment(
      id: parseIntOrNull(json['id']) ?? 0,
      startsAt: start,
      endsAt: parseApiTime(json['ends_at']) ?? start,
      status: ApiAppointmentStatus.parse(json['status']),
      note: json['note'] as String?,
      lateMinutes: parseIntOrNull(json['late_minutes']),
      waitlistEarlier: json['waitlist_earlier'] as bool? ?? false,
      service: ServiceSnapshot.fromJson(asMap(json['service'])),
      master: MasterBrief.fromJson(asMap(json['master'])),
    );
  }
}

/// `GET /me/notifications` item.
class ApiNotification {
  const ApiNotification({
    required this.id,
    required this.eventCode,
    required this.title,
    required this.body,
    required this.payload,
    required this.sentAt,
    this.readAt,
  });
  final int id;
  final String eventCode;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final DateTime sentAt;
  final DateTime? readAt;

  factory ApiNotification.fromJson(Map<String, dynamic> json) => ApiNotification(
    id: parseIntOrNull(json['id']) ?? 0,
    eventCode: json['event_code'] as String? ?? '',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    payload: asMap(json['payload']),
    sentAt: parseApiTime(json['sent_at']) ?? DateTime.now(),
    readAt: parseApiTime(json['read_at']),
  );
}
