import 'package:google_maps_flutter/google_maps_flutter.dart';

class PureDogs {
  final int id;
  final String nameEn;
  final String nameKo;
  final String sizeEn;
  final String sizeKo;
  final String weight;
  final String lifespan;
  final String originEn;
  final String originKo;
  String? imageUrl;
  LatLng? originLatLng;

  PureDogs({
    required this.id,
    required this.nameEn,
    required this.nameKo,
    required this.sizeEn,
    required this.sizeKo,
    required this.weight,
    required this.lifespan,
    required this.originEn,
    required this.originKo,
    this.imageUrl,
    this.originLatLng,
  });

  String get origin => originKo.isNotEmpty ? originKo : originEn;

  String get size => sizeKo.isNotEmpty ? sizeKo : sizeEn;

  String get weightEn => weight;
  
  String get lifespanEn => lifespan;

  factory PureDogs.fromJson(Map<String, dynamic> json) {
    try {
      print('JSON 데이터 변환 시작: $json');
      return PureDogs(
        id: json['id'],
        nameEn: json['nameEn'],
        nameKo: json['nameKo'],
        sizeEn: json['sizeEn'] ?? '',
        sizeKo: json['sizeKo'] ?? '',
        weight: json['weight'] ?? '',
        lifespan: json['lifespan'] ?? '',
        originEn: json['originEn'] ?? '',
        originKo: json['originKo'] ?? '',
        imageUrl: json['imageUrl'],
      );
    } catch (e, stackTrace) {
      print('JSON 변환 오류: $e');
      print('스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameKo': nameKo,
      'sizeEn': sizeEn,
      'sizeKo': sizeKo,
      'weight': weight,
      'lifespan': lifespan,
      'originEn': originEn,
      'originKo': originKo,
      'imageUrl': imageUrl,
    };
  }
} 