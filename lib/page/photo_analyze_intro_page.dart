import 'package:flutter/material.dart';

class PhotoAnalyzeIntroPage extends StatefulWidget {
  const PhotoAnalyzeIntroPage({super.key});

  @override
  State<PhotoAnalyzeIntroPage> createState() => _PhotoAnalyzeIntroPageState();
}

class _PhotoAnalyzeIntroPageState extends State<PhotoAnalyzeIntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '사진 취향 분석 페이지입니다.',
        ),
      ),
    );
  }
}
