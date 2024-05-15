import 'package:flutter/cupertino.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:intl/intl.dart';

class UserInfo {
  String name;
  DateTime birthday;
  String? mbti;
  List<Map<String, dynamic>> appList;
  List<String> nickname;
  String? mostUsedApp;

  //TODO 사진 데이터
  UserInfo({
    required this.name,
    required this.birthday,
    required this.mbti,
    required this.appList,
    required this.nickname,
    required this.mostUsedApp,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'],
      birthday: _parseDate(json['birthday']),
      mbti: json['mbti'],
      appList: (json['apps'] as List<dynamic>)
          .map((app) => {
                'appPackageName': app['appPackageName'].toString(),
                'usageTime': app['usageTime'] as int,
              })
          .toList(),
      nickname:
          json['nickname'] != null ? List<String>.from(json['nickname']) : [],
      mostUsedApp: (json['apps'] as List<dynamic>)
          .map((app) => {
        'appPackageName': app['appPackageName'].toString(),
        'usageTime': app['usageTime'] as int,
      })
          .toList()[0]['appPackageName'].toString(),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is List) {
      // 배열 형식의 날짜 처리
      return DateTime(date[0], date[1], date[2]);
    } else if (date is String) {
      // 문자열 형식의 날짜 처리
      return DateTime.parse(date);
    } else {
      throw const FormatException('Invalid date format');
    }
  }

  Future<void> updateMostUsedApp() async {
    if (appList.isNotEmpty) {
      final appPackageName = appList[0]['appPackageName'].toString();
      mostUsedApp = await _getAppName(appPackageName);
    } else {
      mostUsedApp = null;
    }
  }

  Future<String> _getAppName(String packageName) async {
    AppInfo app = await InstalledApps.getAppInfo(packageName);
    return app.name;
  }
}
