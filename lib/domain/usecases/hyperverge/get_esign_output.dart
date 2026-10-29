import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_esign_output.dart';
import 'package:voiceclub_partner/domain/repository/hyperverge_repository.dart';

class GetESignOutputUsecase
    implements
        UseCase<
          DataState<HypervergeEsignOutputResponse>,
          GetESignOutputParams
        > {
  final HypervergeRepository _hypervergeRepository;
  GetESignOutputUsecase(this._hypervergeRepository);

  @override
  Future<DataState<HypervergeEsignOutputResponse>> call(
    GetESignOutputParams params,
  ) {
    return _hypervergeRepository.getESignOutput(
      transactionId: params.transactionId,
    );
  }
}

class GetESignOutputParams extends Equatable {
  final String transactionId;
  const GetESignOutputParams({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
