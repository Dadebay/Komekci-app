import 'json_helpers.dart';

/// A master's service (`/me/services`).
class ApiService {
  const ApiService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMin,
    required this.isHidden,
    required this.sortOrder,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final int durationMin;
  final bool isHidden;
  final int sortOrder;
  final String? photoUrl;

  factory ApiService.fromJson(Map<String, dynamic> json) => ApiService(
    id: parseIntOrNull(json['id']) ?? 0,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    price: parseMoney(json['price']),
    durationMin: parseIntOrNull(json['duration_min']) ?? 0,
    isHidden: json['is_hidden'] as bool? ?? false,
    sortOrder: parseIntOrNull(json['sort_order']) ?? 0,
    photoUrl: json['photo_url'] as String?,
  );
}

/// One weekday of the weekly schedule. `weekday` 0…6; times are `HH:mm`.
class ScheduleDay {
  const ScheduleDay({
    required this.weekday,
    required this.isWorking,
    this.startTime,
    this.endTime,
    this.breakStart,
    this.breakEnd,
  });

  final int weekday;
  final bool isWorking;
  final String? startTime;
  final String? endTime;
  final String? breakStart;
  final String? breakEnd;

  factory ScheduleDay.fromJson(Map<String, dynamic> json) => ScheduleDay(
    weekday: parseIntOrNull(json['weekday']) ?? 0,
    isWorking: json['is_working'] as bool? ?? false,
    startTime: _hhmm(json['start_time']),
    endTime: _hhmm(json['end_time']),
    breakStart: _hhmm(json['break_start']),
    breakEnd: _hhmm(json['break_end']),
  );

  Map<String, Object?> toJson() => {
    'weekday': weekday,
    'is_working': isWorking,
    'start_time': isWorking ? startTime : null,
    'end_time': isWorking ? endTime : null,
    'break_start': isWorking ? breakStart : null,
    'break_end': isWorking ? breakEnd : null,
  };
}

/// Server may answer `10:00:00`; the API is documented as `HH:mm`.
String? _hhmm(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return value.length >= 5 ? value.substring(0, 5) : value;
}

enum OverrideType { dayOff, customHours }

class ScheduleOverride {
  const ScheduleOverride({
    required this.id,
    required this.date,
    required this.type,
    this.startTime,
    this.endTime,
  });

  final int id;
  final DateTime date;
  final OverrideType type;
  final String? startTime;
  final String? endTime;

  factory ScheduleOverride.fromJson(Map<String, dynamic> json) => ScheduleOverride(
    id: parseIntOrNull(json['id']) ?? 0,
    date: parseApiTime(json['date']) ?? DateTime.now(),
    type: json['type'] == 'custom_hours' ? OverrideType.customHours : OverrideType.dayOff,
    startTime: _hhmm(json['start_time']),
    endTime: _hhmm(json['end_time']),
  );
}

class Vacation {
  const Vacation({required this.id, required this.start, required this.end});
  final int id;
  final DateTime start;
  final DateTime end;

  factory Vacation.fromJson(Map<String, dynamic> json) => Vacation(
    id: parseIntOrNull(json['id']) ?? 0,
    start: parseApiTime(json['start_date']) ?? DateTime.now(),
    end: parseApiTime(json['end_date']) ?? DateTime.now(),
  );
}

class Schedule {
  const Schedule({
    required this.gridStepMin,
    required this.minLeadMin,
    required this.days,
    required this.overrides,
    required this.vacations,
  });

  final int gridStepMin;
  final int minLeadMin;
  final List<ScheduleDay> days;
  final List<ScheduleOverride> overrides;
  final List<Vacation> vacations;

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    gridStepMin: parseIntOrNull(json['grid_step_min']) ?? 15,
    minLeadMin: parseIntOrNull(json['min_lead_min']) ?? 30,
    days: [for (final d in asMapList(json['days'])) ScheduleDay.fromJson(d)],
    overrides: [for (final o in asMapList(json['overrides'])) ScheduleOverride.fromJson(o)],
    vacations: [for (final v in asMapList(json['vacations'])) Vacation.fromJson(v)],
  );
}

