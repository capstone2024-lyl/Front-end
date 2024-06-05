import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/app_color.dart';

class PhotoAnalyzeResultPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const PhotoAnalyzeResultPage({super.key, required this.onNavigateToProfile});

  @override
  State<PhotoAnalyzeResultPage> createState() => _PhotoAnalyzeResultPageState();
}

class _PhotoAnalyzeResultPageState extends State<PhotoAnalyzeResultPage> {
  late Future<void> _loadDataFuture;
  final ApiService _apiService = ApiService();

  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await userInfoProvider.loadUserInfo();
    final photoData = await _apiService.getPhotoResult();
    await userInfoProvider.updatePhotoData(photoData);
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
                size: 200,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: SpinKitWaveSpinner(
                color: AppColor.buttonColor.colors,
                size: 200,
              ),
            );
          } else {
            return Consumer<UserInfoProvider>(
              builder: (context, userInfoProvider, child) {
                if (userInfoProvider.userInfo == null) {
                  userInfoProvider.loadUserInfo();
                  return Center(
                    child: SpinKitWaveSpinner(
                      color: AppColor.buttonColor.colors,
                      size: 200,
                    ),
                  );
                } else {
                  final userInfo = userInfoProvider.userInfo;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 60,
                        ),
                        const Center(
                          child: Text(
                            '사진 취향 분석 결과',
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
                            borderRadius: BorderRadius.circular(20),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                '${userInfo!.name.substring(1)}님이 최근에 찍은 사진들을 통해\n사진 취향을 분석했어요 !',
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
                                height: 40,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: PieChart(
                                      PieChartData(
                                        pieTouchData: PieTouchData(touchCallback:
                                            (FlTouchEvent event,
                                                pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse.touchedSection ==
                                                    null) {
                                              _touchedIndex = -1;
                                              return;
                                            }
                                            _touchedIndex = pieTouchResponse
                                                .touchedSection!
                                                .touchedSectionIndex;
                                          });
                                        }),
                                        sections: _showingSections(
                                            userInfo.photoCategory,
                                            userInfo.photoCategoryCounts),
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
                                      for (int i = 0;
                                          i < userInfo.photoCategory.length;
                                          i++)
                                        _charIndicator(
                                            color: _getChartColor(i),
                                            title: userInfo.photoCategory[i])
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 80,
                              ),
                              Text(
                                '${userInfo.name.substring(1)}님의 사진 취향은 ${userInfo.photoCategory[0]} 사진입니다 !',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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