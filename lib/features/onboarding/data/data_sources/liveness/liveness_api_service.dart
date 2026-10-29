import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/api_constants.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/liveness/check_liveness_hyperverge_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/liveness/check_liveness_idto_response.dart';

part 'liveness_api_service.g.dart';

@RestApi()
abstract class LivenessApiService {
  factory LivenessApiService(Dio dio) = _LivenessApiService;

  @POST(APIConstants.checkLivenessHypervergeRoute)
  @MultiPart()
  Future<HttpResponse<CheckLivenessHypervergeResponse>>
  checkLivenessHyperverge({@Part(name: 'image') required File image});

  @POST(APIConstants.checkLivenessIdtoRoute)
  Future<HttpResponse<CheckLivenessIdtoResponse>> checkLivenessIdto({
    @Field('image_base64') required String imageBase64,
  });
}
