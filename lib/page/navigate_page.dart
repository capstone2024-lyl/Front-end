import 'dart:core';

import 'package:flutter/material.dart';

import 'package:untitled1/page/analyze_menu_page.dart';
import 'package:untitled1/page/home_page.dart';
import 'package:untitled1/page/my_profile_page.dart';
import 'package:untitled1/page/setting_page.dart';
import 'package:untitled1/util/app_color.dart';

class NavigatePage extends StatefulWidget {
  const NavigatePage({super.key});

  @override
  State<NavigatePage> createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage> {
  //TODO 각 page 컴포넌트화
  int _currentPageIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void navigateToAnalysis() {
    setState(() {
      _currentPageIndex = 1;
    });
  }

  void navigateToProfile() {
    setState(() {
      _currentPageIndex = 2;
    });
  }

  //TODO 사용자 정보를 API를 통해 받아오기 -> 프로필 요약에 정보 다 들어가야됨

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        final currentNavigatorState = _navigatorKey.currentState;
        if(currentNavigatorState!.canPop()) {
          currentNavigatorState!.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentPageIndex,
          children: <Widget>[
            HomePage(onNavigateToAnalysis: navigateToAnalysis),
            Navigator(
              key: _navigatorKey,
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                    builder: (context) =>
                        AnalyzeMenuPage(onNavigateToProfile: navigateToProfile));
              },
            ),
            MyProfilePage(),
            SettingPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          backgroundColor: AppColor.backgroundColor.colors,
          indicatorColor: AppColor.buttonColor.colors,
          selectedIndex: _currentPageIndex,
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
              selectedIcon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              icon: Icon(Icons.settings_outlined),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}
