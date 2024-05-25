import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';


class UserInfo {
  String name;
  DateTime birthday;
  String? mbti;
  List<Map<String, dynamic>> appList;
  List<String> nickname;
  List<Map<String, dynamic>> mostUsedApp = [];
  List<Map<String,dynamic>> mbtiPercent= [{'energy' : 0}];

  Map<String, bool> analyzeStatus;


  //TODO 사진 데이터
  UserInfo({
    required this.name,
    required this.birthday,
    required this.mbti,
    required this.appList,
    required this.nickname,
    required this.analyzeStatus,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'],
      birthday: _parseDate(json['birthday']),
      mbti: json['mbti']['mbti'],
      appList: (json['apps']['apps'] as List<dynamic>)
          .map((app) => {
                'appPackageName': app['appPackageName'].toString(),
                'usageTime': app['usageTime'] as int,
              }).toList(),
      nickname:
          json['nickname'] != null ? List<String>.from(json['nickname']) : [],
      analyzeStatus: {
        'chatAnalyzeStatus' : json['mbti']['isChecked'],
        'appUsageAnalyzeStatus' : json['apps']['isChecked'],
        'youtubeAnalyzeStatus' : json['category']['isChecked'],
        //TODO 사진 분석 결과 여부 추가
        'photoAnalyzeStatus' : false,

      }
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

  Future<void> initMostUsedApp() async {
    mostUsedApp.clear();
    if (appList.isNotEmpty) {
      for (var appPackageName in appList) {
        final appInfo = await _getAppInfo(appPackageName['appPackageName']);
        mostUsedApp.add({
          'appName' : appInfo.name,
          'usageTime' : appPackageName['usageTime'],
          'appIcon' : appInfo.icon,
        });
      }
    } else {
      return;
    }
  }

  Future<AppInfo> _getAppInfo(String packageName) async {
    AppInfo app = await InstalledApps.getAppInfo(packageName);
    return app;
  }

  double get numOfCompleteAnalyze {
    print(analyzeStatus);
    double cnt  = 0.0 ;
    if(analyzeStatus['chatAnalyzeStatus']!) {
      cnt+= 0.25;
    }
    if(analyzeStatus['appUsageAnalyzeStatus']!) {
      cnt+=0.25;
    }
    if(analyzeStatus['youtubeAnalyzeStatus']!) {
      cnt+=0.25;
    }
    if(analyzeStatus['photoAnalyzeStatus']!) {
      cnt+=0.25;
    }

    return cnt;
  }

}
