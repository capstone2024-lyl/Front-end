import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:app_usage/app_usage.dart';

import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class ApplicationAnalyzeIntroPage extends StatefulWidget {
  const ApplicationAnalyzeIntroPage({super.key});

  @override
  State<ApplicationAnalyzeIntroPage> createState() =>
      _ApplicationAnalyzeIntroPageState();
}

class _ApplicationAnalyzeIntroPageState
    extends State<ApplicationAnalyzeIntroPage> {
  //TODO 리스트 api연동해서 서버로 넘겨야됨

  List<Map<String, dynamic>> _appUsageData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUsageStats();
  }

  Future<void> getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 7));
      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);
      List<Map<String, dynamic>> tempData = [];
      for (var info in infoList) {
        AppInfo app = await InstalledApps.getAppInfo(info.packageName);
        String appName = app.name;
        Uint8List? iconSource = app.icon;
        tempData.add({
          'appName': appName,
          'usageTime': info.usage.inMinutes,
          'appIcon': iconSource,
        });
      }
      setState(() {
        _appUsageData = tempData;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to get app usage info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[

      ),
    );
  }
}
