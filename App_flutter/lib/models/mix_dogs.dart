import 'pure_dogs.dart';

class MixDogs {
  final int id;
  final String nameEn;
  final String nameKo;
  final String breed1;
  final String breed2;

  MixDogs({
    required this.id,
    required this.nameEn,
    required this.nameKo,
    required this.breed1,
    required this.breed2,
  });

  factory MixDogs.fromJson(Map<String, dynamic> json) {
    try {
      print('JSON 데이터 변환 시작: $json');
      return MixDogs(
        id: json['id'] as int,
        nameEn: json['nameEn'] as String? ?? '',
        nameKo: json['nameKo'] as String? ?? '',
        breed1: json['breed1'] as String? ?? '',
        breed2: json['breed2'] as String? ?? '',
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
      'breed1': breed1,
      'breed2': breed2,
    };
  }
} 