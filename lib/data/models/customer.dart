import 'api/master_models.dart';

/// Loyalty tier the server reports for a client. Mutually exclusive.
enum CustomerStatus { newClient, regular, vip }

/// A single past (or upcoming) booking, used to build the visit history and
/// the aggregate stats (total visits, total spent, last visit date).
class CustomerVisit {
  const CustomerVisit({
    required this.date,
    required this.serviceName,
    required this.price,
    this.status = ApiAppointmentStatus.completed,
  });

  final DateTime date;
  final String serviceName;
  final int price;
  final ApiAppointmentStatus status;
}

/// One of a master's clients (`/me/clients`): either a connected account
/// (`c12`) or an offline client the master typed in (`o4`).
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    this.nickname = '',
    this.photoUrl,
    this.visits = const [],
    this.note = '',
    this.nextVisit,
    this.offline = false,
    this.visitCount = 0,
    this.spent = 0,
    this.noShows = 0,
    this.lastVisit,
    this.nextVisitService,
  });

  final String id;
  final String name;

  /// `+993XXXXXXXX`, or empty when the master never entered one.
  final String phone;
  final CustomerStatus status;
  final String nickname;
  final String? photoUrl;
  final bool offline;

  /// Aggregates from the client list; [visits] only fills in once the full
  /// card has been opened.
  final int visitCount;
  final int spent;
  final int noShows;
  final DateTime? lastVisit;

  /// Sorted newest first. Empty until `GET /me/clients/{id}` has been read.
  final List<CustomerVisit> visits;

  /// The master's private note (only on the full card).
  final String note;
  final DateTime? nextVisit;
  final String? nextVisitService;

  bool get hasCard => visits.isNotEmpty || note.isNotEmpty;

  CustomerVisit? get lastCompletedVisit {
    for (final v in visits) {
      if (v.status == ApiAppointmentStatus.completed) return v;
    }
    return null;
  }

  DateTime? get lastVisitDate => lastVisit;
  int get totalVisits => visitCount;
  int get totalSpent => spent;

  /// A customer who hasn't come in over a month surfaces in the
  /// "Uzak wagt gelmedi" filter.
  bool isInactive(DateTime now) {
    final last = lastVisit;
    if (last == null) return true;
    return now.difference(last).inDays > 30;
  }

  static CustomerStatus parseStatus(String value) {
    final v = value.toLowerCase();
    if (v.contains('vip')) return CustomerStatus.vip;
    if (v.contains('regular') || v.contains('постоян') || v.contains('hemi')) {
      return CustomerStatus.regular;
    }
    return CustomerStatus.newClient;
  }

  factory Customer.fromSummary(ClientSummary c) => Customer(
    id: c.id,
    name: c.name,
    phone: c.phone ?? '',
    status: parseStatus(c.status),
    nickname: c.nickname ?? '',
    photoUrl: c.photoUrl,
    offline: c.offline,
    visitCount: c.visits,
    spent: c.spend.round(),
    noShows: c.noShows,
    lastVisit: c.lastVisit,
    nextVisit: c.appointment?.startsAt,
    nextVisitService: c.appointment?.serviceName,
  );

  /// Fills in the history and note from the full card.
  Customer withCard(ClientCard card) => copyWith(
    note: card.privateNote ?? '',
    visits: [
      for (final h in card.history)
        CustomerVisit(
          date: h.startsAt,
          serviceName: h.serviceName,
          price: h.price.round(),
          status: h.status,
        ),
    ]..sort((a, b) => b.date.compareTo(a.date)),
  );

  Customer copyWith({
    String? name,
    String? phone,
    CustomerStatus? status,
    String? nickname,
    String? photoUrl,
    List<CustomerVisit>? visits,
    String? note,
    DateTime? nextVisit,
    int? visitCount,
    int? spent,
    DateTime? lastVisit,
  }) => Customer(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    status: status ?? this.status,
    nickname: nickname ?? this.nickname,
    photoUrl: photoUrl ?? this.photoUrl,
    offline: offline,
    visitCount: visitCount ?? this.visitCount,
    spent: spent ?? this.spent,
    noShows: noShows,
    lastVisit: lastVisit ?? this.lastVisit,
    visits: visits ?? this.visits,
    note: note ?? this.note,
    nextVisit: nextVisit ?? this.nextVisit,
    nextVisitService: nextVisitService,
  );
}
