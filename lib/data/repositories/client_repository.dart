import '../../core/network/api_client.dart';
import '../models/api/client_models.dart';
import '../models/api/json_helpers.dart';
import '../models/api/user_models.dart';

/// Client-side endpoints: finding and connecting to masters, availability,
/// and the client's own appointments.
class ClientRepository {
  ClientRepository(this._api);
  final ApiClient _api;

  // ---- masters & connections -------------------------------------------

  /// Exact nickname or phone match. Null for a query under 3 characters.
  /// 404 `MASTER_NOT_FOUND` is thrown when nothing matches.
  Future<MasterBrief?> lookupMaster(String query) async {
    final data = unwrapData(await _api.get('/masters/lookup', query: {'q': query}));
    return data is Map<String, dynamic> ? MasterBrief.fromJson(data) : null;
  }

  Future<ClientConnection> connect(int masterId) async => ClientConnection.fromJson(
    asMap(unwrapData(await _api.post('/connections', json: {'master_id': masterId}))),
  );

  Future<List<ClientConnection>> connections() async => [
    for (final c in asMapList(unwrapData(await _api.get('/connections'))))
      ClientConnection.fromJson(c),
  ];

  Future<void> setActiveConnection(int id) async {
    await _api.patch('/connections/$id/active');
  }

  Future<void> removeConnection(int id) async {
    await _api.delete('/connections/$id');
  }

  /// Only for an accepted connection (403 `NOT_CONNECTED` otherwise).
  Future<MasterProfile> master(int id) async =>
      MasterProfile.fromJson(asMap(unwrapData(await _api.get('/masters/$id'))));

  Future<MasterServices> masterServices(int id) async =>
      MasterServices.fromJson(asMap(await _api.get('/masters/$id/services')));

  /// One day via [date], or a range up to 31 days via [from] and [to].
  Future<Availability> availability(
    int masterId, {
    required int serviceId,
    DateTime? date,
    DateTime? from,
    DateTime? to,
  }) async => Availability.fromJson(
    asMap(
      await _api.get(
        '/masters/$masterId/availability',
        query: {
          'service_id': serviceId,
          'date': date == null ? null : formatApiDate(date),
          'from': from == null ? null : formatApiDate(from),
          'to': to == null ? null : formatApiDate(to),
        },
      ),
    ),
  );

  // ---- appointments -----------------------------------------------------

  /// [scope]: `upcoming` (default) or `history`.
  Future<ApiPage<ClientAppointment>> appointments({
    String scope = 'upcoming',
    int? masterId,
    String? status,
    String? cursor,
  }) async => ApiPage.fromJson(
    await _api.get(
      '/appointments',
      query: {'scope': scope, 'master_id': masterId, 'status': status, 'cursor': cursor},
    ),
    ClientAppointment.fromJson,
  );

  /// [idempotencyKey] makes a retry safe: the same key never books twice.
  Future<ClientAppointment> book({
    required int serviceId,
    required DateTime startsAt,
    String? note,
    bool waitlistEarlier = false,
    String? idempotencyKey,
  }) async {
    final body = await _api.post(
      '/appointments',
      json: {
        'service_id': serviceId,
        'starts_at': formatApiDateTime(startsAt),
        if (note != null && note.isNotEmpty) 'note': note,
        'waitlist_earlier': waitlistEarlier,
      },
      headers: idempotencyKey == null ? null : {'Idempotency-Key': idempotencyKey},
    );
    return ClientAppointment.fromJson(asMap(unwrapData(body)));
  }

  Future<void> moveAppointment(int id, DateTime startsAt) async {
    await _api.patch(
      '/appointments/$id/move',
      json: {'starts_at': formatApiDateTime(startsAt)},
    );
  }

  Future<void> cancelAppointment(int id) async {
    await _api.post('/appointments/$id/cancel');
  }

  /// [minutes] is 5 or 10.
  Future<void> reportLate(int id, int minutes) async {
    await _api.post('/appointments/$id/late', json: {'minutes': minutes});
  }

  /// Without [startsAt] the server looks for the same time in the coming
  /// days; a clash throws `SLOT_TAKEN` carrying `suggested_slots`.
  Future<ClientAppointment> rebook(int id, {DateTime? startsAt}) async {
    final body = await _api.post(
      '/appointments/$id/rebook',
      json: startsAt == null ? null : {'starts_at': formatApiDateTime(startsAt)},
    );
    return ClientAppointment.fromJson(asMap(unwrapData(body)));
  }

  // ---- waitlist ---------------------------------------------------------

  Future<void> acceptWaitlistOffer(int id) async {
    await _api.post('/waitlist/$id/accept');
  }

  Future<void> declineWaitlistOffer(int id) async {
    await _api.post('/waitlist/$id/decline');
  }
}
