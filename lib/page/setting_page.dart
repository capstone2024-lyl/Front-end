import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/providers/user_info_provider.dart';
import 'package:untitled1/services/api_service.dart';
import 'package:untitled1/util/app_color.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  Future<bool> _requestGalleryPermissionsAndPickPhoto() async {
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
      return await _pickImage();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(
                title: const Text('권한 필요'),
                backgroundColor: AppColor.cardColor.colors,
                content: const Text('사진을 업로드하려면 갤러리 접근 권한이 필요합니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
        return false;
      }
      return false;
    }

    // 사용자가 권한 요청을 거부한 경우
  }

  //프로필 사진 적용 로직
  Future<bool> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      return await _cropImage(pickedImage.path);
    }
    return false;
  }

  Future<bool> _cropImage(String path) async {
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
        _isLoading = true;
      });
      bool response = await _apiService.updateProfileImage(
          profileImage: croppedFile);
      setState(() {
        _isLoading = false;
      });
      if (response) {
        return response;
      } else {
        return response;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserInfoProvider>(
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
            return Stack(
              children: [
                Column(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.image),
                          title: const Text('프로필 사진 변경'),
                          onTap: () async {
                            bool result = await _requestGalleryPermissionsAndPickPhoto();
                            if(result) {
                              await userInfoProvider.updateProfileImageUrl();
                            }

                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.delete_forever),
                          title: const Text('프로필 사진 삭제'),
                          onTap: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            bool result = await _apiService.deleteProfileImage();
                            if(result) {
                              await userInfoProvider.updateProfileImageUrl();
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                        ),
                        const Divider(),
                      ],
                    ),
                  ],
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: SpinKitWaveSpinner(
                        color: AppColor.buttonColor.colors,
                        size: 200,
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
