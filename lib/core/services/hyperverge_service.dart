import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/location_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_onboarding_selfie.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_esign.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_kyc.dart'
    as update;
import 'package:voiceclub_partner/domain/usecases/hyperverge/get_esign_output.dart';
import 'package:voiceclub_partner/domain/usecases/hyperverge/get_kyc_output.dart';
import 'package:voiceclub_partner/domain/usecases/kyc_file/upload_kyc_file.dart'
    as upload;
import 'package:voiceclub_partner/domain/usecases/transaction/get_kyc_transaction_id.dart';
import 'package:voiceclub_partner/domain/usecases/transaction/mark_kyc_failed.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/learning/video_player_screen.dart';
import 'package:voiceclub_partner/view/profile/verification_result_screen.dart';

const String needsReviewMessage =
    "Your KYC needs further review. We will get back to you shortly.";

class HypervergeKYCService {
  // Cache transaction ID to avoid regenerating during the same KYC session
  static String? _cachedTransactionId;
  static String? _cachedPhoneNumber;

  /// Generates or retrieves cached transaction ID for the given phone number
  static Future<String?> _getTransactionId({
    required String phoneNumber,
    required KycTransactionType type,
  }) async {
    try {
      // Return cached transaction ID if it's for the same phone number
      if (_cachedTransactionId != null && _cachedPhoneNumber == phoneNumber) {
        Logger.logMessage(
          'Using cached transaction ID: $_cachedTransactionId',
          name: 'HYPERVERGE_SERVICE',
        );
        return _cachedTransactionId;
      }

      // Generate new transaction ID
      Logger.logMessage(
        'Generating new transaction ID for phone: $phoneNumber',
        name: 'HYPERVERGE_SERVICE',
      );

      final response = await sl<GetKycTransactionIdUseCase>().call(
        GetKYCTransactionIdParams(type: type),
      );

      if (response.data?.transactionId != null) {
        _cachedTransactionId = response.data!.transactionId!;
        _cachedPhoneNumber = phoneNumber;

        Logger.logMessage(
          'Generated transaction ID: $_cachedTransactionId',
          name: 'HYPERVERGE_SERVICE',
        );

        return _cachedTransactionId;
      } else {
        Logger.logMessage(
          'Failed to generate transaction ID: ${response.error?.response ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      Logger.logMessage('Error generating transaction ID: $e');
      return null;
    }
  }

  /// Clears cached transaction ID (call this when KYC is completed or failed)
  static void _clearTransactionIdCache() {
    _cachedTransactionId = null;
    _cachedPhoneNumber = null;
    Logger.logMessage(
      'Transaction ID cache cleared',
      name: 'HYPERVERGE_SERVICE',
    );
  }

  /// Marks KYC as failed for the current transaction
  static Future<void> _markKYCFailed({
    required String transactionId,
    required String reason,
  }) async {
    try {
      Logger.logMessage(
        'Marking KYC as failed for transaction ID: $transactionId, reason: $reason',
        name: 'HYPERVERGE_SERVICE',
      );

      await sl<MarkKycFailedUseCase>().call(
        MarkKycFailedParams(transactionId: transactionId),
      );

      // Clear cache after marking as failed
      _clearTransactionIdCache();
    } catch (e) {
      Logger.logMessage('Error marking KYC as failed: $e');
    }
  }

  static Future<void> launch({required String phoneNumber}) async {
    String? transactionId;
    String? errorDetail;
    try {
      // Generate unique transaction ID
      transactionId = await _getTransactionId(
        type: KycTransactionType.FULL_KYC,
        phoneNumber: phoneNumber,
      );
      if (transactionId == null) {
        throw Exception('Failed to generate transaction ID');
      }

      final workflowId = StringConstants.hypervergeWorkflowId;
      if (transactionId.isNotEmpty && transactionId != "null") {
        final hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
          appId: StringConstants.hypervergeAppId,
          appKey: StringConstants.hypervergeAppKey,
          workflowId: workflowId,
          transactionId: transactionId,
        );

        final onboardingSelfieUrl = await sl<GetOnboardingSelfieUsecase>().call(
          NoParams(),
        );
        if (onboardingSelfieUrl.data?.url?.isNotEmpty ?? false) {
          hyperKycConfig.setInputs(
            inputs: {"ImageURL": onboardingSelfieUrl.data?.url},
          );
        }
        _logResult("STARTING HYPERVERGE===== TID:$transactionId");
        sl<AnalyticsService>().trackEvent(
          "partnerVerificationInitiated",
          eventProperties: {"transactionId": transactionId},
        );
        HyperKycResult result = await HyperKyc.launch(
          hyperKycConfig: hyperKycConfig,
        );

        _logResult(result.getRawDataJsonString() ?? "NULL");
        _logResult(result.details.toString());
        _logResult("HyperKycResult Response: ${result.toMap().toString()}");

        String? status = result.status?.value;
        bool isSuccess = false;
        String message;
        errorDetail = result.errorMessage;

        switch (status) {
          case 'auto_approved':
            isSuccess = true;
            message = 'Your KYC has been successfully auto-approved.';
            break;
          case 'auto_declined':
            message = 'Unfortunately, your KYC has been auto-declined.';
            break;
          case 'needs_review':
            message = needsReviewMessage;
            break;
          case 'error':
            message =
                'An error occurred during the KYC process. Please try again later.';
            break;
          case 'user_cancelled':
            message = 'You have cancelled the KYC process.';
            break;
          default:
            message =
                'An unknown error occurred. Please contact support for more details.';
        }

        _logResult(message);
        await _processResult(
          message: message,
          isSuccess: isSuccess,
          transactionId: transactionId,
        );
      }
    } catch (e) {
      _logResult('An unexpected error occurred: $e');

      // Mark KYC as failed if we have a transaction ID
      if (transactionId != null) {
        await _markKYCFailed(
          transactionId: transactionId,
          reason: 'Unexpected error: $e',
        );
      }

      await _processResult(
        message: 'An unexpected error occurred. Please try again later.',
        isSuccess: false,
        transactionId: transactionId ?? '',
        errorDetail: errorDetail,
      );
    }
  }

  static void _logResult(String message) {
    Logger.logMessage(message, name: "HYPERVERGE");
  }

  static Future<void> _processResult({
    required String transactionId,
    required String message,
    String? errorDetail,
    bool isSuccess = false,
  }) async {
    String errorMessage = message;
    if (isSuccess) {
      try {
        Get.context?.loaderOverlay.show();
        final hyperVergeResult = await sl<GetKYCOutputUsecase>().call(
          GetKYCOutputParams(transactionId: transactionId),
        );
        _logResult(
          "GetKYCOutputUsecase Response: ${hyperVergeResult.data?.toJson().toString() ?? "NULL"}",
        );
        if (hyperVergeResult.data != null) {
          final kycData = hyperVergeResult.data?.kycDataModel;
          _logResult("KYC DATA: ${kycData.toString()}");
          if (kycData != null) {
            final panImageFileName = await _getKYCFileName(
              fileName: kycData.panImageUrl,
            );
            if (panImageFileName?.isNotEmpty ?? false) {
              kycData.updatePanImageFilename(panImageFileName!);
              final updateKycResponse = await sl<update.UpdateKYCUsecase>()
                  .call(update.Params(kycDataModel: kycData));
              if (updateKycResponse.error != null) {
                final errorData = updateKycResponse.error?.response?.data;
                errorMessage =
                    errorData?['message'] ??
                    'Something went wrong during the KYC update!';
              } else {
                sl<AnalyticsService>().trackEvent(
                  "partnerVerificationSuccess",
                  eventProperties: {
                    "verifiedName": kycData.accountName,
                    "pan": kycData.panNumber,
                    "accountNumber": kycData.accountNumber,
                    "ifsc": kycData.ifsc,
                    "transactionId": transactionId,
                    "panImage": kycData.panImageFilename,
                  },
                );
                await Get.find<UserController>().fetchData();
                HapticFeedback.vibrate();
                Get.to(() => const VerificationResultScreen(isVerified: true));
                AlertService.showSnackBar(
                  snackBarType: SnackBarType.Success,
                  title: 'Success',
                  subtitle: 'KYC process completed successfully.',
                );
                return;
              }
            } else {
              errorMessage = 'PAN file name not found. Please try again.';
            }
          } else {
            errorMessage = 'Failed to retrieve KYC data. Please try again.';
          }
        }
      } catch (e) {
        _logResult('Error during KYC update: $e');
        errorMessage = 'KYC update failed. Please try again later.';
      } finally {
        Get.context?.loaderOverlay.hide();
      }
    }

    // Mark KYC as failed and track analytics
    if (transactionId.isNotEmpty) {
      await _markKYCFailed(transactionId: transactionId, reason: errorMessage);
    }

    sl<AnalyticsService>().trackEvent(
      "partnerVerificationFailed",
      eventProperties: {
        "reason": errorMessage,
        "transactionId": transactionId,
        "needsReview": errorMessage == needsReviewMessage,
        if (errorDetail != null) "errorDetail": errorDetail,
      },
    );
    _clearTransactionIdCache();
    HapticFeedback.vibrate();
    Get.to(() => const VerificationResultScreen(isVerified: false));
    AlertService.showSnackBar(
      snackBarType: SnackBarType.Error,
      title: 'Error',
      subtitle: errorMessage,
    );
    _logResult('Error during KYC update: $errorMessage');
  }

  static Future<KYCStatus?> checkKYCStatus({required String phone}) async {
    String errorMessage = "";
    String? transactionId;
    try {
      // Get transaction ID (might be cached from previous launch)
      transactionId = await _getTransactionId(
        phoneNumber: phone,
        type: KycTransactionType.FULL_KYC,
      );
      if (transactionId == null) {
        Logger.logMessage('No transaction ID available for KYC status check');
        return null;
      }
      final hyperVergeResult = await sl<GetKYCOutputUsecase>().call(
        GetKYCOutputParams(transactionId: transactionId),
      );
      _logResult(
        "GetKYCOutputUsecase Response: ${hyperVergeResult.data?.toJson().toString() ?? "NULL"}",
      );
      if (hyperVergeResult.data != null) {
        final kycStatus = hyperVergeResult.data?.kycStatus;
        if (kycStatus == KYCStatus.approved) {
          final kycData = hyperVergeResult.data?.kycDataModel;
          _logResult("KYC DATA: ${kycData.toString()}");
          if (kycData != null) {
            final panImageFileName = await _getKYCFileName(
              fileName: kycData.panImageUrl,
            );
            if (panImageFileName?.isNotEmpty ?? false) {
              kycData.updatePanImageFilename(panImageFileName!);
              final updateKycResponse = await sl<update.UpdateKYCUsecase>()
                  .call(update.Params(kycDataModel: kycData));

              if (updateKycResponse.error != null) {
                final errorData = updateKycResponse.error?.response?.data;
                errorMessage =
                    errorData?['message'] ??
                    'Something went wrong during the KYC update!';
              } else {
                sl<AnalyticsService>().trackEvent(
                  "partnerVerificationSuccess",
                  eventProperties: {
                    "verifiedName": kycData.accountName,
                    "pan": kycData.panNumber,
                    "accountNumber": kycData.accountNumber,
                    "ifsc": kycData.ifsc,
                    "transactionId": transactionId,
                    "panImage": kycData.panImageFilename,
                    "hypervergeStatus": hyperVergeResult.data?.status,
                  },
                );
                // KYC success - clear cache
                _clearTransactionIdCache();
                await Get.find<UserController>().fetchData();
                return KYCStatus.approved;
              }
            } else {
              errorMessage = 'PAN file name not found. Please try again.';
            }
          }
          sl<AnalyticsService>().trackEvent(
            "partnerVerificationFailed",
            eventProperties: {
              "reason": errorMessage,
              "transactionId": transactionId,
              "needsReview": errorMessage == needsReviewMessage,
            },
          );
          HapticFeedback.vibrate();
          Get.to(() => const VerificationResultScreen(isVerified: false));
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Error,
            title: 'Error',
            subtitle: errorMessage,
          );
          _logResult('Error during KYC update: $errorMessage');
        } else if (kycStatus == KYCStatus.needsReview) {
          return KYCStatus.needsReview;
        } else {
          errorMessage = 'Failed to retrieve KYC data. Please try again.';
        }
      } else {
        errorMessage = 'Failed to retrieve KYC data. Please try again.';
      }
    } catch (e) {
      _logResult('Error during KYC update: $e');
      errorMessage = 'KYC update failed. Please try again later.';
    }

    // Mark KYC as failed for any error case
    if (transactionId != null) {
      await _markKYCFailed(transactionId: transactionId, reason: errorMessage);
    }

    return null;
  }

