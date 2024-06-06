import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import 'package:app_usage/app_usage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';

import 'package:untitled1/page/application_analyze_result_page.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/app_color.dart';

class ApplicationAnalyzeIntroPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const ApplicationAnalyzeIntroPage(
      {super.key, required this.onNavigateToProfile});

  @override
  State<ApplicationAnalyzeIntroPage> createState() =>
      _ApplicationAnalyzeIntroPageState();
}

class _ApplicationAnalyzeIntroPageState
    extends State<ApplicationAnalyzeIntroPage> {
  final ApiService _apiService = ApiService();

  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const platform = MethodChannel('com.example.untitled1/usage_access');

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_updatePage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updatePage() {
    setState(() {
      _currentPage = _pageController.page!.round();
    });
  }

  Future<bool> _checkUsageAccessPermission() async {
    try {
      final bool result = await platform.invokeMethod('checkUsageAccess');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get usage access permission: '${e.message}'.");
      return false;
    }
  }

  Future<bool> _getUsageStats() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 7));
    List<AppUsageInfo> infoList =
        await AppUsage().getAppUsage(startDate, endDate);
    bool isUsageAccessPermission = await _checkUsageAccessPermission();

    if (isUsageAccessPermission) {
      print(infoList);
      List<Map<String, Object>> appList = [];
      for (var info in infoList) {
        if (info.usage.inMinutes == 0) {
          continue;
        }
        appList.add({
          'appPackageName': info.packageName,
          'usageTime': info.usage.inMinutes,
        });
      }
      appList.sort((a, b) {
        int usageTimeA = a['usageTime'] as int;
        int usageTimeB = b['usageTime'] as int;
        return usageTimeB.compareTo(usageTimeA);
      });

      await _apiService.sendAppUsageData(appList);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _openUsageAccessSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserInfoProvider>(
        builder: (context, userInfoProvider, child) {
          if (userInfoProvider.userInfo == null) {
            userInfoProvider.loadUserInfo();
            return Center(
              child: SpinKitWaveSpinner(
                color: AppColor.buttonColor.colors,
                size: 200,
              ),
            );
          } else {
            final userInfo = userInfoProvider.userInfo;
            return SingleChildScrollView(
              child: Column(
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
                    height: 500,
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
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            '최근 1주일동안 ${userInfo!.name.substring(1)}님께서\n가장 많이 사용한 어플 TOP3를 알려드려요!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                          height: 10,
                        ),
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: PageView(
                            controller: _pageController,
                            children: [
                              Image.asset('assets/images/app_analyze1.jpg'),
                              Image.asset('assets/images/app_analyze2.jpg'),
                              _buildAppAnalyzeResultExample(),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIndicator(0),
                            const SizedBox(
                              width: 5,
                            ),
                            _buildIndicator(1),
                            const SizedBox(
                              width: 5,
                            ),
                            _buildIndicator(2),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (_currentPage <= 1)
                          Text(
                            'Step ${_currentPage + 1}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        _buildStepText(_currentPage),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: 380,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (await _checkUsageAccessPermission()) {
                          await _getUsageStats();
                          if (mounted) {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) =>
                                  ApplicationAnalyzeResultPage(
                                onNavigateToProfile: widget.onNavigateToProfile,
                              ),
                            ));
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('알림'),
                              backgroundColor: AppColor.cardColor.colors,
                              content: const Text(
                                  '어플 사용시간을 분석하려면 사용정보 접근을 허용해야 합니다.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _openUsageAccessSettings();
                                  },
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColor.buttonColor.colors,
                      ),
                      child: const Text(
                        '어플 사용시간 분석하기',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _currentPage == index
            ? const Color(0xff6F6F6F)
            : const Color(0xffD9D9D9),
      ),
    );
  }

  Widget _buildAppAnalyzeResultExample() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 20,
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
                    flex: 2,
                    child: Text(
                      '1위 : Instagram',
                      style: TextStyle(
                        fontSize: 18,
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
                        fontSize: 18,
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
                        fontSize: 18,
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
                        fontSize: 18,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
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
                        fontSize: 18,
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
    );
  }

  Widget _buildStepText(int index) {
    String text;
    switch (index) {
      case 0:
        text = '어플 사용시간 분석하기 버튼 최초 클릭 시 사용정보 접근 허용 페이지가 열립니다.';
      case 1:
        text = '어플들 중에서 아이카드를 찾고 접근 권한을 허용해주세요!';
      default:
        text = '';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
