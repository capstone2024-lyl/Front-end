import 'package:flutter/material.dart';
import 'package:untitled1/page/home_page.dart';
import 'package:untitled1/util/app_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.backgroundColor.getColor(),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

