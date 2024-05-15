import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:app_usage/app_usage.dart';

import 'package:flutter_svg/flutter_svg.dart';

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
          const SizedBox(
            height: 50,
          ),
          const Center(
            child: Text(
              '분석에 사용된 개인정보는 바로 폐기돼요 !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            '가장 많이 사용하는 앱 분석하기',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 380,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  blurRadius: 3.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0.0, 5.0),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    '최근 1주일동안 영재님께서\n가장 많이 사용한 어플 TOP3를 알려드려요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  height: 0.7,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 40.0),
                    child: Text(
                      '결과 예시',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Expanded(
                            flex:2,
                            child: Text(
                              '1위 : Instagram',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 1,
                            child: SvgPicture.asset(
                              'assets/icons/instagram_icon.svg',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '총 : 18시간',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(
                        height: 1,
                        endIndent: 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '2위 : Youtube',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SvgPicture.asset(
                              'assets/icons/youtube_original_icon.svg',
                              width: 30,
                              height: 20,
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '총 : 15시간',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Divider(
                        height: 1,
                        endIndent: 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '3위 : 카카오톡',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex:1,
                            child: SvgPicture.asset(
                              'assets/icons/kakao_icon.svg',
                              width: 30,
                              height: 30,
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              '총 : 10시간',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Divider(
                        height: 1,
                        endIndent: 50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
