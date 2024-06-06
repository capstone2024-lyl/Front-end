import 'dart:io';
import 'dart:core';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:image/image.dart' as img;
import 'package:untitled1/page/photo_analyze_result_page.dart';

import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/app_color.dart';

class PhotoAnalyzeIntroPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const PhotoAnalyzeIntroPage({super.key, required this.onNavigateToProfile});

  @override
  State<PhotoAnalyzeIntroPage> createState() => _PhotoAnalyzeIntroPageState();
}

class _PhotoAnalyzeIntroPageState extends State<PhotoAnalyzeIntroPage> {
  final ApiService _apiService = ApiService();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<File>? _images;
  late Future<void> _modelLoadFuture;
  bool _isModelLoaded = false;
  bool _isLoading = false;
  List<FileSystemEntity> _files = [];

  static const List<String> categories = [
    'nature',
    'person',
    'animal',
    'vehicle',
    'homeAppliance',
    'food',
    'furniture',
    'daily'
  ];
  final Map<String, int> categoryCounts = {
    'nature': 0,
    'person': 0,
    'animal': 0,
    'vehicle': 0,
    'homeAppliance': 0,
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
    _pageController.addListener(_updatePage);
  }

  void _updatePage() {
    setState(() {
      _currentPage = _pageController.page!.round();
    });
  }

