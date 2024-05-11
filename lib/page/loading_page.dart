import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {


  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFBB38),
              Color(0xFFFFE4AF),
              Colors.white,
            ]
          )
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 150,),
            Center(
              child: Container(
                child: Image.asset(
                  'assets/images/loading_img.png', width: 350, height: 450,),
              ),
            ),
            const Text('I-Card : 나를 알고, 소개하다',
              style: TextStyle(fontFamily: 'DoHyeon', fontSize: 28),)
          ],
        ),
      ),
    );
  }
}
