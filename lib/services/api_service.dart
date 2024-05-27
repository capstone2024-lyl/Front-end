import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:untitled1/services/storage_service.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

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

  Future<bool> requestSignUp({
    required String id,
    required String password,
    required String confirmPassword,
    required String name,
    required String birthday,
    required CroppedFile? profileImage,
  }) async {
    final url = Uri.parse('$_baseUrl/user/sign-up');
    var request = http.MultipartRequest('POST', url);

    var jsonMap = {
      'loginId' : id,
      'password' : password,
      'passwordCheck' : confirmPassword,
      'name' :  name,
      'birthday' : birthday,
    };

    var jsonData = jsonEncode(jsonMap);

    request.fields['application/json'] = jsonData;

    if(profileImage !=null) {
      File profileImg = File(profileImage.path);
      var profileImageStream = http.ByteStream(profileImage.openRead());
      var profileImageLength = await profileImg.length();

      var mimeTypeData = lookupMimeType(profileImg.path, headerBytes: [0xFF, 0xD8])?.split('/');

      var profileImageMultipart = http.MultipartFile(
        'profileImage',
        profileImageStream,
        profileImageLength,
        filename: basename(profileImg.path),
        contentType: MediaType(mimeTypeData![0],mimeTypeData[1]),
      );
      request.files.add(profileImageMultipart);
    }

    final response = await request.send();

    print(response.statusCode);

    if(response.statusCode==200 || response.statusCode==201) {
      print('회원 가입 성공');
      return true;
    } else {
      print('사용자 등록 실패');
      return false;
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
    String fileName = file.path.split('/').last;
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
      final response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body)['apps'];
        List<Map<String, dynamic>> appUsageData =
            List<Map<String, dynamic>>.from(jsonData);
        print(appUsageData);
        return appUsageData;
      } else {
        print('failed ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print(e);
      print('[error] 앱 사용 정보를 가져오는데 에러가 발생함');
      return [];
    }
  }

  Future<bool> getAppUsageIsDone() async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/app/findTop10');

    if (token == null) {
      throw Exception('No token Found');
    }
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final isChecked = jsonDecode(response.body)['isChecked'] as bool;

        return isChecked;
      } else {
        print('failed ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print(e);
      print('[error] 앱 사용 정보를 가져오는데 에러가 발생함');
      return false;
    }
  }

  //TODO chatAPI 완성되면 주석 삭제
  // Future<List<Map<String,dynamic>> getUserMbti() async {
  //   final token = _storageService.getToken();
  //   final url = Uri.parse('$_baseUrl/')
  // }

  Future<bool> postYoutubeData(String accessToken) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('$_baseUrl/youtube/subscriptions');
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.post(url, headers: <String, String>{
        'X-Google-Token': accessToken,
        'Authorization': 'Bearer $token',
      });
      print(response.statusCode);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(
        'error: cannot post youtube data',
      );
      return false;
    }
  }

  Future<List<String>> getYoutubeTop3Category() async {
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final url = Uri.parse('$_baseUrl/youtube/findTop3Category');
    try {
      final response = await http.get(url, headers: <String, String>{
        'authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['youtubeCategoryList'];
        return List<String>.from(result);
      } else {
        print('wrong status code : ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('cannot Get Youtube top3 category');
      return [];
    }
  }
}
