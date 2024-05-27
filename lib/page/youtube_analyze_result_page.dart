import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/nickname.dart';

import '../util/app_color.dart';

class YoutubeAnalyzeResultPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const YoutubeAnalyzeResultPage(
      {super.key, required this.onNavigateToProfile});

  @override
  State<YoutubeAnalyzeResultPage> createState() =>
      _YoutubeAnalyzeResultPageState();
}

class _YoutubeAnalyzeResultPageState extends State<YoutubeAnalyzeResultPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await userInfoProvider.loadUserInfo();

    final youtubeData = await _apiService.getYoutubeTop3Category();
    await userInfoProvider.updateYoutubeData(youtubeData);
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
                  color: AppColor.buttonColor.colors, size: 100),
            );
          } else {
            final userInfo = userInfoProvider.userInfo;
            return Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Center(
                  child: Text(
                    '좋아하는 유튜브 카테고리 분석 결과',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 380,
                  height: 550,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        blurRadius: 3.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0.0, 5.0),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Chat GPT로  ${userInfo!.name.substring(1)}님의 구독 목록을 토대로\n좋아하는 영상 카테고리를 분석했어요 !',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //TODO 각 카테고리 별 아이콘 띄우기
                      if (userInfo.youtubeTop3Category.isNotEmpty)
                        Text(
                          '1위 : ${Nickname.nicknameTransfer(userInfo.youtubeTop3Category[0])} 카테고리',
                          style: const TextStyle(
                            fontSize: 28,
                          ),

                        )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
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
      ),
    );
  }
}
