import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';

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

  Future<bool> _checkIdDuplicated() async {
    final url = Uri.parse(
        'http://13.209.182.60:8080/api/v1/user/login/is-duplicated?loginId=${_idController.text}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (response.body == 'can use') {
        return false;
      } else {
        return true;
      }
    } else {
      throw Exception('Failed to check login ID');
    }
  }

  void _checkUsernameAvailability() async {
    FocusScope.of(context).unfocus();
    if (_idController.text.isEmpty) {
      setState(() {
        _idError = '아이디를 입력해주세요';
      });
      return;
    } else if (!FormatRule.ID_FORMAT.regex.hasMatch(_idController.text)) {
      setState(() {
        _idError = '아이디는 6~12자의 영문, 숫자만 사용 가능합니다';
      });
      return;
    }
    bool result = await _checkIdDuplicated();
    if (!result) {
      setState(() {
        _idError = '';
        _idIsAvailable = true;
      });
    } else {
      setState(() {
        _idError = '아이디가 중복됩니다.';
      });
    }
  }

  Future<bool> _requestSignUp() async {
    final url = Uri.parse('http://13.209.182.60:8080/api/v1/user/sign-up');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': ' application/json',
      },
      body: jsonEncode(<String, String>{
        'loginId': _idController.text,
        'password': _passwordController.text,
        'passwordCheck': _confirmPasswordController.text,
        'name': _nameController.text,
        'birthday': DateFormat('yyyy-MM-dd').format(_birthday!),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to Submit');
    }
  }

  void _submitForm() async {
    bool result = await _requestSignUp();
    if (_formKey.currentState!.validate() && _idIsAvailable && result) {
      setState(() {
        _isSubmitting = true;
      });

      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SignInPage()));
      }
    }
  }

  //프로필 사진 적용 로직
  Future<void> _pickImage() async {
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
              Stack(
                alignment: Alignment.center,
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
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      onPressed: _requestGalleryPermissionsAndPickPhoto,
                      style: IconButton.styleFrom(
                          side: const BorderSide(color: Colors.black26),
                          backgroundColor: Colors.white),
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                      ),
                    ),
                  )
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
                            onPressed: () async {
                              _checkUsernameAvailability();
                              if (_idIsAvailable) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('알림'),
                                    content: const Text('사용 가능한 아이디입니다.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('확인'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColor.buttonColor.colors,
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
                          hintText: '8~16자 이내 영문, 숫자, 특수 문자를 모두 사용',
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
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          if (!FormatRule.PASSWORD_FORMAT.regex
                              .hasMatch(value)) {
                            return '비밀번호는 8~16자의 문자, 숫자, 기호를 모두 사용해야 합니다';
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
                              border: const OutlineInputBorder(),
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
                            backgroundColor: AppColor.buttonColor.colors,
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

  //갤러리 접근 권한 요청
  Future<void> _requestGalleryPermissionsAndPickPhoto() async {
    // 사진 접근 권한 상태 확인
    var status = await Permission.photos.status;
    // 이미 권한이 허용된 경우
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    // 권한이 영구적으로 거부된 경우
    if (status.isPermanentlyDenied) {
      // 사용자에게 설정 메뉴로 이동하여 권한을 허용하도록 요청
      openAppSettings();
    }

    // 권한 요청
    if (status.isGranted) {
      // 권한이 허용된 경우
      _pickImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('권한 필요'),
          content: const Text('사진을 업로드하려면 갤러리 접근 권한이 필요합니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '확인',
              ),
            )
          ],
        ),
      );
    }

    // 사용자가 권한 요청을 거부한 경우
  }
}
