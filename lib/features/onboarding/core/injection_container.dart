import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';
import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:voiceclub_partner/core/injection_container.dart' as partner_di;
import 'package:voiceclub_partner/core/services/app_preferences.dart';
import 'package:voiceclub_partner/core/services/token_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/api_constants.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/services/logging_interceptor.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/app_language_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/local_data_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/video_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/auth/auth_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/liveness/liveness_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/update_data/update_data_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/upload_file/upload_file_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/verify_gender/verify_gender_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/repository/auth_repository_impl.dart';
import 'package:voiceclub_partner/features/onboarding/data/repository/liveness_repository_impl.dart';
import 'package:voiceclub_partner/features/onboarding/data/repository/update_data_repository_impl.dart';
import 'package:voiceclub_partner/features/onboarding/data/repository/upload_file_repository_impl.dart';
import 'package:voiceclub_partner/features/onboarding/data/repository/verify_gender_repository_impl.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/auth_repository.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/liveness_repository.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/update_data_repository.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/upload_file_repository.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/verify_gender_repository.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/auth/get_profile.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/auth/register.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/auth/verify_otp.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/liveness/check_liveness_hyperverge.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/liveness/check_liveness_idto.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/complete_onboarding.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/get_file_url.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/update_data.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/update_profile_status.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/update_sign_document.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/upload_file/upload_onboarding_file.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/verify_gender/verify_gender_use_case.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final verifyGenderDio = Dio(
    BaseOptions(baseUrl: APIConstants.verifyGenderBaseURL),
  );

  final tokenService = partner_di.sl<TokenService>();
  final appPreferences = partner_di.sl<AppPreferences>();

  tokenService.registerDio(sl<Dio>());
  tokenService.registerDio(verifyGenderDio);

  // ==========================================
  // Services
  // ==========================================
  sl.registerSingleton<LocalDataService>(
    LocalDataService(appPreferences, tokenService),
  );
  sl.registerSingleton<VideoService>(VideoService(appPreferences));
  sl.registerSingleton<AnalyticsService>(
    AnalyticsService(
      mixpanel: await Mixpanel.init(
        StringConstants.mixpanelToken,
        trackAutomaticEvents: true,
      ),
      firebaseAnalytics: FirebaseAnalytics.instance,
    ),
  );
  sl.registerSingleton<AppLanguageService>(AppLanguageService(appPreferences));
  sl.registerSingleton<GrowthBookService>(
    GrowthBookService(
      await GBSDKBuilderApp(
        hostURL: StringConstants.growthBookHostURL,
        apiKey: StringConstants.growthBookAPIKey,
        backgroundSync: true,
        growthBookTrackingCallBack: (gbExperiment) {},
      ).initialize(),
    ),
  );

  // ==========================================
  // APIs
  // ==========================================

  sl.registerSingleton<VerifyGenderApiService>(
    VerifyGenderApiService(verifyGenderDio),
  );

  sl.registerSingleton<UploadFileApiService>(UploadFileApiService(sl()));
  sl.registerSingleton<AuthApiService>(AuthApiService(sl()));
  sl.registerSingleton<UpdateDataApiService>(UpdateDataApiService(sl()));
  sl.registerSingleton<LivenessApiService>(LivenessApiService(sl()));

  // ==========================================
  // Repositories
  // ==========================================

  sl.registerSingleton<VerifyGenderRepository>(
    VerifyGenderRepositoryImpl(sl()),
  );
  sl.registerSingleton<UploadFileRepository>(UploadFileRepositoryImpl(sl()));
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerSingleton<UpdateDataRepository>(UpdateDataRepositoryImpl(sl()));
  sl.registerSingleton<LivenessRepository>(LivenessRepositoryImpl(sl()));

  // ==========================================
  // UseCases
  // ==========================================

  // Auth
  sl.registerSingleton<RegisterUsecase>(RegisterUsecase(sl()));
  sl.registerSingleton<VerifyOTPUseCase>(VerifyOTPUseCase(sl()));
  sl.registerSingleton<GetProfileUseCase>(GetProfileUseCase(sl()));

  // Update Data
  sl.registerSingleton<UpdateDataUseCase>(UpdateDataUseCase(sl()));
  sl.registerSingleton<UpdateSignDocument>(UpdateSignDocument(sl()));
  sl.registerSingleton<GetFileUrlUseCase>(GetFileUrlUseCase(sl()));
  sl.registerSingleton<UpdateProfileStatusUseCase>(
    UpdateProfileStatusUseCase(sl()),
  );
  sl.registerSingleton<CompleteOnboardingUseCase>(
    CompleteOnboardingUseCase(sl()),
  );
  // Verify Gender
  sl.registerSingleton<VerifyGenderUseCase>(VerifyGenderUseCase(sl()));

  // Upload File
  sl.registerSingleton<UploadOnboardingFileUsecase>(
    UploadOnboardingFileUsecase(sl()),
  );

  // Liveness
  sl.registerSingleton<CheckLivenessHypervergeUseCase>(
    CheckLivenessHypervergeUseCase(sl()),
  );
  sl.registerSingleton<CheckLivenessIdtoUseCase>(
    CheckLivenessIdtoUseCase(sl()),
  );

  // ==========================================
  // Interceptors
  // ==========================================

  verifyGenderDio.interceptors.add(LoggingInterceptor());
}
