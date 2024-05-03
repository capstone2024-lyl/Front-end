import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

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