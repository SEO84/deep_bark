import 'lat_lng.dart';

class DogBreed {
  final String id;
  final String name;
  final String nameEn;
  final String nameKo;
  final String? origin;
  final String? description;
  final String? imageUrl;
  final String? size;
  final String? weight;
  final String? lifespan;
  final String? temperament;
  final double? confidence;
  final LatLng? originLatLng;

  const DogBreed({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameKo,
    this.origin,
    this.description,
    this.imageUrl,
    this.size,
    this.weight,
    this.lifespan,
    this.temperament,
    this.confidence,
    this.originLatLng,
  });

  DogBreed copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? nameKo,
    String? origin,
    String? description,
    String? imageUrl,
    String? size,
    String? weight,
    String? lifespan,
    String? temperament,
    double? confidence,
    LatLng? originLatLng,
  }) {
    return DogBreed(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      nameKo: nameKo ?? this.nameKo,
      origin: origin ?? this.origin,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      lifespan: lifespan ?? this.lifespan,
      temperament: temperament ?? this.temperament,
      confidence: confidence ?? this.confidence,
      originLatLng: originLatLng ?? this.originLatLng,
    );
  }
}

class MixDog {
  final String id;
  final String nameEn;
  final String nameKo;
  final String breed1;
  final String breed2;
  final String? imageUrl;
  final double? confidence;

  MixDog({
    required this.id,
    required this.nameEn,
    required this.nameKo,
    required this.breed1,
    required this.breed2,
    this.imageUrl,
    this.confidence,
  });

  MixDog copyWith({
    String? id,
    String? nameEn,
    String? nameKo,
    String? breed1,
    String? breed2,
    String? imageUrl,
    double? confidence,
  }) {
    return MixDog(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameKo: nameKo ?? this.nameKo,
      breed1: breed1 ?? this.breed1,
      breed2: breed2 ?? this.breed2,
      imageUrl: imageUrl ?? this.imageUrl,
      confidence: confidence ?? this.confidence,
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng({required this.latitude, required this.longitude});
}
