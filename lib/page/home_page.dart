import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:untitled1/providers/user_info_provider.dart';

import '../util/app_color.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToAnalysis;

  const HomePage({super.key, required this.onNavigateToAnalysis});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserInfoProvider>(context, listen: false).loadUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserInfoProvider>(
        builder: (context, userInfoProvider, child) {
          if (userInfoProvider.userInfo == null) {
            userInfoProvider.loadUserInfo();
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final userInfo = userInfoProvider.userInfo!;
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(
                    height: 60,
                  ),
                  const Center(
                    child: SizedBox(
                      child: Text(
                        '프로필 요약',
                        style: TextStyle(fontSize: 24),
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
                        color: AppColor.cardColor.colors,
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
                            userInfo.name,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const Center(
                            child: Divider(
                              height: 10,
                              indent: 35,
                              endIndent: 35,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
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
                                          '생일 : ${DateFormat('MM월dd일').format(userInfo.birthday)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                                          '😁 ',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          'MBTI : ${userInfo.mbti ?? '???'}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                                          '가장 많이 사용하는 어플 : ${userInfo.mostUsedApp ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                                        const Text(
                                          '좋아하는 영상 카테고리 : ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    const Row(
                                      children: <Widget>[
                                        Text(
                                          '🖼️ ',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          '사진 취향 : ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Row(
                                      children: <Widget>[
                                        Text(
                                          '️🏆 ',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          '칭호 : ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                  Transform.translate(
                    offset: const Offset(0, -70),
                    child: Text(
                      '${userInfo.name.substring(1, 3)}님만의 카드가 완성되기까지 \n앞으로 네 단계 남았어요 !',
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: SizedBox(
                      width: 380,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: widget.onNavigateToAnalysis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonColor.colors,
                          foregroundColor: const Color(0xffFFFFFF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50.0,
                            vertical: 15.0,
                          ),
                        ),
                        child: const Text(
                          '나에 대해 분석하러 가기 !',
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                      ),
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
}
