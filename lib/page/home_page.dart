import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled1/util/app_color.dart';
import 'dart:core';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //TODO 각 page 컴포넌트화
  int currentPageIndex = 0;

  //TODO 사용자 정보를 API를 통해 받아오기 -> 프로필 요약에 정보 다 들어가야됨

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor.getColor(),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        backgroundColor: AppColor.backgroundColor.getColor(),
        indicatorColor: AppColor.buttonColor.getColor(),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            icon: Icon(
              Icons.home_outlined,
              color: Color(0xff979797),
            ),
            label: '홈',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Center(
                child: SizedBox(
                  child: Text(
                    '프로필 요약',
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              Center(
                child: Container(
                  width: 380,
                  height: 330,
                  decoration: BoxDecoration(
                    color: AppColor.cardColor.getColor(),
                    borderRadius: BorderRadius.circular(30.0),
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
                        height: 60,
                      ),
                      Text(
                        '이영재',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const Center(
                        child: Divider(
                          height: 10,
                          indent: 35,
                          endIndent: 35,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Text(
                                      '🎂 ',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      '생일 :',
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: <Widget>[
                                    const Text(
                                      '😁 ',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      'MBTI : ',
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: <Widget>[
                                    const Text(
                                      '📱 ',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '가장 많이 사용하는 어플 : ',
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/icons/youtube_original_icon.svg',
                                      width: 20,
                                      height: 18,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '좋아하는 영상 카테고리 : ',
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: <Widget>[
                                    const Text(
                                      '🖼️ ',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '사진 취향 : ',
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: <Widget>[
                                    const Text(
                                      '️🏆 ',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '칭호 : ',
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -390),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xffAEAEAE),
                    ),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ex2.jpg',
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
              ),
              //TODO ~단계 남았어요, 4 -여태 진행한 검사 개수 구현하기, 사용자 이름도 받아야함

              Transform.translate(
                offset: Offset(0, -70),
                child: Text(
                  '영재님만의 카드가 완성되기까지 \n앞으로 네 단계 남았어요 !',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Transform.translate(
                offset: Offset(0, -40),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffFFBB38),
                      foregroundColor: Color(0xffFFFFFF),
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 15.0)),
                  child: Text(
                    '나에 대해 분석하러 가기 !',
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.red,
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
