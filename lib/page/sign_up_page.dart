import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:untitled1/page/sign_in_page.dart';
import 'package:untitled1/util/app_color.dart';
import 'package:untitled1/util/format_rule.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  CroppedFile? _croppedFile;

  //TODO 입력한 정보들을 서버로 넘기는 작업 필요
  //TODO User 클래스로 묶기
  //TODO 서버로 보낼 정보: 프로필 사진, 아이디, 비밀번호, 이름, 생일

  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  bool _idIsAvailable = false;
  bool _passwordIsObscured = true;

  String _idError = '';

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _birthday;
  String _birthdayText = '';

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //생일 선택 메서드
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _birthday = pickedDate;
        _birthdayText = DateFormat('MM월 dd일').format(pickedDate);
      });
    });
  }

  //TODO 서버에 중복되는 아이디가 있는지 확인

  void _checkUsernameAvailability() async {
    FocusScope.of(context).unfocus();
    //서버에 중복 확인 요청 해야됨
    //_idError ='아이디가 중복됩니다.';
    if (_idController.text.isEmpty) {
      setState(() {
        _idError = '아이디를 입력해주세요';
      });
    } else if (!FormatRule.ID_FORMAT.regex.hasMatch(_idController.text)) {
      setState(() {
        _idError = '아이디는 6~12자의 영문, 숫자만 사용 가능합니다';
      });
    } else {
      _idError = '';
      _idIsAvailable = true;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _idIsAvailable) {
      setState(() {
        _isSubmitting = true;
      });
      //TODO 데이터를 서버로 전송하는 로직 구현해야 함

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignInPage()));
    }
  }

  //프로필 사진 적용 로직
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _cropImage(pickedImage.path);
    }
  }

  Future<void> _cropImage(String path) async {
    final croppedFile =
        await ImageCropper().cropImage(sourcePath: path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ], uiSettings: [
      AndroidUiSettings(
        toolbarTitle: '',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        title: 'Cropper',
      ),
    ]);

    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
      });
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
            children: [
              const SizedBox(
                height: 40,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Text(
                    '회원 가입',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    child: _croppedFile != null
                        ? ClipOval(
                            child: Image.file(
                              File(_croppedFile!.path),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(
                            child: Image.asset(
                              'assets/images/default_profile.png',
                              width: 150,
                              height: 150,
                            ),
                          ),
                  ),
                  Transform.translate(
                    offset: const Offset(-10, 50),
                    child: IconButton(
                      onPressed: pickImage,
                      style: IconButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.black26,
                        ),
                      ),
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Text(
                    '아이디',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: 280,
                          height: 60,
                          child: TextFormField(
                            controller: _idController,
                            decoration: InputDecoration(
                              hintText: '6~12자 이내 영문, 숫자 사용 가능',
                              errorText: _idError.isEmpty ? null : _idError,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '아이디를 입력해주세요';
                              }
                              if (!_idIsAvailable && value.isNotEmpty) {
                                return '아이디 중복 확인을 해주세요';
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          height: 60,
                          child: ElevatedButton(
                            //TODO 중복확인 로직 구현
                            onPressed: _checkUsernameAvailability,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    AppColor.buttonColor.getColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                )),
                            child: const Text(
                              '중복 확인',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12.0, 15.0, 0, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '비밀번호',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _passwordIsObscured,
                        decoration: InputDecoration(
                          hintText: '8~16자 이내 영문, 숫자, 특수 문자 사용 가능',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordIsObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordIsObscured = !_passwordIsObscured;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          if (!FormatRule.PASSWORD_FORMAT.regex
                              .hasMatch(value)) {
                            return '비밀번호는 8~16자의 문자, 숫자, 기호를 사용해야 합니다';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12.0, 15.0, 0, 0),
                        child: Text(
                          '비밀번호 재입력',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _passwordIsObscured,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordIsObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordIsObscured = !_passwordIsObscured;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12.0, 15.0, 0, 0),
                        child: Text(
                          '이름',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12.0, 15.0, 0, 0),
                        child: Text(
                          '생일',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _presentDatePicker,
                      child: AbsorbPointer(
                        child: SizedBox(
                          width: 400,
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: _birthdayText.isEmpty
                                  ? '월 일 선택'
                                  : _birthdayText,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_birthday == null) {
                                return '생일을 선택해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 400,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColor.buttonColor.getColor(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            )),
                        onPressed: _submitForm,
                        child: const Text(
                          '회원가입 하기',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
