import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/verify_gender_response_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/verify_gender_repository.dart';

class VerifyGenderUseCase
    implements
        UseCase<DataState<VerifyGenderResponseModel>, VerifyGenderParams> {
  final VerifyGenderRepository _verifyGenderRepository;

  VerifyGenderUseCase(this._verifyGenderRepository);

  @override
  Future<DataState<VerifyGenderResponseModel>> call(VerifyGenderParams params) {
    return _verifyGenderRepository.verifyGender(s3Object: params.s3Object);
  }
}

class VerifyGenderParams extends Equatable {
  final Map<String, dynamic> s3Object;

  const VerifyGenderParams({required this.s3Object});

  @override
  List<Object> get props => [s3Object];
}
