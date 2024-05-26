import 'dart:io';
import 'dart:core';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:untitled1/util/app_color.dart';

import 'package:flutter/services.dart' as services; // Add this line

class ImageLabelPage extends StatefulWidget {
  const ImageLabelPage({super.key});

  @override
  State<ImageLabelPage> createState() => _ImageLabelPageState();
}

class _ImageLabelPageState extends State<ImageLabelPage> {
  //자연 인물 동물 교통수단 가전제품 음식 가구 일상

  List<File>? _images;
  String _result = '';
  Interpreter? _interpreter;
  late Future<void> _modelLoadFuture;
  bool _isModelLoaded = false;
  bool _isLoading = false;

  static const List<String> categories = [
    '자연',
    '인물',
    '동물',
    '교통수단',
    '가전제품',
    '음식',
    '가구',
    '일상'
  ];
  final Map<String, int> categoryCounts = {
    '자연': 0,
    '인물': 0,
    '동물': 0,
    '교통수단': 0,
    '가전제품': 0,
    '음식': 0,
    '가구': 0,
    '일상': 0,
  };

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

  Future<void> _requestPermissionAndPickFile() async {
    var statusImage = await Permission.photos.status;
    var statusVideo = await Permission.videos.status;
    var statusAudio = await Permission.audio.status;
    if (!statusImage.isGranted) {
      statusImage = await Permission.photos.request();
    }

    if (!statusVideo.isGranted) {
      statusVideo = await Permission.videos.request();
    }

    if (!statusAudio.isGranted) {
      statusAudio = await Permission.audio.request();
    }

    if (statusImage.isGranted &&
        statusVideo.isGranted &&
        statusAudio.isGranted) {
      await pickFolder();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('권한 필요'),
            content: const Text('채팅 내역을 업로드하려면 저장소 접근 권한이 필요합니다.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> pickFolder() async {
    _images?.clear();
    _result = '';

    setState(() {
      _isLoading = true;
    });
    Directory? cameraDirectory;

    if (Platform.isAndroid) {
      cameraDirectory = Directory('/storage/emulated/0/DCIM/Camera');
    } else {
      final dcimDirectory = await getExternalStorageDirectory();
      if (dcimDirectory != null) {
        cameraDirectory = Directory('${dcimDirectory.path}/Camera');
      }
    }
    print(cameraDirectory);

    if (cameraDirectory != null && await cameraDirectory.exists()) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final directory = Directory(selectedDirectory);
        final List<FileSystemEntity> fileSystemEntities = directory.listSync();

        final stopwatch = Stopwatch()..start();

        // 시간 측정 종료
        // 최신 순으로 정렬한 후 상위 100개의 파일을 선택
        final List<File> images = fileSystemEntities
            .where((item) =>
                item is File &&
                (item.path.toLowerCase().endsWith('.jpg') ||
                    item.path.toLowerCase().endsWith('.jpeg') ||
                    item.path.toLowerCase().endsWith('.png')))
            .map((item) => item as File)
            .toList()
          ..sort(
              (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        print(images.length);

        //300장 추출
        final selectedImages = images.take(200).toList();
        stopwatch.stop();
        print('분석 시간: ${stopwatch.elapsed}');

        setState(() {
          _images = selectedImages;
        });

        if (_isModelLoaded) {
          print('모델 로드')
          // 시간 측정 시작
          final stopwatch = Stopwatch()..start();

          print(selectedImages.length);
          // 이미지 분석을 병렬로 실행
          for (final image in selectedImages) {
            final compressedFile = await FlutterNativeImage.compressImage(
              image.path,
              quality: 90,
              targetWidth: 224,
              targetHeight: 224,
            );

            if (compressedFile.existsSync()) {
              await _analyzeImageInBackground(compressedFile);
            }
          }


          // 시간 측정 종료
          stopwatch.stop();
          print('분석 시간: ${stopwatch.elapsed}');
          print(categoryCounts);
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('Model is not loaded yet');
      }
    } else {
      print('No folder selected.');
    }
  }

  Future<void> _analyzeImageInBackground(File image) async {
    final stopwatch = Stopwatch()..start();
    final receivePort = ReceivePort();
    final modelData =
    await rootBundle.load('assets/model/model.tflite'); // 모델 데이터를 로드
    await Isolate.spawn(_analyzeImage, [receivePort.sendPort, modelData, image.path]);

    final sendPort = await receivePort.first as SendPort;
    final response = ReceivePort();
    sendPort.send(response.sendPort);

    await for (final message in response) {
      if (message is String) {
        setState(() {
          categoryCounts[message] = (categoryCounts[message] ?? 0) + 1;
        });
      } else if (message is bool && message) {
        break;
      }
    }
    stopwatch.stop();
    print('분석 시간: ${stopwatch.elapsed}');

  }

  static Future<void> _analyzeImage(List<dynamic> params) async {
    final sendPort = params[0] as SendPort;
    final modelData = params[1] as ByteData;
    final imagePath = params[2] as String;
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    final Uint8List modelBytes = modelData.buffer.asUint8List();

    final interpreter = Interpreter.fromBuffer(modelBytes);
    final category = await _classifyImage(interpreter, imagePath);
    sendPort.send(category);

    sendPort.send(true); // 작업 완료 신호
  }

  static Future<String> _classifyImage(
      Interpreter interpreter, String imagePath) async {
    final File compressedFile = File(imagePath);

    if (!compressedFile.existsSync()) {
      print('Error: Could not decode image');
      return '';
    }

    final img.Image imageInput =
    img.decodeImage(compressedFile.readAsBytesSync())!;
    final img.Image resizedImage =
    img.copyResize(imageInput, width: 224, height: 224);

    final outputShape = interpreter.getOutputTensor(0).shape;
    final input = List.generate(
        1,
            (_) => List.generate(
            224, (_) => List.generate(224, (_) => List.filled(3, 0.0))));
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    final output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(outputShape);

    interpreter.run(input, output);

    double maxProb = output[0].reduce((double a, double b) => a > b ? a : b);
    int maxIndex = output[0].indexOf(maxProb);

    return _ImageLabelPageState.categories[maxIndex];
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading model'));
          } else {
            return _isLoading
                ? Center(
                    child: SpinKitWaveSpinner(
                    color: AppColor.buttonColor.colors,
                    size: 200,
                  ))
                : Center(
                    child: Text(_result),
                  );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isModelLoaded ? _requestPermissionAndPickFile : null,
        tooltip: 'Pick Folder',
        child: const Icon(Icons.folder),
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
    var reshaped = List.generate(
        outer, (index) => sublist(index * inner, (index + 1) * inner));
    return reshaped;
  }
}
