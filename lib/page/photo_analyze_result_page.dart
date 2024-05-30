import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/util/app_color.dart';

class PhotoAnalyzeResultPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const PhotoAnalyzeResultPage({super.key, required this.onNavigateToProfile});

  @override
  State<PhotoAnalyzeResultPage> createState() => _PhotoAnalyzeResultPageState();
}

class _PhotoAnalyzeResultPageState extends State<PhotoAnalyzeResultPage> {
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
            return Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                const Center(
                  child: Text(
                    '사진 취향 분석 결과',
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
                    borderRadius: BorderRadius.circular(20),
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
                        '${userInfo!.name.substring(1)}님이 최근에 찍은 사진들을 통해\n사진 취향을 분석했어요 !',
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
