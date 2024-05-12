import 'package:flutter/material.dart';

import 'package:app_usage/app_usage.dart';

import 'package:http/http.dart' as http;

import 'package:html/parser.dart';

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
      print(tempData.length);
      for (var info in infoList) {
        String appName = await _appName(info.packageName);
        String appImage = await _appImage(info.packageName);
        tempData.add({
          'appName': appName,
          'usageTime': info.usage.inMinutes,
          'appImage': appImage
        });
      }
      print(tempData.length);
      setState(() {
        _appUsageData = tempData;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to get app usage info: $e');
    }
  }

  Future<String> _appName(String packageName) async {
    String url =
        "https://play.google.com/store/apps/details?id=$packageName&hl=ko";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var document = parse(response.body);
        var titleElement = document.querySelector('h1');
        return titleElement!.text;
      } else {
        throw Exception('Failed to load the webpage');
      }
    } catch (e) {
      return 'Unknown App'; // 웹 스크레이핑 실패 시 기본값
    }
  }

  Future<String> _appImage(String packageName) async {
    String url =
        "https://play.google.com/store/apps/details?id=$packageName&hl=ko";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var document = parse(response.body);
        var imageSource = document.querySelector(
            'body > c-wiz > div > div > div> div> div> div> div > c-wiz > div > div > img');
        return imageSource!.attributes['src'] ?? 'No Image Found';
      } else {
        return 'No Image Found';
      }
    } catch (e) {
      return '[error] : $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('애플리케이션 사용시간 분석 페이지입니다.')),
    );
  }
}
