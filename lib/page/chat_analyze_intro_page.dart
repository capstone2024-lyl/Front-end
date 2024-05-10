import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled1/util/app_color.dart';

class ChatAnalyzeIntroPage extends StatefulWidget {
  const ChatAnalyzeIntroPage({super.key});

  @override
  State<ChatAnalyzeIntroPage> createState() => _ChatAnalyzeIntroPageState();
}

class _ChatAnalyzeIntroPageState extends State<ChatAnalyzeIntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_updatePage);
  }

  void _updatePage() {
    setState(() {
      _currentPage = _pageController.page!.round();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 60,
          ),
          const Center(
            child: Text(
              '채팅 내역은 분석에만 사용되고 바로 삭제돼요 !',
              style: TextStyle(
                fontSize: 20,
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
                  'Step ${_currentPage+1}',
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
            height: 60,
          ),
          SizedBox(
            width: 380,
            height: 60,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.buttonColor.colors,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                '채탱 내역 업로드 하기',
                style: TextStyle(
                  fontSize: 26,
                ),
              ),
            ),
          )
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
    switch(index) {
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
      child: Text(text, textAlign: TextAlign.center,),
    );
  }
}
