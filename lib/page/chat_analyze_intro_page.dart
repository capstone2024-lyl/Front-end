import 'package:flutter/material.dart';

class ChatAnalyzeIntroPage extends StatefulWidget {
  const ChatAnalyzeIntroPage({super.key});

  @override
  State<ChatAnalyzeIntroPage> createState() => _ChatAnalyzeIntroPageState();
}

class _ChatAnalyzeIntroPageState extends State<ChatAnalyzeIntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Text('채팅분석 소개 페이지입니다.'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('뒤로 가기'),
          )
        ],
      ),
    );
  }
}
