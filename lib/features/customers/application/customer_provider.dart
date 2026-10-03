import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/master_repository.dart';

enum CustomerFilter { all, vip, regular, newClient, inactive }

/// The master's client book (`/me/clients`). Search and the status chips
/// filter the loaded list on the device; the full card (visit history and
/// private note) is fetched when a client is opened.
class CustomerProvider extends SessionScoped {
  CustomerProvider(this._repository);

  final MasterRepository _repository;

  /// Pages fetched at most when loading the whole book.
  static const _maxPages = 20;

  List<Customer> _customers = const [];
  String _query = '';
  CustomerFilter _filter = CustomerFilter.all;
  bool _loading = false;
  ApiException? _error;

  List<Customer> get customers => List.unmodifiable(_customers);
  String get query => _query;
  CustomerFilter get filter => _filter;
  bool get loading => _loading;
  ApiException? get error => _error;

  int get allCount => _customers.length;
  int get vipCount => _customers.where((c) => c.status == CustomerStatus.vip).length;
  int get regularCount => _customers.where((c) => c.status == CustomerStatus.regular).length;
  int get newCount => _customers.where((c) => c.status == CustomerStatus.newClient).length;
  int get inactiveCount => _customers.where((c) => c.isInactive(DateTime.now())).length;

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
            c.nickname.toLowerCase().contains(needle) ||
            c.phone.replaceAll(' ', '').contains(digits),
      );
    }
    final sorted = list.toList()
      ..sort((a, b) {
        final aDate = a.lastVisitDate;
        final bDate = b.lastVisitDate;
        if (aDate == null && bDate == null) return a.name.compareTo(b.name);
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    return sorted;
  }

  Customer? byIdOrNull(String id) {
    for (final c in _customers) {
      if (c.id == id) return c;
    }
    return null;
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

  @override
  void reset() {
    _customers = const [];
    _query = '';
    _filter = CustomerFilter.all;
    _loading = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (me.isMaster) await load();
  }

  /// Loads the whole client book, page by page.
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final all = <Customer>[];
      String? cursor;
      var pages = 0;
      do {
        final page = await _repository.clients(cursor: cursor);
        all.addAll(page.items.map(Customer.fromSummary));
        cursor = page.nextCursor;
      } while (cursor != null && ++pages < _maxPages);
      // Keep any card details already fetched for a client.
      _customers = [
        for (final c in all)
          if (byIdOrNull(c.id) case final old? when old.hasCard)
            c.copyWith(note: old.note, visits: old.visits)
          else
            c,
      ];
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading clients failed: $e');
    }
    _loading = false;
    notifyListeners();
  }

  /// Fetches the visit history and private note for [id].
  Future<Customer?> loadCard(String id) async {
    final current = byIdOrNull(id);
    if (current == null) return null;
    final card = await _repository.clientCard(id);
    final updated = current.withCard(card);
    _customers = [for (final c in _customers) c.id == id ? updated : c];
    notifyListeners();
    return updated;
  }

  /// Saves the master's private note (the only editable client field).
  Future<void> saveNote(String id, String note) async {
    await _repository.setClientNote(id, note);
    final current = byIdOrNull(id);
    if (current == null) return;
    _customers = [for (final c in _customers) c.id == id ? c.copyWith(note: note) : c];
    notifyListeners();
  }

  /// Removes the client from the book (`DELETE /me/clients/{id}`).
  Future<void> remove(String id) async {
    await _repository.removeClient(id);
    _customers = [
      for (final c in _customers)
        if (c.id != id) c,
    ];
    notifyListeners();
  }
}
