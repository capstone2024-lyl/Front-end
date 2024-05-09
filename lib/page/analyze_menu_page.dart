import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:untitled1/page/application_analyze_intro_page.dart';
import 'package:untitled1/page/chat_analyze_intro_page.dart';
import 'package:untitled1/page/photo_analyze_intro_page.dart';
import 'package:untitled1/page/youtube_analyze_intro_page.dart';

import 'package:untitled1/util/app_color.dart';
import 'package:untitled1/util/progress_painter.dart';

class AnalyzeMenuPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const AnalyzeMenuPage({super.key, required this.onNavigateToProfile});

  @override
  State<AnalyzeMenuPage> createState() => _AnalyzeMenuPageState();
}

class _AnalyzeMenuPageState extends State<AnalyzeMenuPage> {
  //TODO 검사 진행도 서버에서 받기
  double progress = 0.0; // 검사 진행도

  bool _isChatAnaylzed = false;
  bool _isApplicationAnalyzed = false;
  bool _isYoutubeAnalyzed = false;
  bool _isPhotoAnalyzed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          _showTestProgress(),
          const SizedBox(
            height: 150,
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
                    _baseCardWidget(_buildChatAnalyzeCard()),
                    _baseCardWidget(_buildAppAnalyzeCard()),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _baseCardWidget(_buildYoutubeAnalyzeCard()),
                    _baseCardWidget(_buildPhotoAnalyzeCarD()),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _showTestProgress() {
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
              progress: progress,
              color: AppColor.buttonColor.colors,
              width: 10.0,
            ),
          ),
        ),
        Positioned(
          left: 65,
          top: 65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${progress.toInt() * 4} / 4 단계',
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
          right: 55,
          top: 30,
          child: Text(
            //TODO 서버에서 user 정보 가져오기
            '영재님의 카드 완성까지 \n   네 단계 남았습니다!',
            style: TextStyle(
              fontSize: 18,
            ),
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

  Widget _buildChatAnalyzeCard() {
    return Material(
      color: AppColor.cardColor.colors, // Material 색상 설정
      borderRadius: BorderRadius.circular(20), // 둥근 모서리 설정
      clipBehavior: Clip.antiAlias, // 클리핑 행동 설정
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChatAnalyzeIntroPage()));
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
                _testCompletionIndicator(_isChatAnaylzed),
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
            //TODO 서버에서 mbti 검사 결과 가져오기
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  '현재 MBTI : ???',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppAnalyzeCard() {
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
                builder: (context) => const ApplicationAnalyzeIntroPage()),
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
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    '📱',
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
                _testCompletionIndicator(_isApplicationAnalyzed),
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
            //TODO 서버에서 결과 정보 받아오기
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 22.0),
                child: Column(
                  children: [
                    Text(
                      '1위: ???',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '2위: ???',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '3위: ???',
                      style: TextStyle(
                        fontSize: 14,
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

  Widget _buildYoutubeAnalyzeCard() {
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
                builder: (context) => const YoutubeAnalyzeIntroPage()),
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
                _testCompletionIndicator(_isYoutubeAnalyzed),
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
            //TODO 서버에서 유투브 분석 결과 가져오기
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  '카테고리 : ???',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAnalyzeCarD() {
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
                builder: (context) => const PhotoAnalyzeIntroPage()),
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
                _testCompletionIndicator(_isPhotoAnalyzed),
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
            //TODO 서버에서 사진 분석 검사 결과 가져오기
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  '사진 취향 : ???',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
