import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/models/salon_service.dart';
import '../../../data/repositories/master_repository.dart';

/// The master's own service catalogue (`/me/services`). The server is the
/// source of truth: every change goes there first and the list is updated
/// from its answer (a hide/show toggle is applied at once and rolled back if
/// the call fails).
class ServiceProvider extends SessionScoped {
  ServiceProvider(this._repository);

  final MasterRepository _repository;

  List<SalonService> _services = const [];
  bool _loading = false;
  ApiException? _error;

  List<SalonService> get services => List.unmodifiable(_services);
  int get activeCount => _services.where((service) => service.active).length;
  bool get loading => _loading;
  ApiException? get error => _error;

  @override
  void reset() {
    _services = const [];
    _loading = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (me.isMaster) await load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _repository.services();
      _services = [for (final s in list) SalonService.fromApi(s)];
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading services failed: $e');
    }
    _loading = false;
    notifyListeners();
  }

  /// Creates a service; the server requires a photo. Throws `ApiException`.
  Future<void> add({
    required String name,
    required String description,
    required int price,
    required int minutes,
    required String photoPath,
  }) async {
    final created = await _repository.createService(
      name: name,
      description: description,
      price: price.toDouble(),
      durationMin: minutes,
      photoPath: photoPath,
    );
    _services = [..._services, SalonService.fromApi(created)];
    notifyListeners();
  }

  /// Saves edits; pass [photoPath] only when the photo was replaced.
  Future<void> update(SalonService service, {String? photoPath}) async {
    final saved = await _repository.updateService(
      int.parse(service.id),
      name: service.name,
      description: service.description,
      price: service.price.toDouble(),
      durationMin: service.minutes,
      photoPath: photoPath,
    );
    _replace(SalonService.fromApi(saved));
  }

  Future<void> remove(String id) async {
    await _repository.deleteService(int.parse(id));
    _services = [
      for (final s in _services)
        if (s.id != id) s,
    ];
    notifyListeners();
  }

  /// Hides/shows the service for clients (`is_hidden`).
  Future<void> toggleActive(String id) async {
    final index = _services.indexWhere((service) => service.id == id);
    if (index == -1) return;
    final before = _services[index];
    _services = [..._services]..[index] = before.copyWith(active: !before.active);
    notifyListeners();
    try {
      final saved = await _repository.updateService(
        int.parse(id),
        isHidden: before.active,
      );
      _replace(SalonService.fromApi(saved));
    } catch (_) {
      final i = _services.indexWhere((service) => service.id == id);
      if (i != -1) {
        _services = [..._services]..[i] = before;
        notifyListeners();
      }
      rethrow;
    }
  }

  void _replace(SalonService service) {
    final index = _services.indexWhere((existing) => existing.id == service.id);
    if (index == -1) return;
    _services = [..._services]..[index] = service;
    notifyListeners();
  }
}
