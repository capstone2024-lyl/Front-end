import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/util/app_color.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  //TODO user 정보 API 연동해서 사용자 정보 받아오기
  final String _mbti = 'ESTJ';
  final String _favoriteVideo = '게임 Shorts';
  final String _favoritePhotoStyle = '자연 풍경';

  Color _cardColor = AppColor.profileCardYellow.colors;
  bool _isColorSelectPage = false;
  bool _hideButton = false;

  //TODO 칭호 리스트로 받기
  final String _achievement = '나는 자연인이다.';

  bool _isBack = false;
  double _angle = 0;

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
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 40,
                  ),
                  const Center(
                    child: Text(
                      '내 카드',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
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
                                                  Text(
                                                    '${userInfo!.name.substring(1)}님의 MBTI는 $_mbti입니다.',
                                                    style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  )
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
                                        )
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
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.7),
                                            blurRadius: 3.0,
                                            spreadRadius: 0.0,
                                            offset: const Offset(0.0, 5.0),
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
                                                          Radius.circular(170),
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
                                                userInfo!.mbti ?? _mbti,
                                                style: TextStyle(
                                                  color: _cardColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 40,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 90,
                                              left: 20,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              200),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: const Color(
                                                            0xffAEAEAE),
                                                      ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/images/ex2.jpg',
                                                        height: 120,
                                                        width: 120,
                                                      ),
                                                    ),
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
                                              right: 20,
                                              bottom: 30,
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
                                                  Row(
                                                    children: [
                                                      _buildListMark(),
                                                      Text(
                                                        '${userInfo.mostUsedApp[0]['appName']}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
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
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  _buildDivider(),
                                                  Row(
                                                    children: [
                                                      _buildListMark(),
                                                      Text(
                                                        _favoriteVideo,
                                                        style: const TextStyle(
                                                          fontSize: 15,
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
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  _buildDivider(),
                                                  Row(
                                                    children: <Widget>[
                                                      _buildListMark(),
                                                      Text(
                                                        _favoritePhotoStyle,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    ],
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
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  _buildDivider(),
                                                  Row(
                                                    children: <Widget>[
                                                      _buildListMark(),
                                                      Text(
                                                        _achievement,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            //TODO 카드 색 정하는 로직 구현
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
                                            //TODO 카드 뒤집는 로직 추가
                                            Positioned(
                                              bottom: 10,
                                              left: 10,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _angle = (_angle + pi) %
                                                        (2 * pi);
                                                    _hideButton = !_hideButton;
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
                  if (!_hideButton)
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Container(
                        width: 380,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black26)),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
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
}
