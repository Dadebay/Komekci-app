import 'package:flutter/foundation.dart';

import '../../../data/models/salon_service.dart';

/// In-memory service catalogue. Seeded with mock rows until the backend lands —
/// swap [_seed] for a repository call and the UI stays as is.
class ServiceProvider extends ChangeNotifier {
  final List<SalonService> _services = List.of(_seed);

  List<SalonService> get services => List.unmodifiable(_services);
  int get activeCount => _services.where((service) => service.active).length;

  void add(SalonService service) {
    _services.add(service);
    notifyListeners();
  }

  void update(SalonService service) {
    final index = _services.indexWhere((existing) => existing.id == service.id);
    if (index == -1) return;
    _services[index] = service;
    notifyListeners();
  }

  void remove(String id) {
    _services.removeWhere((service) => service.id == id);
    notifyListeners();
  }

  void toggleActive(String id) {
    final index = _services.indexWhere((service) => service.id == id);
    if (index == -1) return;
    _services[index] = _services[index].copyWith(active: !_services[index].active);
    notifyListeners();
  }

  static const _seed = [
    SalonService(
      id: 's1',
      name: 'Zenanlar üçin saç kesmek',
      description: 'Saçyň görnüşine we uzynlygyna görä kesmek.',
      price: 80,
      minutes: 45,
      imagePath: 'assets/images/v1.png',
      imageIsAsset: true,
    ),
    SalonService(
      id: 's2',
      name: 'Saç boýamak',
      description: 'Ýokary hilli harytlar bilen boýag hyzmaty.',
      price: 150,
      minutes: 90,
      imagePath: 'assets/images/v2.png',
      imageIsAsset: true,
    ),
    SalonService(
      id: 's3',
      name: 'Saç ukalaryny etmek',
      description: 'Dürli görnüşli ukalar we ýörite stiller.',
      price: 70,
      minutes: 40,
      imagePath: 'assets/images/v3.png',
      imageIsAsset: true,
    ),
    SalonService(
      id: 's4',
      name: 'Gaş düzeltmek',
      description: 'Gaşyňyza laýyk şekil bermek we arassalamak.',
      price: 30,
      minutes: 20,
      imagePath: 'assets/images/v4.png',
      imageIsAsset: true,
    ),
    SalonService(
      id: 's5',
      name: 'Manikýur',
      description: 'Elleriň arassalanmagy we timarlanmagy.',
      price: 40,
      minutes: 30,
      imagePath: 'assets/images/v1.png',
      imageIsAsset: true,
    ),
  ];
}
