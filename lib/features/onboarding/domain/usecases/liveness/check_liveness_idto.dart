import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/liveness/check_liveness_idto_response.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/liveness_repository.dart';

class CheckLivenessIdtoUseCase
    implements
        UseCase<DataState<CheckLivenessIdtoResponse>, CheckLivenessIdtoParams> {
  final LivenessRepository _livenessRepository;

  CheckLivenessIdtoUseCase(this._livenessRepository);

  @override
  Future<DataState<CheckLivenessIdtoResponse>> call(
    CheckLivenessIdtoParams params,
  ) {
    final imageBase64 = base64Encode(params.image.readAsBytesSync());
    return _livenessRepository.checkLivenessIdto(imageBase64: imageBase64);
  }
}

class CheckLivenessIdtoParams extends Equatable {
  final File image;

  const CheckLivenessIdtoParams({required this.image});

  @override
  List<Object> get props => [image];
}
