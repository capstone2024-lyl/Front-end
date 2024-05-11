import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatAnalyzeResultPage extends StatefulWidget {
  const ChatAnalyzeResultPage({super.key});

  @override
  State<ChatAnalyzeResultPage> createState() => _ChatAnalyzeResultPageState();
}

class _ChatAnalyzeResultPageState extends State<ChatAnalyzeResultPage> {
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
            child: const Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                  child: Text('영재님이 업로드한 채팅을 통해 MBTI를 분석했어요', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
