import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  final _formKey = GlobalKey<FormState>();
  String? _validationError;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _birthday;

  @override
  void  initState() {
    super.initState();
    _idController.addListener(_validateId);
  }

  //TODO 아이디 유효성 검사 추가

  void _validateId() {
    final idValue = _idController.text;
    if(idValue.isNotEmpty&& !FormatRule.ID_FORMAT.regex.hasMatch(idValue)) {
      setState(() {
        _validationError = '6~12자의 영문, 숫자만 사용 가능합니다.';
      });
    } else {
      setState(() {
        _validationError = null;
      });
    }
  }

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
    return Scaffold(
      body: Column(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 260,
                child: Column(
                  children: [
                    TextFormField(
                      key: const ValueKey(1),
                      controller: _idController,
                      decoration: const InputDecoration(
                        hintText: '6~12자의 영문, 숫자 사용 가능',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력해주세요';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9]{6,12}$').hasMatch(value)) {
                          return '아이디는 6~12자의 영문, 숫자만 가능합니다.';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('처리 중...')));
                        }
                      },
                      child: Text('등록확인'),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 110,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.buttonColor.getColor(),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    '중복 확인',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
