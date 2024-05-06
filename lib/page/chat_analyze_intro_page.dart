
import 'package:flutter/material.dart';

class ChatAnalyzeIntroPage extends StatefulWidget {
  const ChatAnalyzeIntroPage({super.key});

  @override
  State<ChatAnalyzeIntroPage> createState() => _ChatAnalyzeIntroPageState();
}

class _ChatAnalyzeIntroPageState extends State<ChatAnalyzeIntroPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('채팅분석 소개 페이지입니다.'),
      ),
    );
  }
}
