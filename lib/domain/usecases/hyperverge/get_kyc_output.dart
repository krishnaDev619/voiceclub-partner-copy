import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_output_api_response.dart';
import 'package:voiceclub_partner/domain/repository/hyperverge_repository.dart';

class GetKYCOutputUsecase
    implements
        UseCase<
          DataState<HypervergeOutputAPIResponseModel>,
          GetKYCOutputParams
        > {
  final HypervergeRepository _hypervergeRepository;
  GetKYCOutputUsecase(this._hypervergeRepository);

  @override
  Future<DataState<HypervergeOutputAPIResponseModel>> call(
    GetKYCOutputParams params,
  ) {
    return _hypervergeRepository.getKYCOutput(
      transactionId: params.transactionId,
    );
  }
}

class GetKYCOutputParams extends Equatable {
  final String transactionId;
  const GetKYCOutputParams({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
