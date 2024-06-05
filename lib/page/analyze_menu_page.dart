import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';

import 'package:untitled1/models/user_info.dart';
import 'package:untitled1/page/application_analyze_intro_page.dart';
import 'package:untitled1/page/chat_analyze_intro_page.dart';
import 'package:untitled1/page/photo_analyze_intro_page.dart';
import 'package:untitled1/page/youtube_analyze_intro_page.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/util/app_color.dart';
import 'package:untitled1/util/youtube_category.dart';
import 'package:untitled1/util/progress_painter.dart';

class AnalyzeMenuPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const AnalyzeMenuPage({super.key, required this.onNavigateToProfile});

  @override
  State<AnalyzeMenuPage> createState() => _AnalyzeMenuPageState();
}

class _AnalyzeMenuPageState extends State<AnalyzeMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserInfoProvider>(
        builder: (context, userInfoProvider, child) {
          if (userInfoProvider.userInfo == null) {
            userInfoProvider.loadUserInfo();
            return Center(
                child: SpinKitWaveSpinner(
                    color: AppColor.buttonColor.colors, size: 100));
          } else {
            final userInfo = userInfoProvider.userInfo!;
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 50,
                  ),
                  _showTestProgress(userInfo),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '각 검사는 여러 번 할 수 있어요 !',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  const Text(
                    '나를 알아보는 4가지 분석',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const Divider(
                    indent: 30,
                    endIndent: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _baseCardWidget(_buildChatAnalyzeCard(userInfo)),
                            _baseCardWidget(_buildAppAnalyzeCard(userInfo)),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _baseCardWidget(_buildYoutubeAnalyzeCard(userInfo)),
                            _baseCardWidget(_buildPhotoAnalyzeCarD(userInfo)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _showTestProgress(UserInfo? userInfo) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Center(
          child: Container(
            width: 380,
            height: 160,
            decoration: BoxDecoration(
              color: AppColor.cardColor.colors,
              borderRadius: BorderRadius.circular(30),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  blurRadius: 3.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0.0, 5.0),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 40,
          child: CustomPaint(
            size: const Size(120.0, 120.0),
            painter: ProgressPainter(
              progress: 1,
              color: AppColor.progressWidgetBackground.colors,
              width: 10.0,
            ),
          ),
        ),
        Positioned(
          left: 40,
          child: CustomPaint(
            size: const Size(120.0, 120.0),
            painter: ProgressPainter(
              progress: userInfo!.numOfCompleteAnalyze,
              color: AppColor.buttonColor.colors,
              width: 10.0,
            ),
          ),
        ),
        Positioned(
          left: 72,
          top: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(userInfo.numOfCompleteAnalyze * 4).toInt()} / 4 단계',
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              const Text(
                "완료",
                style: TextStyle(
                  fontSize: 17,
                ),
              )
            ],
          ),
        ),
        Positioned(
          right: userInfo.numOfCompleteAnalyze * 4 == 4 ? 40 : 70,
          top: 30,
          child: Text(
            _stepIndicator(userInfo.numOfCompleteAnalyze, userInfo),
            style: const TextStyle(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          right: 50,
          bottom: 20,
          child: SizedBox(
            width: 180,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.onNavigateToProfile,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColor.buttonColor.colors,
              ),
              child: const Text(
                '내 카드 확인하기',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _testCompletionIndicator(bool isDone) {
    if (!isDone) {
      return Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColor.testProgressIndicatorBorder.colors,
              )),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColor.buttonColor.colors,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.check_sharp,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }
  }

  Widget _baseCardWidget(Widget childWidget) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
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
      child: childWidget,
    );
  }

  Widget _buildChatAnalyzeCard(UserInfo userInfo) {
    return Material(
      color: AppColor.cardColor.colors, // Material 색상 설정
      borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
      clipBehavior: Clip.antiAlias, // 클리핑 행동 설정
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatAnalyzeIntroPage(
                onNavigateToProfile: widget.onNavigateToProfile,
              ),
            ),
          );
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SvgPicture.asset(
                      'assets/icons/kakao_icon.svg',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                _testCompletionIndicator(
                    userInfo!.analyzeStatus['chatAnalyzeStatus']!),
              ],
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 5, 0, 0),
                child: Text(
                  '채팅내역 분석',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '현재 MBTI : ${userInfo.mbti ?? '???'}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppAnalyzeCard(UserInfo userInfo) {
    return Material(
      color: AppColor.cardColor.colors, // Material 색상 설정
      borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
      clipBehavior: Clip.antiAlias, // 클리핑 행동 설정
      child: InkWell(
        onTap: () {
          // 탭 이벤트 처리
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ApplicationAnalyzeIntroPage(
                        onNavigateToProfile: widget.onNavigateToProfile,
                      )));
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    '📱',
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
                _testCompletionIndicator(
                    userInfo.analyzeStatus['appUsageAnalyzeStatus']!),
              ],
            ),
            const Text(
              '가장 많이 사용한 어플 분석',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '1위: ${userInfo.mostUsedApp.isNotEmpty ? userInfo.mostUsedApp[0]['appName'] : '???'}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        '2위: ${userInfo.mostUsedApp.length >= 2 ? userInfo.mostUsedApp[1]['appName'] : '???'}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        '3위: ${userInfo.mostUsedApp.length >= 3 ? userInfo.mostUsedApp[2]['appName'] : '???'}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubeAnalyzeCard(UserInfo userInfo) {
    return Material(
      color: AppColor.cardColor.colors, // Material 색상 설정
      borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
      clipBehavior: Clip.antiAlias, // 클리핑 행동 설정
      child: InkWell(
        onTap: () {
          // 탭 이벤트 처리
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => YoutubeAnalyzeIntroPage(
                    onNavigateToProfile: widget.onNavigateToProfile)),
          );
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SvgPicture.asset(
                      'assets/icons/youtube_original_icon.svg',
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                _testCompletionIndicator(
                    userInfo.analyzeStatus['youtubeAnalyzeStatus']!),
              ],
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(6, 15, 0, 0),
                child: Text(
                  '좋아하는 영상 카테고리 분석',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '카테고리 : ${userInfo.youtubeTop3Category.isEmpty ? '???' : YoutubeCategory.youtubeCategoryTransfer(userInfo.youtubeTop3Category[0])}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAnalyzeCarD(UserInfo userInfo) {
    return Material(
      color: AppColor.cardColor.colors, // Material 색상 설정
      borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
      clipBehavior: Clip.antiAlias, // 클리핑 행동 설정
      child: InkWell(
        onTap: () {
          // 탭 이벤트 처리
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PhotoAnalyzeIntroPage(
                      onNavigateToProfile: widget.onNavigateToProfile,
                    )),
          );
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SvgPicture.asset(
                      'assets/icons/gallery_icon.svg',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                _testCompletionIndicator(
                    userInfo.analyzeStatus['photoAnalyzeStatus']!),
              ],
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
                child: Text(
                  '사진 취향 분석',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '사진 취향 : ${userInfo!.analyzeStatus['photoAnalyzeStatus']! ? userInfo!.photoCategory[0] : '???'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _stepIndicator(double progress, UserInfo userInfo) {
    int result = (progress * 4).toInt();
    switch (result) {
      case 0:
        return '${userInfo!.name.substring(1)}님의 카드 완성까지\n'
            '네 단계 남았습니다 !';
      case 1:
        return '${userInfo!.name.substring(1)}님의 카드 완성까지\n'
            '세 단계 남았습니다 !';
      case 2:
        return '${userInfo!.name.substring(1)}님의 카드 완성까지\n'
            '두 단계 남았습니다 !';
      case 3:
        return '${userInfo!.name.substring(1)}님의 카드 완성까지\n'
            '한 단계 남았습니다 !';
      default:
        return '${userInfo!.name.substring(1)}님의 카드가'
            ' 완성되었습니다!';
    }
  }
}