  Future<void> loadModel() async {
    try {
      await _loadModelToFileSystem();
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
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

    if (!statusImage.isGranted) {
      statusImage = await Permission.photos.request();
    }

    if (statusImage.isGranted) {
      _showFileDialog();
      //await pickFolder();
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

  Future<List<File>> _getImages(String directoryPath) async {
    final directory = Directory(directoryPath);
    final List<File> images = [];

    await for (var entity in directory.list()) {
      if (entity is File &&
          (entity.path.toLowerCase().endsWith('.jpg') ||
              entity.path.toLowerCase().endsWith('.jpeg') ||
              entity.path.toLowerCase().endsWith('.png'))) {
        images.add(entity);
      }
    }

    images.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return images;
  }

  Future<void> _pickFolder(String selectedFilePath) async {
    _images?.clear();
    categoryCounts.updateAll((key, value) => 0);

    String? selectedDirectory = selectedFilePath;

    if (selectedDirectory != null) {
      setState(() {
        _isLoading = true;
      });

      // 비동기 작업 수행
      final List<File> images = await _getImages(selectedFilePath);
      final selectedImages = images.take(100).toList(); // 제한된 수의 이미지를 선택

      setState(() {
        _images = selectedImages;
      });

      if (_isModelLoaded) {
        final stopwatch = Stopwatch()..start();
        final ByteData modelData =
            await services.rootBundle.load('assets/model/model.tflite');
        for (final image in selectedImages) {
          await _analyzeImageInBackground(image, modelData);
        }
        stopwatch.stop();

        bool response = await _apiService.savePhotoResult(categoryCounts);
        if (response && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => PhotoAnalyzeResultPage(
                    onNavigateToProfile: widget.onNavigateToProfile)),
          );
        }
      }
    } else {
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
      return '';
    }

    final Stopwatch overallStopwatch = Stopwatch()..start();

    final Stopwatch propertiesStopwatch = Stopwatch()..start();

    final ImageProperties properties =
        await FlutterNativeImage.getImageProperties(imageFile.path);
    propertiesStopwatch.stop();

    final Stopwatch resizeStopwatch = Stopwatch()..start();
    final File resizedImage = await FlutterNativeImage.compressImage(
      imageFile.path,
      quality: 90,
      targetWidth: 224,
      targetHeight: properties.height! * 224 ~/ properties.width!,
    );

    resizeStopwatch.stop();

    final Stopwatch readBytesStopwatch = Stopwatch()..start();
    final Uint8List imageBytes = resizedImage.readAsBytesSync();
    readBytesStopwatch.stop();

    final Stopwatch decodeStopwatch = Stopwatch()..start();
    final img.Image imageInput = img.decodeImage(imageBytes)!;
    final img.Image resizedImg =
        img.copyResize(imageInput, width: 224, height: 224);

    decodeStopwatch.stop();

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

    final Stopwatch inferenceStopwatch = Stopwatch()..start();
    final output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(outputShape);

    interpreter.run(input, output);

    inferenceStopwatch.stop();

    overallStopwatch.stop();

    double maxProb = output[0].reduce((double a, double b) => a > b ? a : b);
    int maxIndex = output[0].indexOf(maxProb);

    return _PhotoAnalyzeIntroPageState.categories[maxIndex];
  }

  Future<void> _showFileDialog() async {
    // Request storage permission
    final directory = Directory('/storage/emulated/0/DCIM');
    List<FileSystemEntity> files = directory.listSync();
    setState(() {
      _files = files;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사진을 분석할 파일을 선택하세요'),
          backgroundColor: AppColor.cardColor.colors,
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _files.length,
              itemBuilder: (BuildContext context, int index) {
                FileSystemEntity file = _files[index];
                return ListTile(
                  title: Text(file.path.split('/').last),
                  onTap: () {
                    Navigator.of(context).pop(file.path);
                  },
                );
              },
            ),
          ),
        );
      },
    ).then((selectedFilePath) async {
      if (selectedFilePath != null) {
        await _pickFolder(selectedFilePath);
      }
    });
  }

  @override
  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _pageController.removeListener(_updatePage);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _modelLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitWaveSpinner(
                color: AppColor.buttonColor.colors,
                size: 200,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading model'));
          } else {
            return Consumer<UserInfoProvider>(
              builder: (context, userInfoProvider, child) {
                if (userInfoProvider.userInfo == null) {
                  userInfoProvider.loadUserInfo();
                  return Center(
                    child: SpinKitWaveSpinner(
                      color: AppColor.buttonColor.colors,
                      size: 200,
                    ),
                  );
                } else {
                  final userInfo = userInfoProvider.userInfo;
                  return _isLoading
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SpinKitWaveSpinner(
                                  color: AppColor.buttonColor.colors,
                                  size: 200,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  '분석 중...',
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            const Center(
                              child: Text(
                                '분석에 사용된 개인정보는 바로 폐기돼요 !',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: 380,
                              height: 550,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.7),
                                    blurRadius: 3.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0.0, 5.0),
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0),
                                      child: Text(
                                        '${userInfo!.name.substring(1)}님의 갤러리 폴더 속 사진들을 통해 최근 사진 취향을 분석해요',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                  ),
                                  SizedBox(
                                    width: 350,
                                    height: 300,
                                    child: PageView(
                                      controller: _pageController,
                                      children: [
                                        Image.asset(
                                          'assets/images/photo1.png',
                                          fit: BoxFit.cover,
                                        ),
                                        Image.asset(
                                          'assets/images/photo2.png',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildIndicator(0),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      _buildIndicator(1),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Step ${_currentPage + 1}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  _buildStepText(_currentPage),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: 380,
                              height: 60,
                              child: ElevatedButton(
                                // onPressed: _isModelLoaded
                                //     ? _requestPermissionAndPickFile
                                //     : null,
                                onPressed: _requestPermissionAndPickFile,
                                // onPressed: () async {
                                //   await _apiService.savePhotoResult({
                                //     "nature": 0,
                                //     "person": 74,
                                //     "animal": 16,
                                //     "vehicle": 16,
                                //     "homeAppliance": 0,
                                //     "food": 20,
                                //     "furniture": 14,
                                //     "daily": 0,
                                //     "home_appliance": 10
                                //   });
                                // },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColor.buttonColor.colors,
                                ),
                                child: const Text(
                                  '사진 취향 분석하기',
                                  style: TextStyle(
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                }
              },
            );
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _isModelLoaded ? _requestPermissionAndPickFile : null,
      //   tooltip: 'Pick Folder',
      //   child: const Icon(Icons.folder),
      // ),
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _currentPage == index
            ? const Color(0xff6F6F6F)
            : const Color(0xffD9D9D9),
      ),
    );
  }

  Widget _buildStepText(int index) {
    String text;
    switch (index) {
      case 0:
        text = '어플이 이미지 파일에 접근할 수 있도록 권한을 허용해주세요';
      default:
        text = '분석하고 싶은 파일을 선택하세요';
    }
    return Text(
      text,
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
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
