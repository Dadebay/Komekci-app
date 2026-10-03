import '../../core/network/api_client.dart';
import '../models/api/json_helpers.dart';
import '../models/api/master_models.dart';
import '../models/api/user_models.dart';

/// Everything under `/me/...` that only a master may call, except billing.
class MasterRepository {
  MasterRepository(this._api);
  final ApiClient _api;

  // ---- profile ----------------------------------------------------------

  Future<MasterProfile> profile() async =>
      MasterProfile.fromJson(asMap(unwrapData(await _api.get('/me/profile'))));

  /// Name, nickname and avatar live on `PATCH /me`, not here.
  Future<MasterProfile> updateProfile({
    String? address,
    String? description,
    String? instagramUrl,
    String? tiktokUrl,
    List<String>? otherLinks,
    String? bannerPath,
  }) async {
    final Object? body;
    if (bannerPath != null) {
      body = await _api.request(
        'PATCH',
        '/me/profile',
        multipart: MultipartBody(
          fields: [
            if (address != null) MapEntry('address', address),
            if (description != null) MapEntry('description', description),
            if (instagramUrl != null) MapEntry('instagram_url', instagramUrl),
            if (tiktokUrl != null) MapEntry('tiktok_url', tiktokUrl),
            if (otherLinks != null)
              for (final l in otherLinks) MapEntry('other_links[]', l),
          ],
          files: [UploadFile('banner', bannerPath)],
        ),
      );
    } else {
      body = await _api.patch(
        '/me/profile',
        json: {
          'address': ?address,
          'description': ?description,
          'instagram_url': ?instagramUrl,
          'tiktok_url': ?tiktokUrl,
          'other_links': ?otherLinks,
        },
      );
    }
    return MasterProfile.fromJson(asMap(unwrapData(body)));
  }

  // ---- services ---------------------------------------------------------

  Future<List<ApiService>> services() async => [
    for (final s in asMapList(unwrapData(await _api.get('/me/services'))))
      ApiService.fromJson(s),
  ];

  /// [photoPath] is required by the server on creation.
  Future<ApiService> createService({
    required String name,
    required double price,
    required int durationMin,
    required String photoPath,
    String? description,
    bool? isHidden,
    int? sortOrder,
  }) async {
    final body = await _api.request(
      'POST',
      '/me/services',
      multipart: MultipartBody(
        fields: [
          MapEntry('name', name),
          MapEntry('price', _num(price)),
          MapEntry('duration_min', '$durationMin'),
          if (description != null) MapEntry('description', description),
          if (isHidden != null) MapEntry('is_hidden', isHidden ? '1' : '0'),
          if (sortOrder != null) MapEntry('sort_order', '$sortOrder'),
        ],
        files: [UploadFile('photo', photoPath)],
      ),
    );
    return ApiService.fromJson(asMap(unwrapData(body)));
  }

  Future<ApiService> updateService(
    int id, {
    String? name,
    double? price,
    int? durationMin,
    String? description,
    bool? isHidden,
    int? sortOrder,
    String? photoPath,
  }) async {
    final Object? body;
    if (photoPath != null) {
      body = await _api.request(
        'PATCH',
        '/me/services/$id',
        multipart: MultipartBody(
          fields: [
            if (name != null) MapEntry('name', name),
            if (price != null) MapEntry('price', _num(price)),
            if (durationMin != null) MapEntry('duration_min', '$durationMin'),
            if (description != null) MapEntry('description', description),
            if (isHidden != null) MapEntry('is_hidden', isHidden ? '1' : '0'),
            if (sortOrder != null) MapEntry('sort_order', '$sortOrder'),
          ],
          files: [UploadFile('photo', photoPath)],
        ),
      );
    } else {
      body = await _api.patch(
        '/me/services/$id',
        json: {
          'name': ?name,
          'price': ?price,
          'duration_min': ?durationMin,
          'description': ?description,
          'is_hidden': ?isHidden,
          'sort_order': ?sortOrder,
        },
      );
    }
    return ApiService.fromJson(asMap(unwrapData(body)));
  }

  Future<void> deleteService(int id) async {
    await _api.delete('/me/services/$id');
  }

  // ---- schedule ---------------------------------------------------------

