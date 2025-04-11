import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dog_breed_model.dart' as models;
import '../models/lat_lng.dart' as latlng;
import '../models/mix_dog.dart' as mix;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'image_cache_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:geocoding/geocoding.dart';

class DogBreedService {
  static final DogBreedService _instance = DogBreedService._internal();
  factory DogBreedService() => _instance;
  DogBreedService._internal();

  final String baseUrl = 'http://10.0.2.2:8080';  // Android 에뮬레이터에서 localhost 접근
  final ImageCacheService _imageCache = ImageCacheService();
  final Map<String, String> _contentCache = {};
  final Map<String, String?> _imageUrlCache = {};
  final Map<String, models.DogBreed> _breedCache = {};
  final Map<String, mix.MixDog> _mixBreedCache = <String, mix.MixDog>{};
  final http.Client _httpClient = http.Client();
  static const int _maxCacheSize = 100;
  Database? _database;
  Map<String, String>? _breedNameMapping;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'dog_breeds.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE pure_dogs (
            id TEXT PRIMARY KEY,
            name_en TEXT NOT NULL,
            name_ko TEXT NOT NULL,
            size TEXT,
            weight TEXT,
            lifespan TEXT,
            origin TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE mix_dogs (
            id TEXT PRIMARY KEY,
            name_en TEXT NOT NULL,
            name_ko TEXT NOT NULL,
            breed1 TEXT NOT NULL,
            breed2 TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Flask 서버 URL (실제 서버 주소로 변경 필요)
  // 실제 기기나 iOS 시뮬레이터에서는 실제 IP 주소 사용 필요
  // 예: final String baseUrl = 'http://192.168.0.100:5000';

  // 영어 견종 이름을 한글로 변환하는 메서드
  Future<String> _convertBreedNameToKorean(String englishName) async {
    if (_breedNameMapping == null) {
      try {
        final String jsonString = await rootBundle.loadString('assets/data/breed_name_mapping.json');
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        _breedNameMapping = Map<String, String>.from(jsonData['mapping']);
      } catch (e) {
        print('견종 이름 매핑 파일 로드 오류: $e');
        _breedNameMapping = {};
      }
    }
    return _breedNameMapping?[englishName] ?? englishName;
  }

  Future<List<dynamic>> analyzeImage(File image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/classify'));
      var stream = http.ByteStream(DelegatingStream.typed(image.openRead()));
      var length = await image.length();
      var multipartFile = http.MultipartFile('image', stream, length, filename: basename(image.path));
      request.files.add(multipartFile);

      var response = await _httpClient.send(request);
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var result = json.decode(responseData);
        List<dynamic> predictions = result['predictions'];

        if (predictions.length >= 2) {
          // 믹스견 처리
          String breed1 = predictions[0]['class'];
          String breed2 = predictions[1]['class'];
          double confidence = (predictions[0]['confidence'] + predictions[1]['confidence']) / 2;

          String koreanBreed1 = await _convertBreedNameToKorean(breed1);
          String koreanBreed2 = await _convertBreedNameToKorean(breed2);

          mix.MixDog mixDog = mix.MixDog(
            id: 'mix_${breed1}_${breed2}',
            nameEn: '${breed1} x ${breed2}',
            nameKo: '${koreanBreed1} x ${koreanBreed2}',
            breed1: breed1,
            breed2: breed2,
            confidence: confidence,
          );

          return [mixDog];
        } else {
          // 순종견 처리
          String englishBreedName = predictions[0]['class'];
          String koreanBreedName = await _convertBreedNameToKorean(englishBreedName);
          double confidence = predictions[0]['confidence'];

          if (_breedCache.containsKey(koreanBreedName)) {
            return [_breedCache[koreanBreedName]!.copyWith(confidence: confidence)];
          }

          String? cachedContent = _contentCache[koreanBreedName];
          String? cachedImageUrl = _imageUrlCache[koreanBreedName];

          String description = cachedContent ?? await getWikipediaContent(koreanBreedName);
          String? imageUrl = cachedImageUrl ?? await getWikipediaImage(koreanBreedName);

          if (cachedContent == null) _contentCache[koreanBreedName] = description;
          if (cachedImageUrl == null) _imageUrlCache[koreanBreedName] = imageUrl;

          models.DogBreed breed = models.DogBreed(
            id: predictions[0]['class'],
            name: koreanBreedName,
            nameEn: englishBreedName,
            nameKo: koreanBreedName,
            origin: '알 수 없음',
            description: description,
            imageUrl: imageUrl,
            confidence: confidence,
          );

          _addToBreedCache(koreanBreedName, breed);
          return [breed];
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 분석 오류: $e');
      return [
        models.DogBreed(
          id: '1',
          name: '분석 오류',
          nameEn: 'Error',
          nameKo: '분석 오류',
          origin: '알 수 없음',
          description: '이미지 분석 중 오류가 발생했습니다: $e',
          imageUrl: 'https://example.com/error.jpg',
        ),
      ];
    }
  }

  void _addToBreedCache(String name, models.DogBreed breed) {
    if (_breedCache.length >= _maxCacheSize) {
      _breedCache.remove(_breedCache.keys.first);
    }
    _breedCache[name] = breed;
  }

  void _addToMixBreedCache(String name, mix.MixDog mixDog) {
    if (_mixBreedCache.length >= _maxCacheSize) {
      _mixBreedCache.remove(_mixBreedCache.keys.first);
    }
    _mixBreedCache[name] = mixDog;
  }

  // 위키백과 페이지 제목 형식으로 변환
  String _normalizeWikiTitle(String title) {
    // 공백을 밑줄로 변환
    String normalized = title.replaceAll(' ', '_');
    // 괄호가 없는 경우 "(개)" 추가
    if (!normalized.contains('(')) {
      normalized += '_(개)';
    }
    return normalized;
  }

  // 위키백과 리다이렉트 처리
  Future<String?> _handleRedirect(Map<String, dynamic> pages) async {
    final pageId = pages.keys.first;
    if (pageId != '-1' && pages[pageId]['redirects'] != null) {
      final redirectTo = pages[pageId]['redirects'][0]['to'];
      return redirectTo;
    }
    return null;
  }

  Future<String> getWikipediaContent(String breedName, [String languageCode = 'ko']) async {
    try {
      // 현재 언어에 맞는 검색어 사용
      final String searchQuery = breedName;
      
      final response = await _httpClient.get(
        Uri.parse('https://$languageCode.wikipedia.org/w/api.php?' +
            'action=query&' +
            'format=json&' +
            'prop=extracts&' +
            'exintro=1&' +
            'explaintext=1&' +
            'titles=$searchQuery'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'];
        final pageId = pages.keys.first;
        if (pageId != '-1') {
          final extract = pages[pageId]['extract'];
          if (extract != null && extract.isNotEmpty) {
            return extract;
          }
        }
        
        // 현재 언어로 검색 실패 시 영어로 재시도
        if (languageCode != 'en') {
          final englishName = _getEnglishBreedName(breedName);
          final enResponse = await _httpClient.get(
            Uri.parse('https://en.wikipedia.org/w/api.php?' +
                'action=query&' +
                'format=json&' +
                'prop=extracts&' +
                'exintro=1&' +
                'explaintext=1&' +
                'titles=$englishName'),
          );

          if (enResponse.statusCode == 200) {
            final enData = json.decode(enResponse.body);
            final enPages = enData['query']['pages'];
            final enPageId = enPages.keys.first;
            if (enPageId != '-1') {
              final enExtract = enPages[enPageId]['extract'];
              if (enExtract != null && enExtract.isNotEmpty) {
                return languageCode == 'ko' 
                    ? '(영문) $enExtract'  // 한글 모드에서는 영문임을 표시
                    : enExtract;
              }
            }
          }
        }
      }
      return getNoWikipediaInfoMessage(languageCode);
    } catch (e) {
      print('위키백과 내용 가져오기 오류: $e');
      return getWikipediaErrorMessage(languageCode, e.toString());
    }
  }

  Future<String?> getWikipediaImage(String breedName, [String languageCode = 'ko']) async {
    try {
      // 항상 영어 이름으로 검색
      final String searchQuery = _getEnglishBreedName(breedName);
      
      final response = await _httpClient.get(
        Uri.parse('https://$languageCode.wikipedia.org/w/api.php?' +
            'action=query&' +
            'format=json&' +
            'prop=pageimages&' +
            'piprop=original&' +
            'titles=$searchQuery'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'];
        final pageId = pages.keys.first;
        if (pageId != '-1' && pages[pageId].containsKey('original')) {
          return pages[pageId]['original']['source'];
        }
      }
      return null;
    } catch (e) {
      print('위키백과 이미지 가져오기 오류: $e');
      return null;
    }
  }

  String _getEnglishBreedName(String koreanName) {
    if (_breedNameMapping == null) return koreanName;
    
    // 한글 이름에 해당하는 영어 이름 찾기
    final englishName = _breedNameMapping!.entries
        .firstWhere(
          (entry) => entry.value == koreanName,
          orElse: () => MapEntry('', ''),
        )
        .key;
    
    return englishName.isNotEmpty ? englishName : koreanName;
  }

  // lat_lng.dart의 LatLng를 dog_breed_model.dart의 LatLng로 변환하는 함수
  models.LatLng convertLatLng(latlng.LatLng sourceLatLng) {
    return models.LatLng(
      latitude: sourceLatLng.latitude,
      longitude: sourceLatLng.longitude
    );
  }

  Future<List<models.DogBreed>> getAllBreeds([String languageCode = 'ko']) async {
    try {
      print('견종 데이터 요청 시작: $baseUrl/api/breeds');
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/breeds'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
      );

      print('서버 응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        print('디코딩된 응답 본문: $decodedBody');
        
        final List<dynamic> data = json.decode(decodedBody);
        print('파싱된 데이터 개수: ${data.length}');
        
        final List<models.DogBreed> breeds = [];
        
        for (var json in data) {
          try {
            final breed = models.DogBreed(
              id: json['id']?.toString() ?? '',
              name: languageCode == 'en' ? json['nameEn'] ?? '' : json['nameKo'] ?? '',
              nameEn: json['nameEn'] ?? '',
              nameKo: json['nameKo'] ?? '',
              origin: json['origin'] ?? '',
              description: '위키백과 정보를 불러오는 중...',
              imageUrl: await getWikipediaImage(json['nameEn'] ?? json['nameKo'], languageCode),
              size: json['size'] ?? '',
              weight: json['weight'] ?? '',
              lifespan: json['lifespan'] ?? '',
            );
            
            // 지오코딩 시도
            final originText = breed.origin ?? '서울';
            try {
              final locations = await locationFromAddress(originText);
              if (locations.isNotEmpty) {
                final location = locations.first;
                final latLng = latlng.LatLng(
                  latitude: location.latitude,
                  longitude: location.longitude,
                );
                breeds.add(breed.copyWith(originLatLng: convertLatLng(latLng)));
              } else {
                print('지오코딩 결과 없음: $originText');
                // 기본값으로 서울 좌표 설정
                final seoulLatLng = latlng.LatLng(
                  latitude: 37.5665,
                  longitude: 126.9780,
                );
                breeds.add(breed.copyWith(originLatLng: convertLatLng(seoulLatLng)));
              }
            } catch (e) {
              print('지오코딩 오류: $originText - $e');
              // 기본값으로 서울 좌표 설정
              final seoulLatLng = latlng.LatLng(
                latitude: 37.5665,
                longitude: 126.9780,
              );
              breeds.add(breed.copyWith(originLatLng: convertLatLng(seoulLatLng)));
            }
          } catch (e) {
            print('견종 데이터 파싱 오류: $e');
            continue;
          }
        }
        
        return breeds;
      } else {
        print('서버 오류 응답: ${response.body}');
        throw Exception('견종 데이터를 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('견종 데이터 가져오기 오류: $e');
      print('스택 트레이스: $stackTrace');
      throw Exception('견종 데이터를 가져오는데 실패했습니다: $e');
    }
  }

  // 각 언어별 메시지 반환
  String getNoInfoMessage(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '(영문)';
      case 'en':
        return '(English)';
      default:
        return '(English)';
    }
  }

  String getNoWikipediaInfoMessage(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '이 견종에 대한 위키백과 정보를 찾을 수 없습니다.';
      case 'en':
        return 'No Wikipedia information found for this breed.';
      default:
        return 'No Wikipedia information found for this breed.';
    }
  }

  String getWikipediaErrorMessage(String languageCode, String error) {
    switch (languageCode) {
      case 'ko':
        return '위키백과 정보를 가져오는 중 오류가 발생했습니다: $error';
      case 'en':
        return 'Error occurred while fetching Wikipedia information: $error';
      default:
        return 'Error occurred while fetching Wikipedia information: $error';
    }
  }

  void dispose() {
    _httpClient.close();
    _contentCache.clear();
    _imageUrlCache.clear();
    _breedCache.clear();
    _mixBreedCache.clear();
  }
}
