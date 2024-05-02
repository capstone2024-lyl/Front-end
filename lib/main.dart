import 'dart:io';

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
      home: ImageLablePage(),
    );
  }
}

class ImageLablePage extends StatefulWidget {
  const ImageLablePage({super.key});

  @override
  State<ImageLablePage> createState() => _ImageLablePageState();
}

class _ImageLablePageState extends State<ImageLablePage> {
  final ImagePicker _picker = ImagePicker();
  final ImageLabeler _imageLabeler = GoogleMlKit.vision.imageLabeler();
  List<ImageLabel> _labels = [];
  XFile? _imageFile;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final List<ImageLabel> labels =
          await _imageLabeler.processImage(inputImage);
      setState(() {
        _imageFile = image;
        _labels = labels;
      });
    }
  }

  @override
  void dispose() {
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Labeling Example'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Image'),
            ),
          ),
          if (_imageFile != null) Image.file(File(_imageFile!.path)),
          Expanded(
            child: ListView.builder(
              itemCount: _labels.length,
              itemBuilder: (context, index) {
                final ImageLabel label = _labels[index];
                return ListTile(
                  title: Text(label.label),
                  subtitle:
                      Text('${(label.confidence * 100).toStringAsFixed(2)}%'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