  Future<Schedule> schedule() async =>
      Schedule.fromJson(asMap(unwrapData(await _api.get('/me/schedule'))));

  /// Replaces the whole week; [days] must hold exactly seven entries.
  Future<Schedule> saveSchedule(List<ScheduleDay> days) async {
    final body = await _api.put(
      '/me/schedule',
      json: {'days': [for (final d in days) d.toJson()]},
    );
    return Schedule.fromJson(asMap(unwrapData(body)));
  }

  Future<ScheduleOverride> addOverride({
    required DateTime date,
    required OverrideType type,
    String? startTime,
    String? endTime,
  }) async {
    final body = await _api.post(
      '/me/schedule/overrides',
      json: {
        'date': formatApiDate(date),
        'type': type == OverrideType.dayOff ? 'day_off' : 'custom_hours',
        'start_time': type == OverrideType.customHours ? startTime : null,
        'end_time': type == OverrideType.customHours ? endTime : null,
      },
    );
    return ScheduleOverride.fromJson(asMap(unwrapData(body)));
  }

  Future<void> deleteOverride(int id) async {
    await _api.delete('/me/schedule/overrides/$id');
  }

  Future<Vacation> addVacation(DateTime start, DateTime end) async {
    final body = await _api.post(
      '/me/vacations',
      json: {'start_date': formatApiDate(start), 'end_date': formatApiDate(end)},
    );
    return Vacation.fromJson(asMap(unwrapData(body)));
  }

  Future<void> deleteVacation(int id) async {
    await _api.delete('/me/vacations/$id');
  }

  // ---- calendar & appointments -----------------------------------------

  Future<List<MasterAppointment>> calendar(DateTime from, DateTime to) async => [
    for (final a in asMapList(
      unwrapData(
        await _api.get(
          '/me/calendar',
          query: {'from': formatApiDate(from), 'to': formatApiDate(to)},
        ),
      ),
    ))
      MasterAppointment.fromJson(a),
  ];

  /// Manual booking for a walk-in or phone client. 403
  /// `SUBSCRIPTION_SUSPENDED` while the subscription is not active.
  Future<MasterAppointment> createAppointment({
    required String name,
    required int serviceId,
    required DateTime startsAt,
    String? phone,
  }) async {
    final body = await _api.post(
      '/me/appointments',
      json: {
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'service_id': serviceId,
        'starts_at': formatApiDateTime(startsAt),
      },
    );
    return MasterAppointment.fromJson(asMap(unwrapData(body)));
  }

  Future<void> setAppointmentStatus(int id, ApiAppointmentStatus status) async {
    await _api.patch('/me/appointments/$id/status', json: {'status': status.wire});
  }

  Future<void> moveAppointment(int id, DateTime startsAt) async {
    await _api.patch(
      '/me/appointments/$id/move',
      json: {'starts_at': formatApiDateTime(startsAt)},
    );
  }

  // ---- clients ----------------------------------------------------------

  /// [sort]: `nearest` (default), `name`, `last_visit`, `visits`.
  Future<ApiPage<ClientSummary>> clients({String? query, String? sort, String? cursor}) async =>
      ApiPage.fromJson(
        await _api.get(
          '/me/clients',
          query: {
            'query': (query == null || query.isEmpty) ? null : query,
            'sort': sort,
            'cursor': cursor,
          },
        ),
        ClientSummary.fromJson,
      );

  Future<ClientCard> clientCard(String id) async =>
      ClientCard.fromJson(asMap(unwrapData(await _api.get('/me/clients/$id'))));

  Future<void> setClientNote(String id, String note) async {
    await _api.patch('/me/clients/$id', json: {'private_note': note});
  }

  Future<void> removeClient(String id) async {
    await _api.delete('/me/clients/$id');
  }

  // ---- connection requests ---------------------------------------------

  Future<List<ConnectionRequest>> connectionRequests() async => [
    for (final r in asMapList(unwrapData(await _api.get('/me/connection-requests'))))
      ConnectionRequest.fromJson(r),
  ];

  Future<void> acceptConnectionRequest(int id) async {
    await _api.post('/me/connection-requests/$id/accept');
  }

  Future<void> declineConnectionRequest(int id) async {
    await _api.post('/me/connection-requests/$id/decline');
  }

  static String _num(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';
}
