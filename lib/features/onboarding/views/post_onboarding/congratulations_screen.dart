import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voiceclub_partner/core/services/session_router.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/auth_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({super.key});

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  final _authController = Get.find<AuthController>();
  @override
  void initState() {
    super.initState();
    trackPageViewEvent();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fireCheckoutEvents();
      getProfile();
    });
  }

  void trackPageViewEvent() {
    final registerResponseModel = _authController.profileResponseModel;

    sl<AnalyticsService>().trackEvent(
      "congratulationsScreen",
      eventProperties: {
        "profileStatus": registerResponseModel.value.profileStatus?.name,
        "hasWatchedTutorial": registerResponseModel.value.hasWatchedTutorial,
      },
    );
  }

  Future<void> downloadPDF() async {
    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      File? pdfFile = await Get.find<AuthController>().getSignedDocumentFile();
      const downloadsFolderPath = '/storage/emulated/0/Download';
      Directory dir = Directory(downloadsFolderPath);
      final file = File(
        '${dir.path}/voiceclub_agreement${Random().nextInt(100)}.pdf',
      );
      Uint8List byteData = Uint8List(0);
      if (pdfFile != null) {
        byteData = pdfFile.readAsBytesSync();
      }
      try {
        await file.writeAsBytes(byteData);
        Get.snackbar(
          LocaleKeys.downloadedSuccessfully.tr,
          LocaleKeys.agreementSaved.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Logger.logError(e.toString());
        Get.snackbar(
          LocaleKeys.somethingWentWrong.tr,
          LocaleKeys.pleaseTryAgain.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {}
    }
    sl<AnalyticsService>().trackEvent(
      "permissionPopup",
      eventProperties: {
        "permission": status.name,
        "type": "Storage",
        "screenName": "congratulationsScreen",
      },
    );
  }

  Future<void> getProfile() async {
    Get.find<AuthController>().getProfile(
      _authController.profileResponseModel.value.phone ?? "",
      shouldNavigate: false,
    );
  }

  void fireCheckoutEvents() async {
    await sl<AnalyticsService>().fireCheckoutEvents();
  }

  @override
  Widget build(BuildContext context) {
    // final overrideCourse =
    //     sl<GrowthBookService>().isFeatureEnabled(FeatureFlag.courseoverride);
    final registerResponseModel = _authController.profileResponseModel;
    final currentAppLocale = Get.find<AuthController>().currentAppLocale.value;

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              Get.find<AuthController>().getProfile(
                registerResponseModel.value.phone ?? "",
                shouldNavigate: false,
              );
            },
            child: Obx(() {
              if (_authController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: Get.height - Get.mediaQuery.padding.bottom,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Visibility(
                          visible:
                              currentAppLocale != AppLanguage.Hindi &&
                              (registerResponseModel.value.hasWatchedTutorial ??
                                  false),
                          replacement: Lottie.asset(
                            AssetConstants.celebrationAnimation,
                            repeat: true,
                          ),
                          child: Visibility(
                            visible:
                                registerResponseModel.value.profileStatus ==
                                ProfileStatus.ACCOUNT_ONBOARDED,
                            replacement: const SizedBox.shrink(),
                            child: Lottie.asset(
                              AssetConstants.celebrationAnimation,
                              repeat: true,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 80.0),
                            Visibility(
                              visible:
                                  currentAppLocale != AppLanguage.Hindi &&
                                  (registerResponseModel
                                          .value
                                          .hasWatchedTutorial ??
                                      false),
                              replacement: Container(
                                height: 100.0,
                                width: 100.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4EBB0B),
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: const Icon(
                                  Icons.done,
                                  size: 70.0,
                                  color: Colors.white,
                                ),
                              ),
                              child: Visibility(
                                visible:
                                    registerResponseModel.value.profileStatus ==
                                    ProfileStatus.ACCOUNT_ONBOARDED,
                                replacement: Image.asset(
                                  AssetConstants.icPending,
                                  height: 90,
                                  width: 90,
                                ),
                                child: Container(
                                  height: 100.0,
                                  width: 100.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF4EBB0B),
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: const Icon(
                                    Icons.done,
                                    size: 70.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              currentAppLocale != AppLanguage.Hindi &&
                                      (registerResponseModel
                                              .value
                                              .hasWatchedTutorial ??
                                          false)
                                  ? registerResponseModel.value.profileStatus ==
                                          ProfileStatus.ACCOUNT_ONBOARDED
                                      ? LocaleKeys.congratulations.tr
                                      : LocaleKeys.pending.tr
                                  : LocaleKeys.congratulations.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: FontSize.xXXXL,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              currentAppLocale != AppLanguage.Hindi &&
                                      (registerResponseModel
                                              .value
                                              .hasWatchedTutorial ??
                                          false)
                                  ? registerResponseModel.value.profileStatus ==
                                          ProfileStatus.ACCOUNT_ONBOARDED
                                      ? LocaleKeys.profileVerified.tr
                                      : LocaleKeys.accountUnderProcess.tr
                                  : LocaleKeys.profileVerified.tr,
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            // StepWidget(
                            //   onTap: () {
                            //     Get.to(() => const ViewAgreementScreen());
                            //   },
                            //   onDownloadTap: downloadPDF,
                            //   step: 1,
                            //   stepName: LocaleKeys.signAgreement.tr,
                            //   completed: registerResponseModel
                            //           .value.isLegalDocumentSigned ??
                            //       false,
                            //   isCurrent: true,
                            // ),
                            // StepWidget(
                            //   onTap: () {
                            //     Get.to(() => const CourseScreen());
                            //   },
                            //   step: 1,
                            //   stepName: LocaleKeys.completeCourse.tr,
                            //   completed: (registerResponseModel
                            //           .value.hasWatchedTutorial ??
                            //       false),
                            //   isCurrent: true,
                            // ),
                            const SizedBox(height: 30.0),
                            CustomButton(
                              text: LocaleKeys.continueLabel.tr,

                              onTap: () async {
                                sl<AnalyticsService>().trackEvent(
                                  "startPartnerAppButtonTap",
                                  eventProperties: {
                                    "profileStatus":
                                        registerResponseModel
                                            .value
                                            .profileStatus
                                            ?.name,
                                  },
                                );
                                SessionRouter.startPartnerAppFromOnboarding();
                              },
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
