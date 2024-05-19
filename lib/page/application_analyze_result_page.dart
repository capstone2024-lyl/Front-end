import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/app_color.dart';

class ApplicationAnalyzeResultPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const ApplicationAnalyzeResultPage(
      {super.key, required this.onNavigateToProfile});

  @override
  State<ApplicationAnalyzeResultPage> createState() =>
      _ApplicationAnalyzeResultPageState();
}

class _ApplicationAnalyzeResultPageState
    extends State<ApplicationAnalyzeResultPage> {
  final ApiService _apiService = ApiService();
  late Future<void> _loadDataFuture;
  bool _isToggle = false;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await userInfoProvider.loadUserInfo();
    final appUsageData = await _apiService.getAppUsageTopTen();
    await userInfoProvider.upDataUserAppUsageData(appUsageData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Consumer<UserInfoProvider>(
              builder: (context, userInfoProvider, child) {
                final userInfo = userInfoProvider.userInfo;
                if (userInfo == null || userInfo.mostUsedApp.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 60,
                        ),
                        Center(
                          child: Text(
                            '최근 일주일 기준 ${userInfo.name.substring(1)}님께서 사용한 어플을 분석했어요'
                            '\n다음은 가장 많이 사용한 어플 TOP3에요!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _isToggle
                            ? Container(
                                width: 380,
                                height: 550,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.7),
                                      blurRadius: 3.0,
                                      spreadRadius: 0.0,
                                      offset: const Offset(0.0, 5.0),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Center(
                                      child: Text(
                                        '가장 많이 사용한 앱 분석 결과',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 350,
                                      height: 380,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            for (var i = 0;
                                                i < 10 &&
                                                    i <
                                                        userInfo
                                                            .mostUsedApp.length;
                                                i++)
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${i + 1}위: ${userInfo.mostUsedApp[i]['appName']}',
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      Image.memory(
                                                        userInfo.mostUsedApp[i]
                                                            ['appIcon'],
                                                        width: 40,
                                                        height: 40,
                                                      ),
                                                      Text(
                                                        '${userInfo.mostUsedApp[i]['usageTime'] ~/ 60}시간 ${userInfo.mostUsedApp[i]['usageTime'] % 60}분',
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(
                                                    height: 1,
                                                    indent: 20,
                                                    endIndent: 20,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _isToggle = !_isToggle;
                                            setState(() {});
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            backgroundColor:
                                                const Color(0xffD9D9D9),
                                          ),
                                          child: const Text('Top3만 보기')),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                width: 380,
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: <BoxShadow>[
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
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    const Center(
                                      child: Text(
                                        '가장 많이 사용한 앱 분석 결과',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: 350,
                                      child: Column(
                                        children: [
                                          for (var i = 0;
                                              i < 3 &&
                                                  i <
                                                      userInfo
                                                          .mostUsedApp.length;
                                              i++)
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${i + 1}위: ${userInfo.mostUsedApp[i]['appName']}',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    Image.memory(
                                                      userInfo.mostUsedApp[i]
                                                          ['appIcon'],
                                                      width: 40,
                                                      height: 40,
                                                    ),
                                                    Text(
                                                      '${userInfo.mostUsedApp[i]['usageTime'] ~/ 60}시간 ${userInfo.mostUsedApp[i]['usageTime'] % 60}분',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  height: 1,
                                                  indent: 20,
                                                  endIndent: 20,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    const Text(
                                      '더 자세한 정보를 알고 싶다면 아래 버튼을 눌러주세요!',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _isToggle = !_isToggle;
                                            setState(() {});
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            backgroundColor:
                                                const Color(0xffD9D9D9),
                                          ),
                                          child: const Text('TOP 10까지 더보기')),
                                    )
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
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onNavigateToProfile();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColor.buttonColor.colors,
                            ),
                            child: const Text(
                              '내 카드 확인하기',
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
