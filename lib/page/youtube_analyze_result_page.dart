import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';

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
    final result = await _apiService.getYoutubeTop3Category();
    print(result);
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
                      style: TextStyle(fontSize: 24),
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
