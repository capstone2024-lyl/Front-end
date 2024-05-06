import 'dart:math';

import 'package:flutter/material.dart';

class ProgressPainter extends CustomPainter {
  final double progress; //진행률
  final Color color; //원의 색상
  final double width; //원의 너비

  ProgressPainter({
    required this.progress,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    //원 그리기
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2),
        -pi / 2, //시작 각도
        2 * pi * progress, //진행률에 따른 원의 길이
        false, //원의 선을 그릴지 여부
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
