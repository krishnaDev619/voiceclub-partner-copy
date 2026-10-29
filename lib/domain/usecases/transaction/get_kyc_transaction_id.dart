import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/hyperverge/get_kyc_transaction_id_response.dart';
import 'package:voiceclub_partner/domain/repository/kyc_transaction_repository.dart';

class GetKycTransactionIdUseCase
    implements
        UseCase<
          DataState<GetKycTransactionIdResponseModel>,
          GetKYCTransactionIdParams
        > {
  final KycTransactionRepository _transactionRepository;

  GetKycTransactionIdUseCase(this._transactionRepository);

  @override
  Future<DataState<GetKycTransactionIdResponseModel>> call(
    GetKYCTransactionIdParams params,
  ) {
    return _transactionRepository.getKycTransactionId(type: params.type.name);
  }
}

class GetKYCTransactionIdParams extends Equatable {
  final KycTransactionType type;

  const GetKYCTransactionIdParams({required this.type});

  @override
  List<Object?> get props => [type];
}
