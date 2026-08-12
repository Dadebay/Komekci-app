/// Loyalty tier a customer currently holds. Mutually exclusive — a customer
/// carries exactly one status at a time, changed from the customer's detail page.
enum CustomerStatus { newClient, regular, vip }

/// A single past (or upcoming) booking, used to build the visit history and
/// the aggregate stats (total visits, total spent, last visit date).
class CustomerVisit {
  const CustomerVisit({
    required this.date,
    required this.serviceName,
    required this.price,
  });

  final DateTime date;
  final String serviceName;
  final int price;
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    this.nickname = '',
    this.photoPath = '',
    this.visits = const [],
    this.note = '',
    this.nextVisit,
  });

  final String id;
  final String name;
  final String phone;
  final CustomerStatus status;

  /// Optional handle/nickname the master can attach, e.g. an Instagram tag.
  final String nickname;

  /// Local file path for a picked photo. Empty when the customer has none.
  final String photoPath;

  /// Sorted newest first.
  final List<CustomerVisit> visits;
  final String note;
  final DateTime? nextVisit;

  CustomerVisit? get lastVisit => visits.isEmpty ? null : visits.first;
  DateTime? get lastVisitDate => lastVisit?.date;
  int get totalVisits => visits.length;
  int get totalSpent => visits.fold(0, (sum, visit) => sum + visit.price);

  /// A customer who hasn't come in over a month surfaces in the
  /// "Uzak wagt gelmedi" filter.
  bool isInactive(DateTime now) {
    final last = lastVisitDate;
    if (last == null) return true;
    return now.difference(last).inDays > 30;
  }

  Customer copyWith({
    String? name,
    String? phone,
    CustomerStatus? status,
    String? nickname,
    String? photoPath,
    List<CustomerVisit>? visits,
    String? note,
    DateTime? nextVisit,
  }) => Customer(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    status: status ?? this.status,
    nickname: nickname ?? this.nickname,
    photoPath: photoPath ?? this.photoPath,
    visits: visits ?? this.visits,
    note: note ?? this.note,
    nextVisit: nextVisit ?? this.nextVisit,
  );
}
