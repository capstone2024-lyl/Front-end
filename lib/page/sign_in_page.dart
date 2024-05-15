import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;

import 'package:untitled1/page/navigate_page.dart';
import 'package:untitled1/page/sign_up_page.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/app_color.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    try {
          await _apiService.login(_idController.text, _passwordController.text);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigatePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      //로그인 실패시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('존재하지 않는 계정입니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: SingleChildScrollView(
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
              SizedBox(
                width: 380,
                height: 60,
                child: TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력하세요',
                      suffixIcon: IconButton(
                        icon: _isPasswordObscured
                            ? const Icon(
                                Icons.visibility_off_outlined,
                                size: 15,
                              )
                            : const Icon(
                                Icons.visibility_outlined,
                                size: 15,
                              ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
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
                    backgroundColor: AppColor.buttonColor.colors,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _login,
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()));
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
                    ),
                  ),
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
      ),
    );
  }
}
