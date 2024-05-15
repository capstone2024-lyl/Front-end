import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled1/services/storage_service.dart';

import '../models/user_info.dart';

class ApiService {

  static const String _baseUrl = 'http://13.209.182.60:8080/api/v1';
  final StorageService _storageService = StorageService();

  Future<void> login(String userId, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/user/login'),
      headers: <String, String> {
        'Content-Type' : 'application/json',
      },
      body: jsonEncode(<String, String> {
        'loginId' : userId,
        'password' : password,
      }),
    );

    if(response.statusCode == 200) {
      var token = jsonDecode(response.body)['accessToken'];
      await _storageService.saveToken(token);
      print(token);
    } else {
      throw Exception('Failed to Login');
    }
  }

  Future<UserInfo?> fetchUserInfo() async {
    final token  = await _storageService.getToken();
    if(token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/user/me'),
      headers: <String,String> {
        'Authorization' :'Bearer $token',
      },
    );

    if(response.statusCode ==200) {
      final decodeBody = utf8.decode(response.bodyBytes);
      return UserInfo.fromJson(jsonDecode(decodeBody));
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<bool> checkIdDuplicated(String id) async {
    final url = Uri.parse(
        '$_baseUrl/user/sign-up/is-duplicated?loginId=$id');
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
}
