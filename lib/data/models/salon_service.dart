/// A service the master offers. [imagePath] is an asset path for seeded mock
/// rows and a local file path for anything the master adds from the picker.
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
