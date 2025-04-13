class DogBreed {
  final int id;
  final String name;
  final String nameEn;
  final String nameKo;
  final String size;
  final String sizeEn;
  final String sizeKo;
  final String weight;
  final String weightEn;
  final String weightKo;
  final String lifespan;
  final String lifespanEn;
  final String lifespanKo;
  final String origin;
  final String originEn;
  final String originKo;
  final String description;
  final String descriptionEn;
  final String descriptionKo;
  final String imageUrl;

  DogBreed({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameKo,
    required this.size,
    required this.sizeEn,
    required this.sizeKo,
    required this.weight,
    required this.weightEn,
    required this.weightKo,
    required this.lifespan,
    required this.lifespanEn,
    required this.lifespanKo,
    required this.origin,
    required this.originEn,
    required this.originKo,
    required this.description,
    required this.descriptionEn,
    required this.descriptionKo,
    required this.imageUrl,
  });

  factory DogBreed.fromJson(Map<String, dynamic> json) {
    return DogBreed(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      nameKo: json['nameKo'] as String,
      size: json['size'] as String,
      sizeEn: json['sizeEn'] as String,
      sizeKo: json['sizeKo'] as String,
      weight: json['weight'] as String,
      weightEn: json['weightEn'] as String,
      weightKo: json['weightKo'] as String,
      lifespan: json['lifespan'] as String,
      lifespanEn: json['lifespanEn'] as String,
      lifespanKo: json['lifespanKo'] as String,
      origin: json['origin'] as String,
      originEn: json['originEn'] as String,
      originKo: json['originKo'] as String,
      description: json['description'] as String,
      descriptionEn: json['descriptionEn'] as String,
      descriptionKo: json['descriptionKo'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'nameKo': nameKo,
      'size': size,
      'sizeEn': sizeEn,
      'sizeKo': sizeKo,
      'weight': weight,
      'weightEn': weightEn,
      'weightKo': weightKo,
      'lifespan': lifespan,
      'lifespanEn': lifespanEn,
      'lifespanKo': lifespanKo,
      'origin': origin,
      'originEn': originEn,
      'originKo': originKo,
      'description': description,
      'descriptionEn': descriptionEn,
      'descriptionKo': descriptionKo,
      'imageUrl': imageUrl,
    };
  }
} 