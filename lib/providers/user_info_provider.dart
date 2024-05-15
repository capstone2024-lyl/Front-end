import 'package:flutter/material.dart';
import 'package:untitled1/models/user_info.dart';
import 'package:untitled1/services/api_service.dart';


class UserInfoProvider  with ChangeNotifier {
  UserInfo? _userInfo;
  UserInfo? get userInfo => _userInfo;
  final ApiService _apiService = ApiService();

  Future<void> loadUserInfo() async {
    try {
      _userInfo = await _apiService.fetchUserInfo();
      updateMostUsedApp();
    } catch (e) {
      print('Failed to load user info: $e');
    }
  }

  Future<void> updateMostUsedApp() async {
    if(_userInfo != null) {
      await _userInfo!.updateMostUsedApp();
      notifyListeners();
    }
  }
}