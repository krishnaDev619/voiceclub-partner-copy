import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/core/services/logging_interceptor.dart';
import 'package:voiceclub_partner/data/data_sources/remote/ringing/ringing_api_service.dart';
import 'package:voiceclub_partner/data/repository/ringing_repository_impl.dart';
import 'package:voiceclub_partner/domain/repository/ringing_repository.dart';
import 'package:voiceclub_partner/domain/usecases/ringing/set_ring_isolate.dart';

final isolate = GetIt.asNewInstance();

Future<void> initializeIsolateDependencies() async {
  final baseDio = Dio(BaseOptions(baseUrl: APIConstants.baseProdURL));
  // Dio
  isolate.registerSingleton<Dio>(baseDio);
  baseDio.interceptors.add(IsolateLoggingInterceptor());

  // ==========================================
  // Services
  // ==========================================
  isolate.registerSingleton<IsolateAuthService>(IsolateAuthService(isolate()));

  // ==========================================
  // APIs
  // ==========================================
  isolate.registerSingleton<RingingApiService>(RingingApiService(isolate()));

  // ==========================================
  // Repostiories
  // ==========================================
  isolate.registerSingleton<RingingRepository>(
    RingingRepositoryImpl(isolate()),
  );

  // ==========================================
  // UseCases
  // ==========================================
  isolate.registerSingleton<SetRingIsolateUsecase>(
    SetRingIsolateUsecase(isolate()),
  );
}
