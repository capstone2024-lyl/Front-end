import 'dart:io';
import 'dart:core';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

import 'package:file_picker/file_picker.dart';

import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:image/image.dart' as img;

import 'package:untitled1/util/app_color.dart';

class PhotoAnalyzeIntroPage extends StatefulWidget {
  const PhotoAnalyzeIntroPage({super.key});

  @override
  State<PhotoAnalyzeIntroPage> createState() => _PhotoAnalyzeIntroPageState();
}

class _PhotoAnalyzeIntroPageState extends State<PhotoAnalyzeIntroPage> {
  List<File>? _images;
  late Future<void> _modelLoadFuture;
  bool _isModelLoaded = false;
  bool _isLoading = false;

  static const List<String> categories = [
    'nature',
    'person',
    'animal',
    'vehicle',
    'home_appliance',
    'food',
    'furniture',
    'daily'
  ];
  final Map<String, int> categoryCounts = {
    'name': 0,
    'person': 0,
    'animal': 0,
    'vehicle': 0,
    'home_appliance': 0,
    'food': 0,
    'furniture': 0,
    'daily': 0,
  };

  late Isolate _isolate;
  late ReceivePort _receivePort;
  late SendPort _sendPort;
  bool _isIsolateInitialized = false;

  @override
  void initState() {
    super.initState();
    _modelLoadFuture = loadModel();
    _initializeIsolate();
  }

  Future<void> loadModel() async {
    try {
      await _loadModelToFileSystem();
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

  Future<void> _loadModelToFileSystem() async {
    final byteData = await rootBundle.load('assets/model/model.tflite');
    final file = File('${(await getTemporaryDirectory()).path}/model.tflite');
    await file.writeAsBytes(byteData.buffer.asUint8List());
  }

  Future<void> _initializeIsolate() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
        _isolateEntry, [_receivePort.sendPort, RootIsolateToken.instance!]);

    _sendPort = await _receivePort.first as SendPort;
    _isIsolateInitialized = true;
  }

  static void _isolateEntry(List<dynamic> args) {
    final sendPort = args[0] as SendPort;
    final rootIsolateToken = args[1] as RootIsolateToken;
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    port.listen((message) async {
      final data = message[0];
      final image = data['image'] as String;
      final modelData = data['modelData'] as Uint8List;
      final replyTo = message[1] as SendPort;

      final result = await _analyzeImage(modelData, image);
      replyTo.send(result);
    });
  }

  static Future<String> _analyzeImage(
      Uint8List modelData, String imagePath) async {
    final interpreter = Interpreter.fromBuffer(modelData);
    return await _classifyImage(interpreter, imagePath);
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
    categoryCounts.updateAll((key, value) => 0);

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
      String? selectedDirectory = await FilePicker.platform
          .getDirectoryPath(initialDirectory: cameraDirectory.path);

      if (selectedDirectory != null) {
        setState(() {
          _isLoading = true;
        });
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
        final selectedImages = images.take(150).toList(); // 제한된 수의 이미지를 선택
        stopwatch.stop();
        print('폴더 선택 시간: ${stopwatch.elapsed}');

        setState(() {
          _images = selectedImages;
        });

        if (_isModelLoaded) {
          final stopwatch = Stopwatch()..start();
          print(selectedImages.length);
          final ByteData modelData =
              await services.rootBundle.load('assets/model/model.tflite');
          for (final image in selectedImages) {
            await _analyzeImageInBackground(image, modelData);
          }
          stopwatch.stop();
          print('이미지 분석 시간: ${stopwatch.elapsed}');
          setState(() {
            _isLoading = false;
          });
          print(categoryCounts);
        }
      } else {
        print('No folder selected.');
      }
    } else {
      print('Camera folder does not exist.');
    }
  }

  Future<void> _analyzeImageInBackground(File image, ByteData modelData) async {
    if (!_isIsolateInitialized) {
      await _initializeIsolate();
    }

    final responsePort = ReceivePort();
    final data = {
      'image': image.path,
      'modelData': modelData.buffer.asUint8List()
    };

    _sendPort.send([data, responsePort.sendPort]);

    final response = await responsePort.first;
    if (response is String) {
      setState(() {
        categoryCounts[response] = (categoryCounts[response] ?? 0) + 1;
      });
    }
  }

  static Future<String> _classifyImage(
      Interpreter interpreter, String imagePath) async {
    final File imageFile = File(imagePath);

    if (!imageFile.existsSync()) {
      print('Error: Could not decode image');
      return '';
    }

    final Stopwatch overallStopwatch = Stopwatch()..start();

    final Stopwatch propertiesStopwatch = Stopwatch()..start();

    final ImageProperties properties =
        await FlutterNativeImage.getImageProperties(imageFile.path);
    propertiesStopwatch.stop();
    print('Time to get image properties: ${propertiesStopwatch.elapsed}');

    final Stopwatch resizeStopwatch = Stopwatch()..start();
    final File resizedImage = await FlutterNativeImage.compressImage(
      imageFile.path,
      quality: 90,
      targetWidth: 224,
      targetHeight: properties.height! * 224 ~/ properties.width!,
    );

    resizeStopwatch.stop();
    print('Time to resize image: ${resizeStopwatch.elapsed}');

    final Stopwatch readBytesStopwatch = Stopwatch()..start();
    final Uint8List imageBytes = resizedImage.readAsBytesSync();
    readBytesStopwatch.stop();
    print('Time to read image bytes: ${readBytesStopwatch.elapsed}');

    final Stopwatch decodeStopwatch = Stopwatch()..start();
    final img.Image imageInput = img.decodeImage(imageBytes)!;
    final img.Image resizedImg =
        img.copyResize(imageInput, width: 224, height: 224);

    decodeStopwatch.stop();
    print('Time to decode and resize image: ${decodeStopwatch.elapsed}');

    final Stopwatch prepareInputStopwatch = Stopwatch()..start();
    final outputShape = interpreter.getOutputTensor(0).shape;
    final input = List.generate(
      1,
      (_) => List.generate(
          224, (_) => List.generate(224, (_) => List.filled(3, 0.0))),
    );
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resizedImg.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    prepareInputStopwatch.stop();
    print('Time to prepare input: ${prepareInputStopwatch.elapsed}');

    final Stopwatch inferenceStopwatch = Stopwatch()..start();
    final output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(outputShape);

    interpreter.run(input, output);

    inferenceStopwatch.stop();
    print('Time for inference: ${inferenceStopwatch.elapsed}');

    overallStopwatch.stop();
    print('Overall time: ${overallStopwatch.elapsed}');

    double maxProb = output[0].reduce((double a, double b) => a > b ? a : b);
    int maxIndex = output[0].indexOf(maxProb);

    return _PhotoAnalyzeIntroPageState.categories[maxIndex];
  }

  @override
  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _modelLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading model'));
          } else {
            return Center(
              child: _isLoading
                  ? SpinKitWaveSpinner(
                      color: AppColor.buttonColor.colors,
                      size: 200,
                      child: Center(
                        child: Text(
                          '분석 중',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColor.buttonColor.colors,
                          ),
                        ),
                      ),
                    )
                  : Text('파일을 선택해주세요.'),
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
