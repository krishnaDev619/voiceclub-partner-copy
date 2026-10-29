import 'package:voiceclub_partner/core/constants/string_constants.dart';

class APIConstants {
  APIConstants._();
  // ==========================================
  // Base URL
  // ==========================================
  static String get baseProdURL => StringConstants.baseProdURL;
  static const String verifyGenderBaseURL =
      "https://3ky4pw7g2jucbv6xatw2zodipa0espcx.lambda-url.ap-south-1.on.aws";

  // ==========================================
  // Demand API Routes
  // ==========================================

  // auth
  static const String registerRoute = "/onboarding/register";
  static const String verifyOTPRoute = "/onboarding/otp/verify";
  static const String profileRoute = "/onboarding/profile";

  // Verify Gender
  static const String verifyGenderRoute = "/";

  // Update Data
  static const String updateDataRoute = "/onboarding/update";
  static const String updateSignDocumentRoute = "/onboarding/sign_document";
  static const String uploadOnboardingFileRoute =
      "/onboarding/upload/{extension}";
  static const String uploadOnboardingFileOnWebRoute = "/onboarding/upload/";
  static const String getFileUrlRoute = "/onboarding/file/{filename}";
  static const String completeOnboardingRoute = "/onboarding/profile/complete";

  // Liveness
  static const String checkLivenessHypervergeRoute =
      "/onboarding/hyper_verge/validation/selfie";
  static const String checkLivenessIdtoRoute = "/onboarding/idto/liveness";
}
