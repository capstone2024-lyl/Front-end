import 'dart:convert';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApplicationAnalyzeResultPage extends StatefulWidget {
  const ApplicationAnalyzeResultPage({super.key});

  @override
  State<ApplicationAnalyzeResultPage> createState() =>
      _ApplicationAnalyzeResultPageState();
}

class _ApplicationAnalyzeResultPageState
    extends State<ApplicationAnalyzeResultPage> {
  String _appUsageInfo = 'Loading...';
  static const platform = MethodChannel('com.example.untitled1');
  List<Map<String, String>> _installedApps= [];

  
  @override
  void initState() {
    super.initState();
    getUsageStats();
    getInstalledApps();
  }
  Future<void> getInstalledApps() async {
    try {
      final String result = await platform.invokeMethod('getInstalledApps');
      final List<dynamic> apps = jsonDecode(result);
      setState(() {
        _installedApps = apps.map((app) => {
          'appName': app['appName'] as String,
          'packageName': app['packageName'] as String
        }).toList();
      });
    } catch (e) {
      print("Failed to get installed apps: $e");
    }
  }


  void getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 7));
      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);

      String s = "";
      for (var info in infoList) {
        s +=
            '${info.packageName} : ${info.usage.inHours} hours, ${info.usage.inMinutes % 60} minutes\n';
      }

      setState(() {
        _appUsageInfo = s;
      });
    } catch (e) {
      print('Error fetching app usage: $e');
      setState(() {
        _appUsageInfo = 'Failed to get app usage info. Make sure';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _installedApps.length,
        itemBuilder: (context, index) {
          final app = _installedApps[index];
          return Card( // 추가된 Card 위젯으로 각 항목을 감싸줍니다
            child: ListTile(
              leading: Icon(Icons.android), // 리스트 타일에 아이콘 추가
              title: Text(app['appName'] ?? 'No name'),
              subtitle: Text(app['packageName'] ?? 'No package name'),
              onTap: () {
                // 아이템 클릭 이벤트 처리를 추가할 수 있습니다.
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Package Name"),
                      content: Text(app['packageName'] ?? 'No package name'),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
