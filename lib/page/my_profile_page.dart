import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

import 'package:screenshot/screenshot.dart';

import 'package:social_share/social_share.dart';

import 'package:untitled1/models/user_info.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/util/app_color.dart';
import 'package:untitled1/util/youtube_category.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  //TODO 검사 안했을 때 상세정보 관리하기

  int _touchedIndex = -1;

  Color _cardColor = AppColor.profileCardYellow.colors;
  bool _isColorSelectPage = false;
  bool _hideButton = false;

  final ScreenshotController _screenshotController = ScreenshotController();
  final _instaId = '1535325187166738';
  bool _isSharing = false;

  bool _isBack = false;
  double _angle = 0;

  Future<void> _captureAndShareScreenshot() async {
    setState(() {
      _isSharing = true;
    });

    final directory = (await getApplicationDocumentsDirectory()).path;
    String fileName = 'screenshot.png';
    String filePath = '$directory/$fileName';

    _screenshotController
        .captureAndSave(directory, fileName: fileName)
        .then((path) {
      _shareToInstagramStory(path!);
    }).catchError((onError) {
      print(onError);
    }).whenComplete(() {
      setState(() {
        _isSharing = false;
      });
    });
  }

  Future<void> _shareToInstagramStory(String imagePath) async {
    try {
      SocialShare.shareInstagramStory(
        appId: _instaId,
        imagePath: imagePath,
        backgroundTopColor: "#ffffff",
        backgroundBottomColor: "#000000",
      );
    } catch (e) {
      print('error sharing to Instagram Story : $e');
    }
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
                size: 100,
              ),
            );
          } else {
            final userInfo = userInfoProvider.userInfo;
            return Screenshot(
              controller: _screenshotController,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const Center(
                      child: SizedBox(
                        height: 40,
                      ),
                    ),
                    if (!_isSharing)
                      const Text(
                        '내 카드',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    _isColorSelectPage
                        ? _buildColorEditPage()
                        : TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: _angle),
                            duration: const Duration(milliseconds: 500),
                            builder: (BuildContext con, double val, _) {
                              _isBack = (val >= (pi / 2)) ? true : false;
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(val),
                                child: _isBack
                                    ? Stack(
                                        children: [
                                          Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.identity()
                                              ..scale(-1.0, 1.0, 1.0),
                                            child: Container(
                                              width: 380,
                                              height: 650,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: _cardColor,
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    if (userInfo!.analyzeStatus[
                                                        'chatAnalyzeStatus']!)
                                                      Column(
                                                        children: [
                                                          _buildMbtiResult(
                                                              userInfo!),
                                                          const Divider(
                                                            indent: 10,
                                                            endIndent: 10,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    if (userInfo!.analyzeStatus[
                                                        'appUsageAnalyzeStatus']!)
                                                      Column(
                                                        children: [
                                                          _buildAppUsageResult(
                                                              userInfo!),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const Divider(
                                                            indent: 10,
                                                            endIndent: 10,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    if (userInfo!.analyzeStatus[
                                                        'youtubeAnalyzeStatus']!)
                                                      _buildYoutubeResult(
                                                          userInfo),
                                                    if (userInfo.analyzeStatus[
                                                        'photoAnalyzeStatus']!)
                                                      Column(
                                                        children: [
                                                          Text(
                                                            '${userInfo.name.substring(1)}님의 사진 분석 결과',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 40,
                                                          ),
                                                          _buildPhotoResult(
                                                              userInfo),
                                                          const SizedBox(
                                                            height: 60,
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _angle =
                                                      (_angle + pi) % (2 * pi);
                                                });

                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 480), () {
                                                  setState(() {
                                                    _hideButton = !_hideButton;
                                                  });
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.flip_camera_android,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          if (userInfo.numOfCompleteAnalyze *
                                                  4 ==
                                              0)
                                            Positioned.fill(
                                              child: Transform(
                                                alignment: Alignment.center,
                                                transform: Matrix4.identity()
                                                  ..scale(-1.0, 1.0, 1.0),
                                                child: Center(
                                                  child: Text(
                                                    '아직 완료된 검사가 없어요 !\n\n\n'
                                                    '검사를 진행해서 ${userInfo.name.substring(1)}님만의 카드를 \n완성해보세요 !',
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      )
                                    : Container(
                                        width: 380,
                                        height: 500,
                                        decoration: BoxDecoration(
                                          color: _cardColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(100),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          border: Border.all(
                                            color: _cardColor,
                                          ),
                                          boxShadow: _isSharing
                                              ? null
                                              : <BoxShadow>[
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.7),
                                                    blurRadius: 3.0,
                                                    spreadRadius: 0.0,
                                                    offset:
                                                        const Offset(0.0, 5.0),
                                                  ),
                                                ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(100),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Positioned(
                                                top: -250,
                                                left: -140,
                                                child: Transform.rotate(
                                                  angle: pi / 6,
                                                  child: Container(
                                                    width: 400,
                                                    height: 400,
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(20),
                                                        topLeft:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(
                                                                170),
                                                        bottomLeft:
                                                            Radius.circular(20),
                                                      ),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 50,
                                                left: 60,
                                                child: Text(
                                                  userInfo!.mbti == ''
                                                      ? '???'
                                                      : userInfo!.mbti,
                                                  style: TextStyle(
                                                    color: _cardColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 40,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 110,
                                                left: 20,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(200),
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xffAEAEAE),
                                                        ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: ClipOval(
                                                        child: Image.network(
                                                          userInfo
                                                              .profileImageUrl,
                                                          height: 120,
                                                          width: 120,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      userInfo!.name,
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${DateFormat('MM월 dd일').format(userInfo!.birthday)} 🎂',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 40,
                                                right: 20,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    const Row(
                                                      children: [
                                                        Text(
                                                          '📱',
                                                          style: TextStyle(
                                                            fontSize: 22,
                                                          ),
                                                        ),
                                                        Text(
                                                          '가장 많이 사용하는 어플',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    _buildDivider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: [
                                                        _buildListMark(),
                                                        Text(
                                                          '${userInfo.mostUsedApp.isEmpty ? '???' : userInfo.mostUsedApp[0]['appName']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        SvgPicture.asset(
                                                          'assets/icons/youtube_original_icon.svg',
                                                          width: 15,
                                                          height: 15,
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8.0),
                                                          child: Text(
                                                            '좋아하는 동영상 카테고리',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    _buildDivider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: [
                                                        _buildListMark(),
                                                        Text(
                                                          userInfo.youtubeTop3Category
                                                                  .isEmpty
                                                              ? '???'
                                                              : YoutubeCategory
                                                                  .youtubeCategoryTransfer(
                                                                      userInfo
                                                                          .youtubeTop3Category[0]),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    const Row(
                                                      children: [
                                                        Text(
                                                          '🖼️',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8.0),
                                                          child: Text(
                                                            '사진 취향',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    _buildDivider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        _buildListMark(),
                                                        Text(
                                                          userInfo.photoCategory
                                                                  .isEmpty
                                                              ? '???'
                                                              : userInfo
                                                                  .photoCategory[0],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    const Row(
                                                      children: [
                                                        Text(
                                                          '🏆',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        Text(
                                                          '칭호',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    _buildDivider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    userInfo.nickname.isEmpty
                                                        ? Row(
                                                            children: [
                                                              _buildListMark(),
                                                              const Text(
                                                                '???',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ],
                                                          )
                                                        : SizedBox(
                                                            height: 100,
                                                            child:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: userInfo
                                                                    .nickname
                                                                    .asMap()
                                                                    .map((index,
                                                                        nickname) {
                                                                      return MapEntry(
                                                                        index,
                                                                        Text(
                                                                          index < userInfo.nickname.length - 1
                                                                              ? '• $nickname'
                                                                              : '• $nickname',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                        ),
                                                                      );
                                                                    })
                                                                    .values
                                                                    .toList(),
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: IconButton(
                                                  onPressed: () {
                                                    _isColorSelectPage =
                                                        !_isColorSelectPage;
                                                    setState(() {});
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 10,
                                                left: 10,
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _angle = (_angle + pi) %
                                                          (2 * pi);
                                                      _hideButton =
                                                          !_hideButton;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons
                                                        .flip_camera_android_outlined,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                              );
                            },
                          ),
                    if (!_hideButton && !_isSharing)
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Container(
                          width: 380,
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.black26)),
                          child: ElevatedButton(
                            onPressed: _captureAndShareScreenshot,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/instagram_icon.svg',
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Text(
                                  '인스타그램 공유하기',
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDivider() {
    return const SizedBox(
      width: 180,
      height: 10,
      child: Divider(
        thickness: 1,
        color: Colors.white,
      ),
    );
  }

  Widget _buildListMark() {
    return const Text(
      '• ',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    );
  }

  Widget _buildColorEditPage() {
    return Container(
      width: 380,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(100),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.white,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            blurRadius: 3.0,
            spreadRadius: 0.0,
            offset: const Offset(0.0, 5.0),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              const SizedBox(
                height: 60,
              ),
              const Center(
                child: Text(
                  '카드 배경색 설정',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                indent: 60,
                endIndent: 60,
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _cardColor == AppColor.profileCardPurple.colors
                            ? _buildCurrentColorIndicator(
                                AppColor.profileCardPurple.colors)
                            : _buildColorSelectorWidget(
                                AppColor.profileCardPurple.colors),
                        _cardColor == AppColor.profileCardBlack.colors
                            ? _buildCurrentColorIndicator(
                                AppColor.profileCardBlack.colors)
                            : _buildColorSelectorWidget(
                                AppColor.profileCardBlack.colors),
                        _cardColor == AppColor.profileCardYellow.colors
                            ? _buildCurrentColorIndicator(
                                AppColor.profileCardYellow.colors)
                            : _buildColorSelectorWidget(
                                AppColor.profileCardYellow.colors),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _cardColor == AppColor.profileCardBlue.colors
                            ? _buildCurrentColorIndicator(
                                AppColor.profileCardBlue.colors)
                            : _buildColorSelectorWidget(
                                AppColor.profileCardBlue.colors),
                        _cardColor == AppColor.profileCardRed.colors
                            ? _buildCurrentColorIndicator(
                                AppColor.profileCardRed.colors)
                            : _buildColorSelectorWidget(
                                AppColor.profileCardRed.colors),
                        _cardColor == AppColor.profileCardGreen.colors
                            ? _buildCurrentColorIndicator(
                                AppColor.profileCardGreen.colors)
                            : _buildColorSelectorWidget(
                                AppColor.profileCardGreen.colors),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () {
                _isColorSelectPage = !_isColorSelectPage;
                setState(() {});
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentColorIndicator(Color widgetColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widgetColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipOval(
          child: Container(
            width: 50,
            height: 50,
            color: widgetColor,
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelectorWidget(Color widgetColor) {
    return InkWell(
      onTap: () {
        _cardColor = widgetColor;
        setState(() {
          _isColorSelectPage = !_isColorSelectPage;
        });
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipOval(
            child: Container(
              width: 50,
              height: 50,
              color: widgetColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMbtiResult(UserInfo userInfo) {
    return Column(
      children: [
        Text(
          '${userInfo!.name.substring(1)}님의 MBTI는 ${userInfo.mbti}입니다.',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/${userInfo.mbti.toLowerCase()}.jpg',
              width: 250,
              height: 280,
              fit: BoxFit.cover,
            )),
        Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            _buildIndicator(
                "외향형 (E)",
                "내향형 (I)",
                userInfo.mbtiPercent['energy']!,
                AppColor.eiIndicatorColor.colors),
            const SizedBox(
              height: 10,
            ),
            _buildIndicator(
                "감각형 (S)",
                "직관형 (N)",
                userInfo.mbtiPercent['recognition']!,
                AppColor.snIndicatorColor.colors),
            const SizedBox(
              height: 10,
            ),
            _buildIndicator(
                "사고형 (T)",
                "감정형 (F)",
                userInfo.mbtiPercent['decision']!,
                AppColor.tfIndicatorColor.colors),
            const SizedBox(
              height: 10,
            ),
            _buildIndicator(
                "판단형 (J)",
                "인식형 (P)",
                userInfo.mbtiPercent['lifeStyle']!,
                AppColor.jpIndicatorColor.colors),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppUsageResult(UserInfo userInfo) {
    return Column(
      children: [
        Text(
          '${userInfo!.name.substring(1)}님이 자주 사용하는 어플',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        for (var i = 0; i < 3 && i < userInfo.mostUsedApp.length; i++)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${i + 1}위: ${userInfo.mostUsedApp[i]['appName']}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.memory(
                      userInfo.mostUsedApp[i]['appIcon'],
                      width: 40,
                      height: 40,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${userInfo.mostUsedApp[i]['usageTime'] ~/ 60}시간 ${userInfo.mostUsedApp[i]['usageTime'] % 60}분',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
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
                color: Colors.white,
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
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYoutubeResult(UserInfo userInfo) {
    return Column(
      children: [
        Center(
          child: Text(
            '${userInfo!.name.substring(1)}님이 좋아하는 영상 카테고리 분석 결과',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          children: [
            SizedBox(
              width: 280,
              height: 250,
              child: Stack(
                children: [
                  Positioned(
                    top: 70,
                    right: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'TOP 3',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColor.buttonColor.colors,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.7),
                                      blurRadius: 3.0,
                                      spreadRadius: 0.0,
                                      offset: const Offset(0.0, 5.0),
                                    ),
                                  ],
                                  color: Colors.white),
                            ),
                            userInfo.youtubeTop3Category.length < 3
                                ? Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Image.asset(
                                      'assets/icons/question_mark.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                  )
                                : Positioned(
                                    top: 10,
                                    left: 10,
                                    child: SvgPicture.asset(
                                      'assets/icons/${userInfo.youtubeTop3Category[2].toLowerCase()}_icon.svg',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          userInfo.youtubeTop3Category.length < 3
                              ? '???'
                              : YoutubeCategory.youtubeCategoryTransfer(
                                  userInfo.youtubeTop3Category[2]),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 70,
                    left: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'TOP 2',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.buttonColor.colors,
                                ),
                                borderRadius: BorderRadius.circular(50),
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
                            userInfo.youtubeTop3Category.length < 2
                                ? Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Image.asset(
                                      'assets/icons/question_mark.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                  )
                                : Positioned(
                                    top: 10,
                                    left: 10,
                                    child: SvgPicture.asset(
                                      'assets/icons/${userInfo.youtubeTop3Category[1].toLowerCase()}_icon.svg',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          userInfo.youtubeTop3Category.length < 2
                              ? '???'
                              : YoutubeCategory.youtubeCategoryTransfer(
                                  userInfo.youtubeTop3Category[0]),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    left: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'TOP 1',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Image.asset(
                          'assets/icons/crown_icon.png',
                          width: 40,
                          height: 40,
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColor.buttonColor.colors,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.7),
                                      blurRadius: 3.0,
                                      spreadRadius: 0.0,
                                      offset: const Offset(0.0, 5.0),
                                    ),
                                  ],
                                  color: Colors.white),
                            ),
                            userInfo.youtubeTop3Category.isEmpty
                                ? Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Image.asset(
                                      'assets/icons/question_mark.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                  )
                                : Positioned(
                                    top: 10,
                                    left: 10,
                                    child: SvgPicture.asset(
                                      'assets/icons/${userInfo.youtubeTop3Category[0].toLowerCase()}_icon.svg',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          userInfo.youtubeTop3Category.isEmpty
                              ? '???'
                              : YoutubeCategory.youtubeCategoryTransfer(
                                  userInfo.youtubeTop3Category[0]),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoResult(UserInfo userInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 200,
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              }),
              sections: _showingSections(
                  userInfo.photoCategory, userInfo.photoCategoryCounts),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 0,
            ),
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 60,
            ),
            for (int i = 0; i < userInfo.photoCategory.length; i++)
              _charIndicator(
                  color: _getChartColor(i), title: userInfo.photoCategory[i])
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections(
      List<String> category, List<int> categoryCount) {
    return List.generate(category.length, (i) {
      final isTouched = (i == _touchedIndex);
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 110 : 100;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      final color = _getChartColor(i);
      final widgetSize = isTouched ? 55.0 : 40.0;
      return PieChartSectionData(
        color: color,
        value: categoryCount[i].toDouble(),
        title: '${categoryCount[i]}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
        badgeWidget: _buildBadge(
          imgAsset: 'assets/icons/${_translateCategory(category[i])}.png',
          size: widgetSize,
          borderColor: Colors.black,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }

  Color _getChartColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF2196F3);
      case 1:
        return const Color(0xFFFF683B);
      case 2:
        return const Color(0xFF3BFF49);
      case 3:
        return const Color(0xFFE80054);
      case 4:
        return const Color(0xFF6E1BFF);
      case 5:
        return const Color(0xffFF90E7);
      case 6:
        return const Color(0xFFFF3AF2);
      case 7:
        return const Color(0xFFFFC300);
      default:
        return Colors.black;
    }
  }

  Widget _charIndicator({
    required Color color,
    required String title,
  }) {
    double size = 16;
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ],
    );
  }

  Widget _buildBadge({
    required String imgAsset,
    required double size,
    required Color borderColor,
  }) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Image.asset(
        imgAsset,
      ),
    );
  }

  String _translateCategory(String original) {
    switch (original) {
      case '인물':
        return 'person';
      case '음식':
        return 'food';
      case '동물':
        return 'animal';
      case '가구':
        return 'furniture';
      case '교통수단':
        return 'transport';
      case '가전제품':
        return 'homeappliance';
      case '자연':
        return 'nature';
      default:
        return 'daily';
    }
  }
}
