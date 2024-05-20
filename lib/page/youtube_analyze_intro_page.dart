import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/util/app_color.dart';

class YoutubeAnalyzeIntroPage extends StatefulWidget {
  const YoutubeAnalyzeIntroPage({super.key});

  @override
  State<YoutubeAnalyzeIntroPage> createState() =>
      _YoutubeAnalyzeIntroPageState();
}

class _YoutubeAnalyzeIntroPageState extends State<YoutubeAnalyzeIntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserInfoProvider>(
        builder: (context, userInfoProvider, child) {
          if (userInfoProvider.userInfo == null) {
            return Center(
                child: SpinKitWaveSpinner(
                    color: AppColor.buttonColor.colors, size: 100));
          } else {
            final userInfo = userInfoProvider.userInfo;
            return Column(
              children: <Widget>[
                const SizedBox(
                  height: 40,
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
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
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
                    children: [
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
                        '${userInfo!.name.substring(1)}님의 Youtube 시청 기록을 기반으로'
                        '\n좋아하는 영상 카테고리를 분석해요!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: 380,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _signInWithGoogle,
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
                ElevatedButton(
                  onPressed: signOut,
                  child: Text('로그아웃'),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
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
      if (googleAuth?.accessToken != null) {
        await _fetchSubscriptions(googleAuth!.accessToken!);
      }
    }
  }

  Future<void> _fetchSubscriptions(String accessToken) async {
    final client = authenticatedClient(
      Client(),
      AccessCredentials(
        AccessToken('Bearer', accessToken,
            DateTime.now().add(Duration(hours: 1)).toUtc()),
        // Ensure expiry is in UTC
        null,
        ['https://www.googleapis.com/auth/youtube.readonly'],
      ),
    );

    final youtubeApi = youtube.YouTubeApi(client);

    try {
      final subscriptionsResponse = await youtubeApi.subscriptions.list(
        ['snippet', 'contentDetails'],
        mine: true,
        maxResults: 50, // Fetch up to 50 subscriptions
      );

      for (var item in subscriptionsResponse.items!) {
        print(
            'Channel: ${item.snippet?.title}, ID: ${item.snippet?.resourceId?.channelId}');
      }
    } catch (e) {
      print('Failed to fetch subscriptions: $e');
    } finally {
      client.close();
    }
  }

  void signOut() async {
    await GoogleSignIn().signOut();
  }
}
