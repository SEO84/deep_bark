class MixDog {
  final String id;
  final String nameEn;
  final String nameKo;
  final String breed1;
  final String breed2;
  final double confidence;

  MixDog({
    required this.id,
    required this.nameEn,
    required this.nameKo,
    required this.breed1,
    required this.breed2,
    this.confidence = 0.0,
  });

  MixDog copyWith({
    String? id,
    String? nameEn,
    String? nameKo,
    String? breed1,
    String? breed2,
    double? confidence,
  }) {
    return MixDog(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameKo: nameKo ?? this.nameKo,
      breed1: breed1 ?? this.breed1,
      breed2: breed2 ?? this.breed2,
      confidence: confidence ?? this.confidence,
    );
  }
} 