import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ImageLabelPage extends StatefulWidget {
  const ImageLabelPage({super.key});

  @override
  State<ImageLabelPage> createState() => _ImageLabelPageState();
}

class _ImageLabelPageState extends State<ImageLabelPage> {
  File? _image;
  final picker = ImagePicker();
  String _result='';
  Interpreter? _interpreter;
  late Future<void> _modelLoadFuture;
  bool _isModelLoaded = false; // 모델 로드 상태 저장

  @override
  void initState() {
    super.initState();
    _modelLoadFuture = loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/model.tflite');
      setState(() {
        _isModelLoaded = true;
      });
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
      setState(() {
        _isModelLoaded = false;
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      if (_isModelLoaded) {
        classifyImage(File(pickedFile.path));
      } else {
        print('Model is not loaded yet');
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> classifyImage(File image) async {
    if (_interpreter == null) {
      print('Error: Interpreter is not initialized');
      return;
    }

    img.Image? imageInput = img.decodeImage(image.readAsBytesSync());
    if (imageInput == null) {
      print('Error: Could not decode image');
      return;
    }

    img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);

    // 입력 텐서 형태 확인
    var inputShape = _interpreter!.getInputTensor(0).shape;
    var outputShape = _interpreter!.getOutputTensor(0).shape;
    print('Input shape: $inputShape');
    print('Output shape: $outputShape');

    // 입력 데이터 준비 (입력 텐서를 4차원 배열로 준비)
    var input = List.generate(1, (_) => List.generate(224, (_) => List.generate(224, (_) => List.filled(3, 0.0))));
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);

    _interpreter!.run(input, output);

    setState(() {

      _result = output.toString();
    });

    print("Output: $output");
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Labeling"),
      ),
      body: FutureBuilder<void>(
        future: _modelLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading model'));
          } else {
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    _image == null ? Text('No image selected.') : Image.file(_image!),
                    Text(_result),
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isModelLoaded ? pickImage : null,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

extension ListReshape<T> on List<T> {
  List reshape(List<int> shape) {
    if (shape.length != 2) {
      throw Exception("Only 2D reshape is supported for now.");
    }
    var outer = shape[0];
    var inner = shape[1];
    if (length != outer * inner) {
      throw Exception("Invalid shape for reshape: $shape");
    }
    var reshaped = List.generate(outer, (index) => sublist(index * inner, (index + 1) * inner));
    return reshaped;
  }
}
