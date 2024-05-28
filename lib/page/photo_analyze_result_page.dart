
import 'package:flutter/material.dart';

class PhotoAnalyzeResultPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;
  const PhotoAnalyzeResultPage({super.key, required this.onNavigateToProfile});

  @override
  State<PhotoAnalyzeResultPage> createState() => _PhotoAnalyzeResultPageState();
}

class _PhotoAnalyzeResultPageState extends State<PhotoAnalyzeResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: (){
          Navigator.of(context).pop();
          widget.onNavigateToProfile();
        },
        child: Text('버튼입니다.'),
      ),
    );
  }
}
