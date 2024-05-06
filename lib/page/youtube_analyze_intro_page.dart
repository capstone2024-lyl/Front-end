import 'package:flutter/material.dart';

class YoutubeAnalyzeIntroPage extends StatefulWidget {
  const YoutubeAnalyzeIntroPage({super.key});

  @override
  State<YoutubeAnalyzeIntroPage> createState() =>
      _YoutubeAnalyzeIntroPageState();
}

class _YoutubeAnalyzeIntroPageState extends State<YoutubeAnalyzeIntroPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '좋아하는 영상 분석 페이지입니다.',
        ),
      ),
    );
  }
}
