import 'api/master_models.dart';

/// A service the master offers. [imagePath] is the photo URL served by the
/// API (or, for bundled sample art, an asset path).
class SalonService {
  const SalonService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.minutes,
    required this.imagePath,
    this.imageIsAsset = false,
    this.active = true,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final int minutes;
  final String imagePath;
  final bool imageIsAsset;
  final bool active;

  /// True for a photo that lives on the server.
  bool get imageIsNetwork => imagePath.startsWith('http');

  factory SalonService.fromApi(ApiService service) => SalonService(
    id: '${service.id}',
    name: service.name,
    description: service.description,
    price: service.price.round(),
    minutes: service.durationMin,
    imagePath: service.photoUrl ?? '',
    active: !service.isHidden,
  );

  SalonService copyWith({
    String? name,
    String? description,
    int? price,
    int? minutes,
    String? imagePath,
    bool? imageIsAsset,
    bool? active,
  }) => SalonService(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    minutes: minutes ?? this.minutes,
    imagePath: imagePath ?? this.imagePath,
    imageIsAsset: imageIsAsset ?? this.imageIsAsset,
    active: active ?? this.active,
  );
}
