
import 'package:flutter/material.dart';

class ApplicationAnalyzeIntroPage extends StatefulWidget {
  const ApplicationAnalyzeIntroPage({super.key});

  @override
  State<ApplicationAnalyzeIntroPage> createState() => _ApplicationAnalyzeIntroPageState();
}

class _ApplicationAnalyzeIntroPageState extends State<ApplicationAnalyzeIntroPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('애플리케이션 사용시간 분석 페이지입니다.')),
    );
  }
}