  static Future<void> launchAadharSign({required String phone}) async {
    String? transactionId;
    String? errorDetail;
    try {
      await _checkEsignVideoSeen();
      // Generate unique transaction ID
      transactionId = await _getTransactionId(
        phoneNumber: phone,
        type: KycTransactionType.ESIGN,
      );
      if (transactionId == null) {
        throw Exception('Failed to generate transaction ID');
      }

      final workflowId = StringConstants.hypervergeESignWorkflowId;
      if (transactionId.isNotEmpty && transactionId != "null") {
        final hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
          appId: StringConstants.hypervergeAppId,
          appKey: StringConstants.hypervergeAppKey,
          workflowId: workflowId,
          transactionId: transactionId,
        );

        final userController = Get.find<UserController>();
        final user = userController.userDetails.value.user;
        var name = user?.name ?? "";
        final onboardingDetails = await userController.getOnboardingDetails();

        if (onboardingDetails != null) {
          if (name.isNotEmpty) {
            name = onboardingDetails.name ?? '';
          }
        }

        // Fetch current location
        final locationService = sl<LocationService>();
        final latLong = await locationService.fetchLatLong();
        final place = latLong.isNotEmpty ? latLong : "-";

        final inputs = {
          "inviteeName": name,
          "inviteePhone": user?.phoneNumber ?? phone,
          "userName": name,
          "id": user?.phoneNumber ?? phone,
          "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
          "place": place,
        };

        hyperKycConfig.setInputs(inputs: inputs);

        _logResult(
          "STARTING HYPERVERGE===== TID:$transactionId, INPUTS: $inputs",
        );
        sl<AnalyticsService>().trackEvent(
          "partnerEsignInitiated",
          eventProperties: {"transactionId": transactionId},
        );
        HyperKycResult result = await HyperKyc.launch(
          hyperKycConfig: hyperKycConfig,
        );

        _logResult(result.getRawDataJsonString() ?? "NULL");
        _logResult(result.details.toString());
        _logResult("HyperKycResult Response: ${result.toMap().toString()}");

        String? status = result.status?.value;
        bool isSuccess = false;
        String message;
        errorDetail = result.errorMessage;
        switch (status) {
          case 'auto_approved':
            isSuccess = true;
            message = 'Your KYC has been successfully auto-approved.';
            break;
          case 'auto_declined':
            message = 'Unfortunately, your KYC has been auto-declined.';
            final gender = checkGender(result);
            if (gender == Gender.Male) {
              message =
                  'Unfortunately, your KYC has been auto-declined. Please use female aadhar for KYC process.';
            }
            break;
          case 'needs_review':
            message = needsReviewMessage;
            break;
          case 'error':
            message =
                'An error occurred during the KYC process. Please try again later.';
            break;
          case 'user_cancelled':
            message = 'You have cancelled the KYC process.';
            break;
          default:
            message =
                'An unknown error occurred. Please contact support for more details.';
        }

        _logResult(message);
        await _processESignResult(
          message: message,
          isSuccess: isSuccess,
          transactionId: transactionId,
          phone: phone,
        );
      }
    } catch (e) {
      _logResult('An unexpected error occurred: $e');

      // Mark KYC as failed if we have a transaction ID
      if (transactionId != null) {
        await _markKYCFailed(
          transactionId: transactionId,
          reason: 'Unexpected error: $e',
        );
      }

      await _processESignResult(
        phone: phone,
        message: 'An unexpected error occurred. Please try again later.',
        isSuccess: false,
        transactionId: transactionId ?? '',
        errorDetail: errorDetail,
      );
    }
  }

  static Gender? checkGender(HyperKycResult result) {
    final gender = result.details?['gender'] as String?;
    if (gender?.isNotEmpty ?? false) {
      if (gender == 'M') {
        return Gender.Male;
      } else if (gender == 'F') {
        return Gender.Female;
      }
    }
    return null;
  }

  static Future<void> _processESignResult({
    required String phone,
    required String transactionId,
    required String message,
    bool isSuccess = false,
    String? errorDetail,
  }) async {
    String errorMessage = message;
    if (isSuccess) {
      try {
        Get.context?.loaderOverlay.show();
        final hyperVergeResult = await sl<GetESignOutputUsecase>().call(
          GetESignOutputParams(transactionId: transactionId),
        );
        _logResult(
          "GetKYCOutputUsecase Response: ${hyperVergeResult.data?.toString() ?? "NULL"}",
        );
        if (hyperVergeResult.data != null) {
          final kycData = hyperVergeResult.data?.result?.userDetails;
          _logResult("KYC DATA: ${kycData.toString()}");
          if (kycData != null) {
            if (kycData.documentUrl?.isNotEmpty ?? false) {
              final udpateEsignResponse = await sl<UpdateESignUsecase>().call(
                UpdateESignParams(
                  transactionId: transactionId,
                  signedDocumentPath: kycData.documentUrl ?? '',
                  maskedAadhar: kycData.aadhaarNumber ?? '',
                  name: kycData.name ?? '',
                  ifsc: kycData.ifsc ?? '',
                  accountNumber: kycData.accountNumber ?? '',
                  type:
                      kycData.upiAccountExists == 'true' &&
                              kycData.upi?.isNotEmpty == true
                          ? EsignType.VPA
                          : EsignType.BANK,
                  upi: kycData.upi ?? '',
                ),
              );
              if (udpateEsignResponse.error != null) {
                final errorData = udpateEsignResponse.error?.response?.data;
                errorMessage =
                    errorData?['message'] ??
                    'Something went wrong during the E-Sign update!';
              } else {
                sl<AnalyticsService>().trackEvent(
                  "partnerESignSuccess",
                  eventProperties: {
                    "verifiedName": kycData.name ?? '',
                    "maskedAadhar": kycData.aadhaarNumber ?? '',
                    "signedDocumentPath": kycData.documentUrl ?? '',
                    "transactionId": transactionId,
                    "hypervergeStatus": hyperVergeResult.data?.status,
                    "ifsc": kycData.ifsc,
                    "accountNumber": kycData.accountNumber,
                  },
                );
                await Get.find<UserController>().fetchData();
                HapticFeedback.vibrate();
                Get.back();
                AlertService.showSnackBar(
                  snackBarType: SnackBarType.Success,
                  title: 'Success',
                  subtitle: 'E-Sign process completed successfully.',
                );
                return;
              }
            } else {
              errorMessage = 'PAN file name not found. Please try again.';
            }
          } else {
            errorMessage = 'Failed to retrieve KYC data. Please try again.';
          }
        }
      } catch (e) {
        _logResult('Error during E-Sign update: $e');
        errorMessage = 'E-Sign update failed. Please try again later.';
      } finally {
        Get.context?.loaderOverlay.hide();
      }
    }

    // Mark KYC as failed and track analytics
    if (transactionId.isNotEmpty) {
      await _markKYCFailed(transactionId: transactionId, reason: errorMessage);
    }

    sl<AnalyticsService>().trackEvent(
      "partnerESignFailed",
      eventProperties: {
        "reason": errorMessage,
        "transactionId": transactionId,
        "needsReview": errorMessage == needsReviewMessage,
        if (errorDetail != null) "errorDetail": errorDetail,
      },
    );
    _clearTransactionIdCache();
    HapticFeedback.vibrate();
    Get.back();
    AlertService.showSnackBar(
      snackBarType: SnackBarType.Error,
      title: 'Error',
      subtitle: errorMessage,
    );
    _logResult('Error during E-Sign update: $errorMessage');
  }

  static Future<String?> _getKYCFileName({required String fileName}) async {
    try {
      final fileUrl = await Get.find<UserController>().getFileUrlByName(
        fileName: fileName,
      );
      if (fileUrl == null) {
        return null;
      }
      Directory dir = await getApplicationDocumentsDirectory();
      String fileExtension = "jpeg"; // Default to JPEG

      // Detect the correct extension from the URL
      if (fileUrl.contains(".png")) {
        fileExtension = "png";
      } else if (fileUrl.contains(".jpg") || fileUrl.contains(".jpeg")) {
        fileExtension = "jpeg";
      } else if (fileUrl.contains(".webp")) {
        fileExtension = "webp";
      } else {
        // Fetch the content type from headers (useful when the extension is missing)
        final response = await Dio().head(fileUrl);
        String? contentType = response.headers.value("content-type");
        if (contentType != null) {
          if (contentType.contains("png")) {
            fileExtension = "png";
          } else if (contentType.contains("jpeg")) {
            fileExtension = "jpeg";
          } else if (contentType.contains("webp")) {
            fileExtension = "webp";
          }
        }
      }

      // Generate a unique filename with the correct extension
      String randomFileName = "image_${const Uuid().v4()}.$fileExtension";
      String filePath = "${dir.path}/$randomFileName";

      // Download the file
      Dio dio = Dio();
      await dio.download(fileUrl, filePath);
      final file = File(filePath);
      final response = await sl<upload.UploadKYCFileUsecase>().call(
        upload.Params(
          file: file,
          extension: extension(file.path).replaceFirst(".", ""),
        ),
      );
      if (response.data != null) {
        return response.data?.file;
      } else {
        return null;
      }
    } catch (e) {
      _logResult('Error downloading or uploading PAN file: $e');
      return null;
    }
  }

  static Future<void> _checkEsignVideoSeen() async {
    final isSeen = await _hasSeenAadharSign();
    if (!isSeen) {
      final videoUrl = URLConstants.aadharEsignVideo.trim();
      if (videoUrl.isNotEmpty) {
        await Get.to(() => VideoPlayerScreen(videoUrl: videoUrl));
        await _setAadharSignSeen();
      }
    }
  }

  static Future<bool> _hasSeenAadharSign() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hyperverge_aadhar_sign_seen') ?? false;
  }

  static Future<void> _setAadharSignSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hyperverge_aadhar_sign_seen', true);
  }
}
