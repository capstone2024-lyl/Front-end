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
      await _userInfo!.initMostUsedApp();
      notifyListeners();
    } catch (e) {
      print('Failed to load user info: $e');
    }
  }

  Future<void> updateUserAppUsageData(List<Map<String,dynamic>> appUsageData) async {
    _userInfo!.appList = appUsageData;
    await _userInfo!.initMostUsedApp();
    notifyListeners();
  }

  Future<void> updateAppAnalyzeStatus(bool isDone) async {
    _userInfo!.analyzeStatus['appUsageAnalyzeStatus'] = isDone;
    notifyListeners();
  }

  Future<void> updateYoutubeTop3Category(List<String> updateList) async {
    _userInfo!.youtubeTop3category.clear();
    _userInfo!.youtubeTop3category = updateList;
    notifyListeners();
  }
}