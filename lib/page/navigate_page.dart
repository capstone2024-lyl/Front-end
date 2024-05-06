import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled1/page/home_page.dart';
import 'package:untitled1/util/app_color.dart';
import 'dart:core';

class NavigatePage extends StatefulWidget {
  const NavigatePage({super.key});

  @override
  State<NavigatePage> createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage> {
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
            selectedIcon: Icon(
              Icons.bar_chart,
              color: Colors.white,
            ),
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            label: '분석하기',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            icon: Icon(Icons.account_circle_outlined),
            label: '내 프로필',
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
          const HomePage(),
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
          Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
