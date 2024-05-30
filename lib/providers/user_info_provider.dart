import 'package:flutter/material.dart';
import 'package:untitled1/models/user_info.dart';
import 'package:untitled1/services/api_service.dart';

class UserInfoProvider with ChangeNotifier {
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

  Future<void> updateUserAppUsageData(
      List<Map<String, dynamic>> appUsageData) async {
    _userInfo!.appList = appUsageData;
    await _userInfo!.initMostUsedApp();
    notifyListeners();
  }

  Future<void> updateAppAnalyzeStatus(bool isDone) async {
    _userInfo!.analyzeStatus['appUsageAnalyzeStatus'] = isDone;
    notifyListeners();
  }

  Future<void> updateYoutubeData(Map<String, dynamic> youtubeData) async {
    _userInfo!.youtubeTop3Category.clear();
    _userInfo!.youtubeTop3Category =
        List<String>.from(youtubeData['youtubeCategoryList']);
    _userInfo!.analyzeStatus['youtubeAnalyzeStatus'] = youtubeData['isChecked'];
    notifyListeners();
  }

  Future<void> updateUserMBTI(Map<String, dynamic> mbtiData) async {
    _userInfo!.mbti = mbtiData['mbti'];
    _userInfo!.mbtiPercent['energy'] = mbtiData['energy'];
    _userInfo!.mbtiPercent['recognition'] = mbtiData['recognition'];
    _userInfo!.mbtiPercent['decision'] = mbtiData['decision'];
    _userInfo!.mbtiPercent['lifeStyle'] = mbtiData['lifeStyle'];
    _userInfo!.analyzeStatus['chatAnalyzeStatus'] = mbtiData['isChecked'];
    notifyListeners();
  }

  Future<void> updateProfileImageUrl() async {
    String newProfileImageUrl = await _apiService.getProfileImage();
    _userInfo!.profileImageUrl = newProfileImageUrl;
    notifyListeners();
  }

  Future<void> updatePhotoData(Map<String, dynamic> json) async {
      _userInfo!.photoCategory.clear();
      _userInfo!.photoCategoryCounts.clear();
      _userInfo!.photoCategory = List<String>.from(json['sortedCategories']);
      _userInfo!.photoCategoryCounts = List<int>.from(json['categoryCounts']);
      _userInfo!.analyzeStatus['photoAnalyzeStatus'] = json['isChecked'];
      notifyListeners();
  }
}
