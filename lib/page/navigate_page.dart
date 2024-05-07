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
  late final List<Widget> _pages;

  final List<GlobalKey<NavigatorState>> _navigatorKeys =[
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onNavigateToAnalysis: navigateToAnalysis),
      AnalyzeMenuPage(
        onNavigateToProfile: navigateToProfile,
      ),
      MyProfilePage(),
      SettingPage(),
    ];
  }

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
    return  Scaffold(
      body: IndexedStack(
        index: _currentPageIndex,
        children: <Widget>[
          _buildOffstageNavigator(0),
          _buildOffstageNavigator(1),
          _buildOffstageNavigator(2),
          _buildOffstageNavigator(3),
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
    );

    // return Scaffold(
    //   backgroundColor: AppColor.backgroundColor.colors,
    //   bottomNavigationBar: NavigationBar(
    //     onDestinationSelected: (int index) {
    //       setState(() {
    //         _currentPageIndex = index;
    //       });
    //     },
    //     backgroundColor: AppColor.backgroundColor.colors,
    //     indicatorColor: AppColor.buttonColor.colors,
    //     selectedIndex: _currentPageIndex,
    //     destinations: const <Widget>[
    //       NavigationDestination(
    //         selectedIcon: Icon(
    //           Icons.home,
    //           color: Colors.white,
    //         ),
    //         icon: Icon(
    //           Icons.home_outlined,
    //           color: Color(0xff979797),
    //         ),
    //         label: '홈',
    //       ),
    //       NavigationDestination(
    //         selectedIcon: Icon(
    //           Icons.bar_chart,
    //           color: Colors.white,
    //         ),
    //         icon: Icon(
    //           Icons.bar_chart_outlined,
    //         ),
    //         label: '분석하기',
    //       ),
    //       NavigationDestination(
    //         selectedIcon: Icon(
    //           Icons.account_circle,
    //           color: Colors.white,
    //         ),
    //         icon: Icon(Icons.account_circle_outlined),
    //         label: '내 프로필',
    //       ),
    //       NavigationDestination(
    //         selectedIcon: Icon(
    //           Icons.settings,
    //           color: Colors.white,
    //         ),
    //         icon: Icon(Icons.settings_outlined),
    //         label: '설정',
    //       ),
    //     ],
    //   ),
    //   body: IndexedStack(
    //     index: _currentPageIndex,
    //     children: _pages,
    //   ),
    //);
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentPageIndex != index,
        child: Navigator(
          key: _navigatorKeys[index],
          onGenerateRoute: (routeSetting) {
            return MaterialPageRoute(builder: (context) => _getPage(index),);
          },
        ),
    );
  }

  Widget _getPage(int index) {
    switch(index) {
      case 0:
        return HomePage(onNavigateToAnalysis: navigateToAnalysis);
      case 1:
        return AnalyzeMenuPage(onNavigateToProfile: navigateToProfile);
      case 2:
        return MyProfilePage();
      case 3:
        return SettingPage();
      default:
        return HomePage(onNavigateToAnalysis: navigateToAnalysis);
    }
  }
}