enum ApiAppointmentStatus {
  expected,
  completed,
  cancelled,
  noShow;

  static ApiAppointmentStatus parse(Object? value) => switch (value) {
    'completed' => completed,
    'cancelled' => cancelled,
    'no_show' => noShow,
    _ => expected,
  };

  String get wire => switch (this) {
    expected => 'expected',
    completed => 'completed',
    cancelled => 'cancelled',
    noShow => 'no_show',
  };
}

class ServiceSnapshot {
  const ServiceSnapshot({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMin,
  });
  final int id;
  final String name;
  final double price;
  final int durationMin;

  factory ServiceSnapshot.fromJson(Map<String, dynamic> json) => ServiceSnapshot(
    id: parseIntOrNull(json['id']) ?? 0,
    name: json['name'] as String? ?? '',
    price: parseMoney(json['price']),
    durationMin: parseIntOrNull(json['duration_min']) ?? 0,
  );
}

/// The client of a master's appointment. `id` is a string: `a15` for a
/// connected account, `o4` for an offline client the master typed in.
class AppointmentClient {
  const AppointmentClient({
    required this.id,
    required this.name,
    this.nickname,
    this.phone,
    this.photoUrl,
    this.offline = false,
  });
  final String id;
  final String name;
  final String? nickname;
  final String? phone;
  final String? photoUrl;
  final bool offline;

  factory AppointmentClient.fromJson(Map<String, dynamic> json) => AppointmentClient(
    id: '${json['id']}',
    name: json['name'] as String? ?? '',
    nickname: json['nickname'] as String?,
    phone: json['phone'] as String?,
    photoUrl: json['photo_url'] as String?,
    offline: json['offline'] as bool? ?? false,
  );
}

/// An appointment as the master sees it (`/me/calendar`, `/me/appointments`).
class MasterAppointment {
  const MasterAppointment({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.service,
    required this.client,
    this.note,
    this.source = 'online',
    this.lateMinutes,
    this.noShowSuggested = false,
  });

  final int id;
  final DateTime startsAt;
  final DateTime endsAt;
  final ApiAppointmentStatus status;
  final String? note;
  final String source;
  final int? lateMinutes;
  final bool noShowSuggested;
  final ServiceSnapshot service;
  final AppointmentClient client;

  factory MasterAppointment.fromJson(Map<String, dynamic> json) {
    final start = parseApiTime(json['starts_at']) ?? DateTime.now();
    return MasterAppointment(
      id: parseIntOrNull(json['id']) ?? 0,
      startsAt: start,
      endsAt: parseApiTime(json['ends_at']) ?? start,
      status: ApiAppointmentStatus.parse(json['status']),
      note: json['note'] as String?,
      source: json['source'] as String? ?? 'online',
      lateMinutes: parseIntOrNull(json['late_minutes']),
      noShowSuggested: json['no_show_suggested'] as bool? ?? false,
      service: ServiceSnapshot.fromJson(asMap(json['service'])),
      client: AppointmentClient.fromJson(asMap(json['client'])),
    );
  }
}

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
      appointment: appt is Map<String, dynamic> ? ClientAppointmentRef.fromJson(appt) : null,
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
  const ClientCard({required this.client, this.privateNote, this.history = const []});
  final ClientSummary client;
  final String? privateNote;
  final List<ClientHistoryItem> history;

  factory ClientCard.fromJson(Map<String, dynamic> json) => ClientCard(
    client: ClientSummary.fromJson(asMap(json['client'])),
    privateNote: json['private_note'] as String?,
    history: [for (final h in asMapList(json['history'])) ClientHistoryItem.fromJson(h)],
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
