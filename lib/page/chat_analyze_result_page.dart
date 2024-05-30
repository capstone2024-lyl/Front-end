import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/page/my_profile_page.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/app_color.dart';

class ChatAnalyzeResultPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const ChatAnalyzeResultPage({super.key, required this.onNavigateToProfile});

  @override
  State<ChatAnalyzeResultPage> createState() => _ChatAnalyzeResultPageState();
}

class _ChatAnalyzeResultPageState extends State<ChatAnalyzeResultPage> {
  late Future<void> _loadDataFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await userInfoProvider.loadUserInfo();
    final mbtiData = await _apiService.findMBTI();
    await userInfoProvider.updateUserMBTI(mbtiData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitWaveSpinner(
                color: AppColor.buttonColor.colors,
                size: 200,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: SpinKitWaveSpinner(
                color: AppColor.buttonColor.colors,
                size: 200,
              ),
            );
          } else {
            return Consumer<UserInfoProvider>(
              builder: (context, userProviderInfo, child) {
                if (userProviderInfo.userInfo == null) {
                  userProviderInfo.loadUserInfo();
                  return Center(
                    child: SpinKitWaveSpinner(
                      color: AppColor.buttonColor.colors,
                      size: 200,
                    ),
                  );
                } else {
                  final userinfo = userProviderInfo.userInfo;
                  return Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 0),
                          child: Text(
                            '${userinfo!.name.substring(1)}님이 업로드한 채팅을 통해 \nMBTI를 분석했어요',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 380,
                        height: 580,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('MBTI 분석 결과',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            _buildIndicator(
                                "외향형 (E)",
                                "내향형 (I)",
                                userinfo!.mbtiPercent['energy']!,
                                AppColor.eiIndicatorColor.colors),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildIndicator(
                                "감각형 (S)",
                                "직관형 (N)",
                                userinfo!.mbtiPercent['recognition']!,
                                AppColor.snIndicatorColor.colors),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildIndicator(
                                "사고형 (T)",
                                "감정형 (F)",
                                userinfo!.mbtiPercent['decision']!,
                                AppColor.tfIndicatorColor.colors),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildIndicator(
                                "판단형 (J)",
                                "인식형 (P)",
                                userinfo!.mbtiPercent['lifeStyle']!,
                                AppColor.jpIndicatorColor.colors),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${userinfo!.name.substring(1)}님의 MBTI는 ${userinfo.mbti}입니다.',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Image.asset(
                              'assets/images/${userinfo.mbti.toLowerCase()}.jpg',
                              width: 290,
                              height: 290,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildIndicator(
      String leftLabel, String rightLabel, int percent, Color color) {
    double? width = 230;
    double? height = 30;
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              leftLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: (percent >= 50) ? FontWeight.bold : null,
              ),
            ),
          ),
          const SizedBox(
            width: 3,
          ),
          SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade300,
                  ),
                ),
                percent >= 50
                    ? Positioned(
                        left: 0,
                        child: Container(
                          width: width * percent / 100,
                          height: height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: color,
                          ),
                          child: Center(
                            child: Text(
                              '${percent.toStringAsFixed(0)}%',
                            ),
                          ),
                        ),
                      )
                    : Positioned(
                        right: 0,
                        child: Container(
                          width: width * (100 - percent) / 100,
                          height: height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: color,
                          ),
                          child: Center(
                            child: Text(
                              '${(100 - percent).toStringAsFixed(0)}%',
                            ),
                          ),
                        ),
                      ),
                percent < 50
                    ? Positioned(
                        left: 0,
                        child: SizedBox(
                          width: width * percent / 100,
                          height: height,
                          child: Center(
                            child: Text(
                              '${percent.toStringAsFixed(0)}%',
                            ),
                          ),
                        ),
                      )
                    : Positioned(
                        right: 0,
                        child: SizedBox(
                          width: width - width * percent / 100,
                          height: height,
                          child: Center(
                            child: Text(
                              '${(100 - percent).toStringAsFixed(0)}%',
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(
            width: 3,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              rightLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: (percent < 50) ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
