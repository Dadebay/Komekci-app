import 'package:flutter/foundation.dart';

import '../../../data/models/customer.dart';

enum CustomerFilter { all, vip, regular, newClient, inactive }

/// In-memory customer book. Seeded with mock rows until the backend lands —
/// swap [_seed] for a repository call and the UI stays as is.
class CustomerProvider extends ChangeNotifier {
  CustomerProvider() : _customers = List.of(_seed);

  final List<Customer> _customers;
  String _query = '';
  CustomerFilter _filter = CustomerFilter.all;

  List<Customer> get customers => List.unmodifiable(_customers);
  String get query => _query;
  CustomerFilter get filter => _filter;

  int get allCount => _customers.length;
  int get vipCount =>
      _customers.where((c) => c.status == CustomerStatus.vip).length;
  int get regularCount =>
      _customers.where((c) => c.status == CustomerStatus.regular).length;
  int get newCount =>
      _customers.where((c) => c.status == CustomerStatus.newClient).length;
  int get inactiveCount =>
      _customers.where((c) => c.isInactive(DateTime.now())).length;

  /// Customers after the active filter chip and the search query are applied,
  /// most recently visited first.
  List<Customer> get visible {
    final now = DateTime.now();
    Iterable<Customer> list = _customers;
    switch (_filter) {
      case CustomerFilter.all:
        break;
      case CustomerFilter.vip:
        list = list.where((c) => c.status == CustomerStatus.vip);
      case CustomerFilter.regular:
        list = list.where((c) => c.status == CustomerStatus.regular);
      case CustomerFilter.newClient:
        list = list.where((c) => c.status == CustomerStatus.newClient);
      case CustomerFilter.inactive:
        list = list.where((c) => c.isInactive(now));
    }
    if (_query.trim().isNotEmpty) {
      final needle = _query.trim().toLowerCase();
      final digits = needle.replaceAll(RegExp(r'\s+'), '');
      list = list.where(
        (c) =>
            c.name.toLowerCase().contains(needle) ||
            c.phone.replaceAll(' ', '').contains(digits),
      );
    }
    final sorted = list.toList()
      ..sort((a, b) {
        final aDate = a.lastVisitDate;
        final bDate = b.lastVisitDate;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    return sorted;
  }

  Customer byId(String id) => _customers.firstWhere((c) => c.id == id);

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(CustomerFilter value) {
    _filter = value;
    notifyListeners();
  }

  void add(Customer customer) {
    _customers.insert(0, customer);
    notifyListeners();
  }

  void update(Customer customer) {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index == -1) return;
    _customers[index] = customer;
    notifyListeners();
  }

  void updateStatus(String id, CustomerStatus status) {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _customers[index] = _customers[index].copyWith(status: status);
    notifyListeners();
  }

  void remove(String id) {
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  static final DateTime _anchor = DateTime(2026, 8, 12);

  static const _serviceCatalog = [
    ('Saç kesmek we fen', 50),
    ('Saç reňklemek', 80),
    ('Keratin prosedurasy', 100),
    ('Manikýur', 40),
    ('Gaş düzeltmek', 30),
    ('Saç ukalamak', 70),
  ];

  static List<CustomerVisit> _visits({
    required int count,
    required int daysSinceLast,
    required int seed,
    int spacing = 16,
  }) => List.generate(count, (i) {
    final service = _serviceCatalog[(seed + i) % _serviceCatalog.length];
    final date = _anchor
        .subtract(Duration(days: daysSinceLast + i * spacing))
        .add(Duration(hours: 9 + ((seed + i * 3) % 9), minutes: ((seed + i) * 15) % 60));
    return CustomerVisit(date: date, serviceName: service.$1, price: service.$2);
  });

  static Customer _c({
    required String id,
    required String name,
    required String phone,
    required CustomerStatus status,
    required int daysSinceLast,
    required int visitCount,
    required int seed,
    String note = '',
    DateTime? nextVisit,
  }) => Customer(
    id: id,
    name: name,
    phone: phone,
    status: status,
    visits: _visits(count: visitCount, daysSinceLast: daysSinceLast, seed: seed),
    note: note,
    nextVisit: nextVisit,
  );

  /// Fixed, hand-tuned visit list so the very first (VIP) customer matches the
  /// product mock exactly: 12 visits, 960 manat total, note included.
  static final List<CustomerVisit> _c1Visits = [
    CustomerVisit(date: DateTime(2026, 8, 1, 14, 30), serviceName: 'Saç kesmek we fen', price: 50),
    CustomerVisit(date: DateTime(2026, 7, 20, 12, 0), serviceName: 'Saç reňklemek', price: 80),
    CustomerVisit(date: DateTime(2026, 7, 5, 11, 30), serviceName: 'Keratin prosedurasy', price: 100),
    CustomerVisit(date: DateTime(2026, 6, 20, 15, 0), serviceName: 'Saç kesmek we fen', price: 50),
    CustomerVisit(date: DateTime(2026, 6, 5, 10, 0), serviceName: 'Saç kesmek we fen', price: 90),
    CustomerVisit(date: DateTime(2026, 5, 18, 13, 0), serviceName: 'Saç reňklemek', price: 80),
    CustomerVisit(date: DateTime(2026, 5, 2, 11, 0), serviceName: 'Gaş düzeltmek', price: 70),
    CustomerVisit(date: DateTime(2026, 4, 15, 14, 0), serviceName: 'Saç kesmek we fen', price: 90),
    CustomerVisit(date: DateTime(2026, 3, 28, 10, 30), serviceName: 'Manikýur', price: 80),
    CustomerVisit(date: DateTime(2026, 3, 10, 16, 0), serviceName: 'Saç kesmek we fen', price: 70),
    CustomerVisit(date: DateTime(2026, 2, 22, 12, 0), serviceName: 'Keratin prosedurasy', price: 100),
    CustomerVisit(date: DateTime(2026, 2, 5, 15, 0), serviceName: 'Saç reňklemek', price: 100),
  ];

  static final List<Customer> _seed = [
    Customer(
      id: 'c1',
      name: 'Aýjemal Annagulyýewa',
      phone: '+993 65 123456',
      status: CustomerStatus.vip,
      visits: _c1Visits,
      note: 'Saçyň gysga kesmegini halaýar. Reňk: goňur ton. Allergiýasy ýok.',
      nextVisit: DateTime(2026, 8, 20, 15, 30),
    ),
    _c(id: 'c2', name: 'Gülşirin Mämmedowa', phone: '+993 64 987654', status: CustomerStatus.regular, daysSinceLast: 13, visitCount: 6, seed: 1),
    _c(id: 'c3', name: 'Oguljahan Hydyrowa', phone: '+993 65 456789', status: CustomerStatus.newClient, daysSinceLast: 15, visitCount: 1, seed: 2),
    _c(id: 'c4', name: 'Mähri Gurbanowa', phone: '+993 63 741852', status: CustomerStatus.regular, daysSinceLast: 23, visitCount: 8, seed: 3),
    _c(id: 'c5', name: 'Jeren Myradowa', phone: '+993 65 369852', status: CustomerStatus.vip, daysSinceLast: 33, visitCount: 15, seed: 4),
    _c(id: 'c6', name: 'Nursoltan Jepbarowa', phone: '+993 64 159753', status: CustomerStatus.newClient, daysSinceLast: 38, visitCount: 1, seed: 5),
    _c(id: 'c7', name: 'Aýnabat Saparowa', phone: '+993 62 118820', status: CustomerStatus.vip, daysSinceLast: 5, visitCount: 9, seed: 6),
    _c(id: 'c8', name: 'Bahar Rejepowa', phone: '+993 65 220147', status: CustomerStatus.vip, daysSinceLast: 9, visitCount: 11, seed: 7),
    _c(id: 'c9', name: 'Merdan Öwezow', phone: '+993 61 934512', status: CustomerStatus.vip, daysSinceLast: 18, visitCount: 7, seed: 8),
    _c(id: 'c10', name: 'Gunça Baýramowa', phone: '+993 63 552390', status: CustomerStatus.vip, daysSinceLast: 45, visitCount: 6, seed: 9),
    _c(id: 'c11', name: 'Selbi Atajanowa', phone: '+993 65 555111', status: CustomerStatus.regular, daysSinceLast: 4, visitCount: 10, seed: 10),
    _c(id: 'c12', name: 'Maral Rejepowa', phone: '+993 65 444777', status: CustomerStatus.regular, daysSinceLast: 6, visitCount: 9, seed: 11),
    _c(id: 'c13', name: 'Aýgül Çaryýewa', phone: '+993 62 336119', status: CustomerStatus.regular, daysSinceLast: 8, visitCount: 7, seed: 12),
    _c(id: 'c14', name: 'Ogulnur Baýryýewa', phone: '+993 63 771245', status: CustomerStatus.regular, daysSinceLast: 12, visitCount: 6, seed: 13),
    _c(id: 'c15', name: 'Rahat Hojaýewa', phone: '+993 64 668932', status: CustomerStatus.regular, daysSinceLast: 14, visitCount: 8, seed: 14),
    _c(id: 'c16', name: 'Kerim Annaýew', phone: '+993 61 227788', status: CustomerStatus.regular, daysSinceLast: 17, visitCount: 5, seed: 15),
    _c(id: 'c17', name: 'Bibi Gurbanowa', phone: '+993 65 903214', status: CustomerStatus.regular, daysSinceLast: 19, visitCount: 9, seed: 16),
    _c(id: 'c18', name: 'Sapargeldi Rejepow', phone: '+993 62 445661', status: CustomerStatus.regular, daysSinceLast: 22, visitCount: 6, seed: 17),
    _c(id: 'c19', name: 'Jemal Öwezowa', phone: '+993 63 118745', status: CustomerStatus.regular, daysSinceLast: 25, visitCount: 7, seed: 18),
    _c(id: 'c20', name: 'Aman Sähedow', phone: '+993 61 552903', status: CustomerStatus.regular, daysSinceLast: 29, visitCount: 5, seed: 19),
    _c(id: 'c21', name: 'Gözel Nuryýewa', phone: '+993 65 337781', status: CustomerStatus.regular, daysSinceLast: 34, visitCount: 8, seed: 20),
    _c(id: 'c22', name: 'Amanmyrat Nuryýew', phone: '+993 64 881122', status: CustomerStatus.regular, daysSinceLast: 41, visitCount: 6, seed: 21),
    _c(id: 'c23', name: 'Maksat Geldiýew', phone: '+993 64 987001', status: CustomerStatus.newClient, daysSinceLast: 2, visitCount: 1, seed: 22),
    _c(id: 'c24', name: 'Dowletmyrat Ýazmammedow', phone: '+993 61 777888', status: CustomerStatus.newClient, daysSinceLast: 3, visitCount: 1, seed: 23),
    _c(id: 'c25', name: 'Oguljemal Baýlyýewa', phone: '+993 62 664521', status: CustomerStatus.newClient, daysSinceLast: 6, visitCount: 1, seed: 24),
    _c(id: 'c26', name: 'Serdar Amanow', phone: '+993 65 229981', status: CustomerStatus.newClient, daysSinceLast: 9, visitCount: 2, seed: 25),
    _c(id: 'c27', name: 'Aýnur Halmyradowa', phone: '+993 63 447712', status: CustomerStatus.newClient, daysSinceLast: 1, visitCount: 1, seed: 26),
    _c(id: 'c28', name: 'Begmyrat Öwezow', phone: '+993 61 336655', status: CustomerStatus.newClient, daysSinceLast: 7, visitCount: 1, seed: 27),
  ];
}
