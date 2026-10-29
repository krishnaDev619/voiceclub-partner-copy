import 'dart:io';

import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/liveness/check_liveness_hyperverge_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/liveness/check_liveness_idto_response.dart';

abstract class LivenessRepository {
  Future<DataState<CheckLivenessHypervergeResponse>> checkLivenessHyperverge({
    required File image,
  });

  Future<DataState<CheckLivenessIdtoResponse>> checkLivenessIdto({
    required String imageBase64,
  });
}
