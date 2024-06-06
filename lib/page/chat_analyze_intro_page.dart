import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:untitled1/page/chat_analyze_result_page.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/app_color.dart';

class ChatAnalyzeIntroPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;

  const ChatAnalyzeIntroPage({super.key, required this.onNavigateToProfile});

  @override
  State<ChatAnalyzeIntroPage> createState() => _ChatAnalyzeIntroPageState();
}

class _ChatAnalyzeIntroPageState extends State<ChatAnalyzeIntroPage> {
  final ApiService _apiService = ApiService();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _isLoading = false;

  List<File> _txtFiles = [];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_updatePage);
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    _pageController.dispose();
    super.dispose();
  }

  void _updatePage() {
    setState(() {
      _currentPage = _pageController.page!.round();
    });
  }

  Future<void> _listTxtFiles() async {
    Directory kakaoTalkDir =
        Directory('/storage/emulated/0/Documents/KakaoTalk/Chats');

    if (await kakaoTalkDir.exists()) {
      List<File> files = await _getTxtFiles(kakaoTalkDir);
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      setState(() {
        _txtFiles = files;
      });
    }
  }

  Future<List<File>> _getTxtFiles(Directory dir) async {
    List<File> txtFiles = [];

    await for (FileSystemEntity entity
        in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        if (entity.path.endsWith('.txt')) {
          txtFiles.add(entity);
        }
      }
    }

    return txtFiles;
  }

  void _showFilePickerDialog() async {
    await _listTxtFiles();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('분석할 채팅 파일을 선택해주세요!')),
          backgroundColor: AppColor.cardColor.colors,
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: _txtFiles.isEmpty
                ? Center(
                    child: SpinKitWaveSpinner(
                    color: AppColor.buttonColor.colors,
                    waveColor: Colors.white,
                    size: 100,
                  ))
                : ListView.builder(
                    itemCount: _txtFiles.length,
                    itemBuilder: (context, index) {
                      File file = _txtFiles[index];
                      return ListTile(
                        title: Text(file.path.split('/').last),
                        subtitle: Text(file.path),
                        onTap: () async {
                          Navigator.of(context).pop(file.path);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    ).then((selectedFilePath) {
      if (selectedFilePath != null) {
        _handleFileSelection(selectedFilePath);
      }
    });
  }

  void _handleFileSelection(String filePath) async {
    setState(() {
      _isLoading = true;
    });

    File file = File(filePath);
    bool isUploaded = await _apiService.uploadChattingFile(file);
    if (isUploaded && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ChatAnalyzeResultPage(
          onNavigateToProfile: widget.onNavigateToProfile,
        ),
      ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestPermissionAndPickFile() async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림'),
          backgroundColor: AppColor.cardColor.colors,
          content: const Text('채팅 내역을 분석하려면 파일 접근을 허용해주세요'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                status = await Permission.manageExternalStorage.request();
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      );
    }

    if (status.isGranted) {
      _showFilePickerDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              const Center(
                child: Text(
                  '채팅을 통한 MBTI 분석하기',
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
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      blurRadius: 3.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0.0, 5.0),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      '채팅 업로드 방법',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
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
                          SvgPicture.asset('assets/images/chat1.svg'),
                          SvgPicture.asset('assets/images/chat2.svg'),
                          SvgPicture.asset('assets/images/chat3.svg'),
                          SvgPicture.asset('assets/images/chat4.svg'),
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
                        const SizedBox(
                          width: 5,
                        ),
                        _buildIndicator(2),
                        const SizedBox(
                          width: 5,
                        ),
                        _buildIndicator(3),
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
                    _buildStepText(_currentPage),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '채팅 내역은 분석에만 사용되고 바로 삭제돼요!',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 380,
                height: 60,
                child: ElevatedButton(
                  onPressed: _requestPermissionAndPickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.buttonColor.colors,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '채팅 내역 업로드 하기',
                    style: TextStyle(
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: SpinKitWaveSpinner(
                  color: AppColor.buttonColor.colors,
                  waveColor: Colors.white,
                  trackColor: Colors.black26,
                  size: 150,
                ),
              ),
            ),
        ],
      ),
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
        text = '채팅내역을 업로드하고 싶은 채팅방에서 우측 상단의 햄버거 옵션을 선택하세요';
      case 1:
        text = '화면 우측 하단에 있는 톱니바퀴를 선택하세요.';
      case 2:
        text = '채팅방 설정 메뉴 중 대화 내용 내보내기를 선택하세요.';
      default:
        text = '대화 내용 내보내기 메뉴 중 모든 메세지 내부저장소에 저장을 선택하세요.';
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
