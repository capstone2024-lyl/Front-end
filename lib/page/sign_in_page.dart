import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled1/page/sign_up_page.dart';
import 'package:untitled1/util/app_color.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  //TODO 로그인 로직 구현 + 각 버튼 별 메소드 구현

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 75,
            ),
            const Center(
              child: Text(
                'I Card: 나를 알고, 소개하다',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Image.asset(
              'assets/images/loading_img.png',
              width: 200,
              height: 200,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 380,
              height: 60,
              child: TextField(
                controller: _idController,
                decoration: InputDecoration(
                    labelText: '아이디',
                    hintText: '아이디를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 380,
              height: 60,
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호를 입력하세요',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 380,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.buttonColor.getColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  //TODO 아이디 찾기 page로 이동
                  onPressed: () {},
                  child: const Text(
                    '아이디 찾기',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  //TODO 비밀번호 찾기 page로 이동
                  onPressed: () {},
                  child: const Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  //TODO 회원가입 page로 이동
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: const Divider(
                indent: 20,
                endIndent: 20,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'SNS 로그인',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 380,
              height: 60,
              child: ElevatedButton(
                //TODO 구글 로그인 구현
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    side: const BorderSide(
                      color: Colors.black38,
                      width: 1,
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google_icon.svg',
                      width: 50,
                      height: 50,
                    ),
                    const Text(
                      '구글 계정으로 로그인',
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
