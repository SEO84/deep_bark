import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pure_dogs.dart';
import '../models/mix_dogs.dart';
import 'package:geocoding/geocoding.dart';
import 'dog_breed_service.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/locale_provider.dart';

class PureDogsService {
  static final PureDogsService _instance = PureDogsService._internal();
  factory PureDogsService() => _instance;
  PureDogsService._internal();

  final _httpClient = http.Client();
  final _dogBreedService = DogBreedService();
  final String baseUrl = 'http://192.168.45.180:8080';

  String _normalizeTitle(String title) {
    return title.replaceAll(' ', '_');
  }

  Future<List<PureDogs>> getAllPureDogs(BuildContext context) async {
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('$baseUrl/api/pure-dogs'),
        headers: {'Accept-Language': localeProvider.locale.languageCode},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        final List<PureDogs> breeds = [];

        for (var breedJson in jsonList) {
          // 위키피디아에서 이미지 가져오기
          String? imageUrl;
          try {
            final breedName = localeProvider.locale.languageCode == 'en' 
              ? breedJson['nameEn'] 
              : breedJson['nameKo'];
            
            // 위키피디아에서 이미지 가져오기
            imageUrl = await getWikipediaImage(breedName, context);
            
            // 위키피디아에서 실패하면 Dog API에서 가져오기
            if (imageUrl == null) {
              imageUrl = await _dogBreedService.getDogApiImage(breedJson['nameEn']);
            }
          } catch (e) {
            print('이미지 가져오기 오류: $e');
          }

          final breed = PureDogs.fromJson(breedJson);
          breed.imageUrl = imageUrl;
          breeds.add(breed);
        }

        return breeds;
      } else {
        throw Exception('Failed to load pure dogs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String?> getWikipediaContent(String breedName, BuildContext context) async {
    try {
      final languageCode = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
      final normalizedTitle = _normalizeTitle(breedName);
      final response = await http.get(
        Uri.parse('https://${languageCode}.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro=1&explaintext=1&titles=$normalizedTitle'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'];
        final pageId = pages.keys.first;
        return pages[pageId]['extract'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getWikipediaImage(String breedName, BuildContext context) async {
    try {
      final languageCode = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
      final normalizedTitle = _normalizeTitle(breedName);
      final response = await http.get(
        Uri.parse('https://${languageCode}.wikipedia.org/w/api.php?action=query&format=json&prop=pageimages&pithumbsize=500&titles=$normalizedTitle'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'];
        final pageId = pages.keys.first;
        return pages[pageId]['thumbnail']?['source'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> analyzeImage(File image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/analyze'));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        if (data['type'] == 'pure') {
          return PureDogs.fromJson(data['breed']);
        } else {
          return MixDogs.fromJson(data['breed']);
        }
      } else {
        throw Exception('Failed to analyze image');
      }
    } catch (e) {
      print('이미지 분석 오류: $e');
      throw Exception('Error analyzing image: $e');
    }
  }

  Stream<PureDogs> getAllPureDogsStream(BuildContext context) async* {
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('$baseUrl/api/pure-dogs'),
        headers: {'Accept-Language': localeProvider.locale.languageCode},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        
        for (var breedJson in jsonList) {
          // 위키피디아에서 이미지 가져오기
          String? imageUrl;
          try {
            final breedName = localeProvider.locale.languageCode == 'en' 
              ? breedJson['nameEn'] 
              : breedJson['nameKo'];
            
            // 위키피디아에서 이미지 가져오기
            imageUrl = await getWikipediaImage(breedName, context);
            
            // 위키피디아에서 실패하면 Dog API에서 가져오기
            if (imageUrl == null) {
              imageUrl = await _dogBreedService.getDogApiImage(breedJson['nameEn']);
            }
          } catch (e) {
            print('이미지 가져오기 오류: $e');
          }

          final breed = PureDogs.fromJson(breedJson);
          breed.imageUrl = imageUrl;
          yield breed;
        }
      } else {
        throw Exception('Failed to load pure dogs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<MixDogs?> getMixBreedInfo(String breed1, String breed2) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mix-breeds?breed1=$breed1&breed2=$breed2'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return MixDogs.fromJson(data);
      }
      return null;
    } catch (e) {
      print('믹스견종 정보 가져오기 오류: $e');
      return null;
    }
  }

  void dispose() {
    _httpClient.close();
    _dogBreedService.dispose();
  }
}
