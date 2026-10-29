import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/liveness/check_liveness_hyperverge_response.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/liveness_repository.dart';

class CheckLivenessHypervergeUseCase
    implements
        UseCase<
          DataState<CheckLivenessHypervergeResponse>,
          CheckLivenessHypervergeParams
        > {
  final LivenessRepository _livenessRepository;

  CheckLivenessHypervergeUseCase(this._livenessRepository);

  @override
  Future<DataState<CheckLivenessHypervergeResponse>> call(
    CheckLivenessHypervergeParams params,
  ) {
    return _livenessRepository.checkLivenessHyperverge(image: params.image);
  }
}

class CheckLivenessHypervergeParams extends Equatable {
  final File image;

  const CheckLivenessHypervergeParams({required this.image});

  @override
  List<Object> get props => [image];
}
