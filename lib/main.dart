import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
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
      //home: HomePage(),
      //TODO 이미지 분석 실현 가능성 테스트 페이지 구현, 추후 삭제 예정
      home: ImageAnalyzerPage(),
    );
  }
}

class ImageAnalyzerPage extends StatefulWidget {
  const ImageAnalyzerPage({super.key});

  @override
  State<ImageAnalyzerPage> createState() => _ImageAnalyzerPageState();
}

class _ImageAnalyzerPageState extends State<ImageAnalyzerPage> {
  final ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();
  List<String> _label = [];

  @override
  void dispose() {
    imageLabeler.close();
    super.dispose();
  }

  Future<void> pickAndAnalyzeImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withReadStream: true,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      int analyzeLimit = 100;
      analyzeImages(files.take(analyzeLimit).toList());
    } else {
      print('No files selected.');
    }
  }

  Future<void> analyzeImages(List<File> images) async {
    List<String> labels = [];

    for (File image in images) {
      final inputImage = InputImage.fromFile(image);
      final List<ImageLabel> imageLabels =
          await imageLabeler.processImage(inputImage);

      for (ImageLabel label in imageLabels) {
        labels.add('${label.label} (${label.confidence.toStringAsFixed(2)})');
      }
    }

    setState(() {
      _label = labels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: pickAndAnalyzeImages,
            child: Text('SelectImage'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _label.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_label[index]),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
