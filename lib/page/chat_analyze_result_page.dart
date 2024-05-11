import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:untitled1/util/app_color.dart';

class ChatAnalyzeResultPage extends StatefulWidget {
  const ChatAnalyzeResultPage({super.key});

  @override
  State<ChatAnalyzeResultPage> createState() => _ChatAnalyzeResultPageState();
}

class _ChatAnalyzeResultPageState extends State<ChatAnalyzeResultPage> {
  //TODO 각 MBTI 성향 별 수치 API 연동하기
  double ei = 64;
  double sn = 27;
  double tf = 82;
  double jp = 55;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 40,
          ),
          const Center(
            child: Text('MBTI 분석 결과',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: 380,
            height: 450,
            decoration: BoxDecoration(
              color: Colors.white,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                  child: Text(
                    '영재님이 업로드한 채팅을 통해 \nMBTI를 분석했어요',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                _buildIndicator(
                    "외향형 (E)", "내향형 (I)", ei, AppColor.eiIndicatorColor.colors),
                const SizedBox(
                  height: 10,
                ),
                _buildIndicator(
                    "감각형 (S)", "직관형 (N)", sn, AppColor.snIndicatorColor.colors),
                const SizedBox(
                  height: 10,
                ),
                _buildIndicator(
                    "사고형 (T)", "감정형 (F)", tf, AppColor.tfIndicatorColor.colors),
                const SizedBox(
                  height: 10,
                ),
                _buildIndicator(
                    "판단형 (J)", "인식형 (P)", jp, AppColor.jpIndicatorColor.colors),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(
      String leftLabel, String rightLabel, double percent, Color color) {
    double? width = 230;
    double? height = 30;
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              leftLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: (percent >=50) ? FontWeight.bold : null ,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
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
                      ),
                percent < 50
                    ? Positioned(
                        left: 0,
                        child: SizedBox(
                          width: width - width * percent / 100,
                          height: height,
                          child: Center(
                            child: Text(
                              '${(100 - percent).toStringAsFixed(0)}%',
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
            width: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              rightLabel,
              style:  TextStyle(
                fontSize: 16,
                fontWeight: (percent < 50) ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
