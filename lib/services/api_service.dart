import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:untitled1/services/storage_service.dart';

import '../models/user_info.dart';

class ApiService {
  static const String _baseUrl = 'http://13.209.182.60:8080/api/v1';
  final StorageService _storageService = StorageService();

  Future<void> login(String userId, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'loginId': userId,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var token = jsonDecode(response.body)['accessToken'];
      await _storageService.saveToken(token);
    } else {
      throw Exception('Failed to Login');
    }
  }

  Future<UserInfo?> fetchUserInfo() async {
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/user/me'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodeBody = utf8.decode(response.bodyBytes);
      return UserInfo.fromJson(jsonDecode(decodeBody));
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<bool> checkIdDuplicated(String id) async {
    final url = Uri.parse('$_baseUrl/user/sign-up/is-duplicated?loginId=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (response.body == 'can use') {
        return false;
      } else {
        return true;
      }
    } else {
      throw Exception('Failed to check login ID');
    }
  }

  Future<bool> uploadChattingFile(File file) async {
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    List<int> fileBytes = await file.readAsBytes();
    String fileName = file.path
        .split('/')
        .last;
    final httpFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    );
    final url = Uri.parse('$_baseUrl/chat/predict-mbti');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({'Authorization': 'Bearer $token'})
      ..files.add(httpFile);

    final response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Upload success');
      return true;
    } else {
      print('failed to upload');
      return false;
    }
  }

  Future<void> sendAppUsageData(List<dynamic> data) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/app/appUsage');

    if (token == null) {
      throw Exception('No token Found');
    }

    try {
      final jsonString = jsonEncode(data);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: utf8.encode(jsonString),
      );
      if (response.statusCode == 200) {
        print('success');
      } else {
        print('failed');
      }
    } catch (e) {
      print('[Error] : 앱 사용시간 api 오류');
    }
  }

  Future<List<Map<String, dynamic>>> getAppUsageTopTen() async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/app/findTop10');

    if (token == null) {
      throw Exception('No token Found');
    }
    try {
      final response = await http.get(url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> appUsageData = List<
            Map<String, dynamic>>.from(jsonData);
        print(appUsageData);
        return appUsageData;
      } else {
        print('failed ${response.statusCode}');
        print(token.toString());
        return [];
      }
    } catch (e) {
      print('[error] 앱 사용 정보를 가져오는데 에러가 발생함');
      return [];
    }
  }

  Future<void> getYoutubeAnalyzeResult () async {

  }
}