part of 'master_models.dart';

class ClientAppointmentRef {
  const ClientAppointmentRef({
    required this.id,
    required this.startsAt,
    required this.serviceName,
    required this.status,
  });
  final int id;
  final DateTime startsAt;
  final String serviceName;
  final ApiAppointmentStatus status;

  factory ClientAppointmentRef.fromJson(Map<String, dynamic> json) =>
      ClientAppointmentRef(
        id: parseIntOrNull(json['id']) ?? 0,
        startsAt: parseApiTime(json['starts_at']) ?? DateTime.now(),
        serviceName: json['service_name'] as String? ?? '',
        status: ApiAppointmentStatus.parse(json['status']),
      );
}

/// A row of `GET /me/clients`, also the `client` block of the client card.
class ClientSummary {
  const ClientSummary({
    required this.id,
    required this.offline,
    required this.name,
    this.nickname,
    this.phone,
    this.photoUrl,
    this.accountId,
    this.appointment,
    this.lastVisit,
    this.visits = 0,
    this.noShows = 0,
    this.spend = 0,
    this.status = '',
  });

  /// `c12` for a connection, `o4` for an offline client.
  final String id;
  final bool offline;
  final String name;
  final String? nickname;
  final String? phone;
  final String? photoUrl;

  /// Numeric account ID needed by `POST /me/notifications/send`.
  /// The `c12` row ID is a connection ID and must not be used here.
  final int? accountId;
  final ClientAppointmentRef? appointment;
  final DateTime? lastVisit;
  final int visits;
  final int noShows;
  final double spend;
  final String status;

  factory ClientSummary.fromJson(Map<String, dynamic> json) {
    final appt = json['appointment'];
    return ClientSummary(
      id: '${json['id']}',
      offline: json['offline'] as bool? ?? false,
      name: json['name'] as String? ?? '',
      nickname: json['nickname'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photo_url'] as String?,
      accountId: parseIntOrNull(json['account_id']),
      appointment: appt is Map<String, dynamic>
          ? ClientAppointmentRef.fromJson(appt)
          : null,
      lastVisit: parseApiTime(json['last_visit']),
      visits: parseIntOrNull(json['visits']) ?? 0,
      noShows: parseIntOrNull(json['no_shows']) ?? 0,
      spend: parseMoney(json['spend']),
      status: '${json['status'] ?? ''}',
    );
  }
}

class ClientHistoryItem {
  const ClientHistoryItem({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.serviceName,
    required this.price,
    required this.durationMin,
    this.note,
    this.lateMinutes,
  });
  final int id;
  final DateTime startsAt;
  final DateTime endsAt;
  final ApiAppointmentStatus status;
  final String serviceName;
  final double price;
  final int durationMin;
  final String? note;
  final int? lateMinutes;

  factory ClientHistoryItem.fromJson(Map<String, dynamic> json) {
    final start = parseApiTime(json['starts_at']) ?? DateTime.now();
    return ClientHistoryItem(
      id: parseIntOrNull(json['id']) ?? 0,
      startsAt: start,
      endsAt: parseApiTime(json['ends_at']) ?? start,
      status: ApiAppointmentStatus.parse(json['status']),
      serviceName: json['service_name'] as String? ?? '',
      price: parseMoney(json['price']),
      durationMin: parseIntOrNull(json['duration_min']) ?? 0,
      note: json['note'] as String?,
      lateMinutes: parseIntOrNull(json['late_minutes']),
    );
  }
}

/// `GET /me/clients/{id}`.
class ClientCard {
  const ClientCard({
    required this.client,
    this.privateNote,
    this.history = const [],
  });
  final ClientSummary client;
  final String? privateNote;
  final List<ClientHistoryItem> history;

  factory ClientCard.fromJson(Map<String, dynamic> json) => ClientCard(
    client: ClientSummary.fromJson(asMap(json['client'])),
    privateNote: json['private_note'] as String?,
    history: [
      for (final h in asMapList(json['history'])) ClientHistoryItem.fromJson(h),
    ],
  );
}

/// Incoming client → master connection request.
class ConnectionRequest {
  const ConnectionRequest({
    required this.id,
    required this.requestedAt,
    required this.clientName,
    this.clientNickname,
    this.clientPhotoUrl,
  });
  final int id;
  final DateTime requestedAt;
  final String clientName;
  final String? clientNickname;
  final String? clientPhotoUrl;

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    final client = asMap(json['client']);
    return ConnectionRequest(
      id: parseIntOrNull(json['id']) ?? 0,
      requestedAt: parseApiTime(json['requested_at']) ?? DateTime.now(),
      clientName: client['name'] as String? ?? '',
      clientNickname: client['nickname'] as String?,
      clientPhotoUrl: client['photo_url'] as String?,
    );
  }
}
