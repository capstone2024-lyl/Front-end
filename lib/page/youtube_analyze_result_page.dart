import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/youtube_category.dart';

import '../util/app_color.dart';

class YoutubeAnalyzeResultPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const YoutubeAnalyzeResultPage(
      {super.key, required this.onNavigateToProfile});

  @override
  State<YoutubeAnalyzeResultPage> createState() =>
      _YoutubeAnalyzeResultPageState();
}

class _YoutubeAnalyzeResultPageState extends State<YoutubeAnalyzeResultPage> {
  final ApiService _apiService = ApiService();
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await userInfoProvider.loadUserInfo();

    final youtubeData = await _apiService.getYoutubeTop3Category();
    await userInfoProvider.updateYoutubeData(youtubeData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitWaveSpinner(
                color: AppColor.buttonColor.colors,
                size: 100,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
                child: SpinKitWaveSpinner(
              color: AppColor.buttonColor.colors,
              size: 100,
            ));
          } else {
            return Consumer<UserInfoProvider>(
              builder: (context, userInfoProvider, child) {
                if (userInfoProvider.userInfo == null) {
                  userInfoProvider.loadUserInfo();
                  return Center(
                    child: SpinKitWaveSpinner(
                        color: AppColor.buttonColor.colors, size: 100),
                  );
                } else {
                  final userInfo = userInfoProvider.userInfo;
                  print(userInfo?.youtubeTop3Category);
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        const Center(
                          child: Text(
                            '좋아하는 유튜브 카테고리 분석 결과',
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
                            borderRadius: BorderRadius.circular(30),
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
                                '${userInfo!.name.substring(1)}님의 유튜브 구독 목록을 토대로\n좋아하는 영상 카테고리를 분석했어요 !',
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
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: 280,
                                height: 300,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 70,
                                      right: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'TOP 3',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Stack(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: AppColor
                                                          .buttonColor.colors,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(50),
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.7),
                                                        blurRadius: 3.0,
                                                        spreadRadius: 0.0,
                                                        offset: const Offset(
                                                            0.0, 5.0),
                                                      ),
                                                    ],
                                                    color: Colors.white),
                                              ),
                                              userInfo.youtubeTop3Category
                                                          .length <
                                                      3
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
                                            userInfo.youtubeTop3Category.length <
                                                    3
                                                ? '???'
                                                : YoutubeCategory
                                                    .youtubeCategoryTransfer(userInfo
                                                        .youtubeTop3Category[2]),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 70,
                                      left: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'TOP 2',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Stack(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: AppColor
                                                          .buttonColor.colors,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(50),
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.7),
                                                        blurRadius: 3.0,
                                                        spreadRadius: 0.0,
                                                        offset: const Offset(
                                                            0.0, 5.0),
                                                      ),
                                                    ],
                                                    color: Colors.white),
                                              ),
                                              userInfo.youtubeTop3Category
                                                          .length <
                                                      2
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
                                            userInfo.youtubeTop3Category.length <
                                                    2
                                                ? '???'
                                                : YoutubeCategory
                                                    .youtubeCategoryTransfer(userInfo
                                                        .youtubeTop3Category[0]),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      left: 90,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'TOP 1',
                                            style: TextStyle(
                                              fontSize: 20,
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
                                                      color: AppColor
                                                          .buttonColor.colors,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(50),
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.7),
                                                        blurRadius: 3.0,
                                                        spreadRadius: 0.0,
                                                        offset: const Offset(
                                                            0.0, 5.0),
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
                                                : YoutubeCategory
                                                    .youtubeCategoryTransfer(userInfo
                                                        .youtubeTop3Category[0]),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '${userInfo.name.substring(1)}님께서 가장 좋아하는 영상 카테고리는 \n${userInfo.youtubeTop3Category.isEmpty ? '???' : YoutubeCategory.youtubeCategoryTransfer(userInfo.youtubeTop3Category[0])}입니다 !',
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              )
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
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
