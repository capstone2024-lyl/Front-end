import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ImageLabelPage extends StatefulWidget {
  const ImageLabelPage({super.key});

  @override
  State<ImageLabelPage> createState() => _ImageLabelPageState();
}

class _ImageLabelPageState extends State<ImageLabelPage> {
  List<File>? _images;
  String _result = '';
  Interpreter? _interpreter;
  late Future<void> _modelLoadFuture;
  bool _isModelLoaded = false;

  final List<String> categories = [
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
  final Map<String, int> categoryCountsMlKit = {
    '자연': 0,
    '인물': 0,
    '동물': 0,
    '교통수단': 0,
    '가전제품': 0,
    '음식': 0,
    '가구': 0,
    '일상': 0,
  };

  final Map<String, String> mlKitToCustomCategory = {
    'landscape': '자연',
    'person': '인물',
    'animal': '동물',
    'vehicle': '교통수단',
    'appliance': '가전제품',
    'food': '음식',
    'furniture': '가구',
    'everyday': '일상'
    // Add more mappings as needed
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
            content: const Text('갤러리를 분석하려면 저장소 접근 권한이 필요합니다.'),
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

    Directory? cameraDirectory;

    if (Platform.isAndroid) {
      cameraDirectory = Directory('/storage/emulated/0/DCIM/Camera');
    } else {
      final dcimDirectory = await getExternalStorageDirectory();
      if (dcimDirectory != null) {
        cameraDirectory = Directory('${dcimDirectory.path}/Camera');
      }
    }

    if (cameraDirectory != null && await cameraDirectory.exists()) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final directory = Directory(selectedDirectory);
        final List<FileSystemEntity> fileSystemEntities = directory.listSync();

        final stopwatch = Stopwatch()..start();

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

        final selectedImages = images.take(100).toList();
        stopwatch.stop();
        print('폴더 선택 시간: ${stopwatch.elapsed}');

        setState(() {
          _images = selectedImages;
        });

        if (_isModelLoaded) {
          final stopwatch = Stopwatch()..start();
          print(selectedImages.length);
          await Future.wait(selectedImages.map((image) => classifyImage(image)));
          stopwatch.stop();
          print('이미지 분석 시간: ${stopwatch.elapsed}');
          print(categoryCounts);
        }
      } else {
        print('No folder selected.');
      }
    } else {
      print('Camera folder does not exist.');
    }
  }

  Future<void> classifyImage(File image) async {
    final totalStopwatch = Stopwatch()..start();

    if (_interpreter == null) {
      print('Error: Interpreter is not initialized');
      return;
    }

    File compressedFile = await FlutterNativeImage.compressImage(
      image.path,
      quality: 90,
      targetWidth: 224,
      targetHeight: 224,
    );

    if (!compressedFile.existsSync()) {
      print('Error: Could not decode image');
      return;
    }

    final imageBytes = await compressedFile.readAsBytes();

    final img.Image? imageInput = img.decodeImage(imageBytes);
    if (imageInput == null) {
      print('Error: Could not decode image');
      return;
    }
    final img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);

    final outputShape = _interpreter!.getOutputTensor(0).shape;
    var input = List.generate(
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

    var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(outputShape);

    _interpreter!.run(input, output);

    double maxProb = output[0].reduce((double a, double b) => a > b ? a : b);
    int maxIndex = output[0].indexOf(maxProb);
    String category = categories[maxIndex];

    setState(() {
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    });

    await classifyWithMLKit(image.path);

    totalStopwatch.stop();
    print('Total analysis time: ${totalStopwatch.elapsed}');

    await compressedFile.delete();
  }

  Future<void> classifyWithMLKit(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
    final ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler(options);

    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    for (final label in labels) {
      final String? customCategory = mlKitToCustomCategory[label.label];
      if (customCategory != null) {
        setState(() {
          categoryCountsMlKit[customCategory] = (categoryCountsMlKit[customCategory] ?? 0) + 1;
        });
      }
    }

    imageLabeler.close();
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
            return const SingleChildScrollView(
              child: Center(
                child: Text('하이'),
              ),
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
