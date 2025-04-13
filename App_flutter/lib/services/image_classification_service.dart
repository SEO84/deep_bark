import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageClassificationService {
  // 안드로이드 에뮬레이터에서는 10.0.2.2를 사용하여 로컬호스트에 접근
  // static const String baseUrl = 'http://10.0.2.2:5000';
  // 실제 기기에서는 컴퓨터의 IP 주소를 사용
  static const String baseUrl = 'http://192.168.45.180:5000';

  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    try {
      final uri = Uri.parse('$baseUrl/classify');
      final request = http.MultipartRequest('POST', uri);
      
      final file = await http.MultipartFile.fromPath('file', imagePath);
      request.files.add(file);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('서버 응답이 너무 오래 걸립니다.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('이미지 분석 중 오류가 발생했습니다. (상태 코드: ${response.statusCode})');
      }
    } on SocketException catch (e) {
      throw Exception('서버에 연결할 수 없습니다. 네트워크 연결을 확인해주세요.\n$e');
    } on TimeoutException {
      throw Exception('서버 응답 시간이 초과되었습니다.');
    } catch (e) {
      throw Exception('이미지 분석 중 오류가 발생했습니다.\n$e');
    }
  }
} 