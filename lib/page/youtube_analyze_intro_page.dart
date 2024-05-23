import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/page/youtube_analyze_result_page.dart';

import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/util/app_color.dart';

class YoutubeAnalyzeIntroPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;
  const YoutubeAnalyzeIntroPage({super.key, required this.onNavigateToProfile});

  @override
  State<YoutubeAnalyzeIntroPage> createState() =>
      _YoutubeAnalyzeIntroPageState();
}

class _YoutubeAnalyzeIntroPageState extends State<YoutubeAnalyzeIntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserInfoProvider>(
        builder: (context, userInfoProvider, child) {
          if (userInfoProvider.userInfo == null) {
            return Center(
              child: SpinKitWaveSpinner(
                  color: AppColor.buttonColor.colors, size: 100),
            );
          } else {
            final userInfo = userInfoProvider.userInfo;
            return Column(
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                const Center(
                  child: Text(
                    '분석에 사용된 개인정보는 바로 폐기돼요 !',
                    style: TextStyle(
                      fontSize: 22,
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
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
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
                        '좋아하는 영상 카테고리 분석',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(
                        indent: 30,
                        endIndent: 30,
                      ),
                      Text(
                        '${userInfo!.name.substring(1)}님의 Youtube 구독 목록을 기반으로'
                        '\n좋아하는 영상 카테고리를 분석해요!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: PageView(
                          controller: _pageController,
                          children: [
                            Image.asset('assets/images/youtube_analyze1.png'),
                            Image.asset('assets/images/youtube_analyze2.png'),
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
                          const SizedBox(),
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
                  height: 20,
                ),
                SizedBox(
                  width: 380,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool isSignIn = await _signInWithGoogle();
                      if (isSignIn) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => YoutubeAnalyzeResultPage(
                                onNavigateToProfile:
                                    widget.onNavigateToProfile)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColor.buttonColor.colors,
                    ),
                    child: const Text(
                      '좋아하는 영상 분석하기',
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                //TODO 로그아웃 버튼 및 메서드 삭제
                ElevatedButton(
                  onPressed: signOut,
                  child: const Text('로그아웃'),
                ),
              ],
            );
          }
        },
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
        text = "영상 카테고리를 분석하고자하는 구글 계정을 선택해주세요";
      default:
        text = "구글 계정에 대한 접근을 허용해주세요";
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  Future<bool> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
        'https://www.googleapis.com/auth/youtube.readonly',
      ],
      serverClientId:
          '748389893868-o38se8gksu0u8ihnia6gc3e5bbu42pnr.apps.googleusercontent.com',
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    if (googleUser != null) {
      print(googleAuth);
      String? idToken = googleAuth!.idToken;
      print('name = ${googleUser.displayName}');
      print('email= ${googleUser.email}');
      print('id =${googleUser.id}');
      print('OAuth2.0=${idToken}');
      print('access token= ${googleAuth!.accessToken}');

      return true;
    }
    return false;
  }

  // Future<void> _fetchSubscriptions(String accessToken) async {
  //   final client = authenticatedClient(
  //     Client(),
  //     AccessCredentials(
  //       AccessToken('Bearer', accessToken,
  //           DateTime.now().add(Duration(hours: 1)).toUtc()),
  //       // Ensure expiry is in UTC
  //       null,
  //       ['https://www.googleapis.com/auth/youtube.readonly'],
  //     ),
  //   );
  //
  //   final youtubeApi = youtube.YouTubeApi(client);
  //
  //   try {
  //     final subscriptionsResponse = await youtubeApi.subscriptions.list(
  //       ['snippet', 'contentDetails'],
  //       mine: true,
  //       maxResults: 50, // Fetch up to 50 subscriptions
  //     );
  //
  //     for (var item in subscriptionsResponse.items!) {
  //       print(
  //           'Channel: ${item.snippet?.title}, ID: ${item.snippet?.resourceId?.channelId}');
  //     }
  //   } catch (e) {
  //     print('Failed to fetch subscriptions: $e');
  //   } finally {
  //     client.close();
  //   }
  // }

  void signOut() async {
    await GoogleSignIn().signOut();
  }
}
