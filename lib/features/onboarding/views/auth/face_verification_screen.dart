import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/face_verification_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  CameraController? controller;
  Future<void>? _initializeCameraFuture;
  late FaceVerificationController _faceVerificationController;
  bool _hasCameraPermission = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    _faceVerificationController = Get.put(FaceVerificationController());
    sl<AnalyticsService>().trackEvent("faceVerificationScreen");
    _checkInitialPermissionStatus();
  }

  /// **Check if permission is already granted on init**
  Future<void> _checkInitialPermissionStatus() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        setState(() {
          _hasCameraPermission = true;
        });
        // Delay initialization to ensure widget is fully built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeCamera();
        });
      }
    } catch (e) {
      // Silently handle permission check errors
    }
  }

  /// **Initialize Camera for Web**
  Future<void> _initializeCamera() async {
    // Dispose existing controller if any
    if (controller != null) {
      try {
        if (controller!.value.isInitialized) {
          await controller!.dispose();
        }
      } catch (e) {
        // Ignore disposal errors
      }
      controller = null;
    }

    // Check if already initializing
    if (_initializeCameraFuture != null) {
      try {
        await _initializeCameraFuture;
      } catch (e) {
        // Ignore previous initialization errors
      }
    }

    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }

      CameraDescription? cameraDescription = _cameras.firstWhereOrNull(
        (element) => element.lensDirection == CameraLensDirection.front,
      );

      if (cameraDescription != null) {
        final newController = CameraController(
          cameraDescription,
          ResolutionPreset.high,
          enableAudio: false,
        );

        setState(() {
          controller = newController;
          _initializeCameraFuture = controller!.initialize();
        });

        // Wait for initialization to complete
        await _initializeCameraFuture;
      }
    } catch (e) {
      // Handle camera initialization errors gracefully
      setState(() {
        controller = null;
        _initializeCameraFuture = null;
      });
    }
  }

  /// **Request Camera Permission**
  Future<void> _requestCameraPermission() async {
    sl<AnalyticsService>().trackEvent("openCamera");

    try {
      var status = await Permission.camera.status;

      if (status.isDenied) {
        status = await Permission.camera.request();
      }

      sl<AnalyticsService>().trackEvent(
        "permissionPopup",
        eventProperties: {
          "permission": status.name,
          "type": "Camera",
          "screenName": "faceVerificationScreen",
        },
      );

      if (status != PermissionStatus.granted) {
        Get.dialog(
          AlertDialog(
            title: Text(LocaleKeys.cameraPermissionRequired.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LocaleKeys.cameraAccessRequiredBrowser.tr),
                const SizedBox(height: 16),
                if (kIsWeb) ...[
                  Text(
                    LocaleKeys.toEnableCameraAccess.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(LocaleKeys.clickLockIcon.tr),
                  Text(LocaleKeys.findCameraInPermissions.tr),
                  Text(LocaleKeys.changeSettingToAllow.tr),
                  Text(LocaleKeys.refreshThePage.tr),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(LocaleKeys.cancel.tr),
              ),
              if (!kIsWeb)
                TextButton(
                  onPressed: () async {
                    Get.back();
                    await openAppSettings();
                  },
                  child: Text(LocaleKeys.openSettings.tr),
                ),
            ],
          ),
        );
        return;
      }

      if (status.isGranted) {
        // Only initialize if not already initialized
        if (!_hasCameraPermission ||
            controller == null ||
            !controller!.value.isInitialized) {
          setState(() {
            _hasCameraPermission = true;
          });
          _initializeCamera();
        }
      } else {
        Get.dialog(
          AlertDialog(
            title: Text(LocaleKeys.cameraAccessDenied.tr),
            content: Text(LocaleKeys.pleaseAllowCameraAccess.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(LocaleKeys.ok.tr),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle permission request errors
      Get.dialog(
        AlertDialog(
          title: Text(LocaleKeys.errorTitle.tr),
          content: Text(LocaleKeys.cameraPermissionError.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(LocaleKeys.ok.tr),
            ),
          ],
        ),
      );
    }
  }

  /// **Take Picture using `camera_web`**
  Future<void> takePicture() async {
    sl<AnalyticsService>().trackEvent("takePicture");
    final image = await controller?.takePicture();
    if (image != null) {
      _faceVerificationController.image.value = File(image.path);
    }
  }

  String getDescriptionString() {
    switch (_faceVerificationController.faceVerificationState.value) {
      case FaceVerificationState.Incomplete:
        return _hasCameraPermission
            ? LocaleKeys.bringFaceInsideBox.tr
            : LocaleKeys.openCamera.tr;
      case FaceVerificationState.Rejected:
        return LocaleKeys.hiringFemalePartners.tr;
      case FaceVerificationState.Accepted:
        return LocaleKeys.faceVerificationCompleted.tr;
    }
  }

  String getButtonString() {
    if (!_hasCameraPermission) {
      return LocaleKeys.openCamera.tr;
    }

    switch (_faceVerificationController.faceVerificationState.value) {
      case FaceVerificationState.Incomplete:
        if (_faceVerificationController.image.value != null) {
          return LocaleKeys.startVerification.tr;
        } else {
          return LocaleKeys.takePicture.tr;
        }
      case FaceVerificationState.Rejected:
        return LocaleKeys.downloadVoiceClubApp.tr;
      case FaceVerificationState.Accepted:
        return LocaleKeys.continueLabel.tr;
    }
  }

  @override
  void dispose() {
    // Properly dispose camera controller
    if (controller != null) {
      try {
        if (controller!.value.isInitialized) {
          controller!.dispose();
        }
      } catch (e) {
        // Ignore disposal errors during widget disposal
      }
      controller = null;
    }
    _initializeCameraFuture = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width * 0.75;

    return Obx(() {
      return Scaffold(
        body: SafeArea(
          child: Container(
            width: Get.width,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Visibility(
                  visible:
                      _faceVerificationController.faceVerificationState.value !=
                      FaceVerificationState.Incomplete,
                  replacement: Container(
                    width: width,
                    height: width,
                    decoration: const BoxDecoration(
                      color: ApplicationColors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(width / 2),
                      child:
                          _faceVerificationController.image.value != null
                              ? Image.file(
                                _faceVerificationController.image.value!,
                                fit: BoxFit.cover,
                              )
                              : _hasCameraPermission
                              ? FutureBuilder(
                                future: _initializeCameraFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 50,
                                            color: ApplicationColors.grey,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            LocaleKeys.cameraError.tr,
                                            style: TextStyle(
                                              color: ApplicationColors.grey,
                                              fontWeight: Weight.heavy,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    if (controller != null) {
                                      return CameraPreview(controller!);
                                    } else {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                              size: 50,
                                              color: ApplicationColors.grey,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              LocaleKeys.cameraNotAvailable.tr,
                                              style: TextStyle(
                                                color: ApplicationColors.grey,
                                                fontWeight: Weight.heavy,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                },
                              )
                              : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 50,
                                      color: ApplicationColors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      LocaleKeys.openCamera.tr,
                                      style: TextStyle(
                                        color: ApplicationColors.grey,
                                        fontWeight: Weight.heavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),
                  child: Image.asset(
                    _faceVerificationController.faceVerificationState.value ==
                            FaceVerificationState.Rejected
                        ? AssetConstants.faceVerificationMale
                        : AssetConstants.faceVerificationFemale,
                    height: width,
                    width: width,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Get.theme.primaryColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getDescriptionString(),
                    textAlign: TextAlign.center,
                    style:
                        _faceVerificationController
                                    .faceVerificationState
                                    .value ==
                                FaceVerificationState.Accepted
                            ? const TextStyle(
                              fontWeight: Weight.heavy,
                              fontSize: FontSize.xXL,
                            )
                            : null,
                  ),
                ),
                const Spacer(),
                Visibility(
                  visible:
                      (_faceVerificationController.image.value != null &&
                          _faceVerificationController
                                  .faceVerificationState
                                  .value ==
                              FaceVerificationState.Incomplete) ||
                      _faceVerificationController.faceVerificationState.value ==
                          FaceVerificationState.Rejected,
                  child: InkWell(
                    onTap: _faceVerificationController.retakeAction,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: Get.theme.primaryColor),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Get.theme.primaryColor,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              _faceVerificationController
                                          .faceVerificationState
                                          .value ==
                                      FaceVerificationState.Rejected
                                  ? LocaleKeys.tryAgain.tr
                                  : LocaleKeys.retake.tr,
                              style: TextStyle(
                                fontWeight: Weight.heavy,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: ApplicationColors.grey,
                        size: 16.0,
                      ),
                      Text(
                        " ${LocaleKeys.photoWontAppearOnProfile.tr}",
                        style: const TextStyle(color: ApplicationColors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                CustomButton(
                  text: getButtonString(),
                  onTap: () {
                    if (!_hasCameraPermission) {
                      _requestCameraPermission();
                    } else if (_faceVerificationController
                                .faceVerificationState
                                .value ==
                            FaceVerificationState.Incomplete &&
                        _faceVerificationController.image.value == null) {
                      takePicture();
                    } else {
                      _faceVerificationController.continueAction();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
