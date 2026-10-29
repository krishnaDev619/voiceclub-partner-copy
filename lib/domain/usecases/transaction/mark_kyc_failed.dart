import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/kyc_transaction_repository.dart';

class MarkKycFailedUseCase
    implements UseCase<DataState<void>, MarkKycFailedParams> {
  final KycTransactionRepository _transactionRepository;

  MarkKycFailedUseCase(this._transactionRepository);

  @override
  Future<DataState<void>> call(MarkKycFailedParams params) {
    return _transactionRepository.markKYCFailed(
      transactionId: params.transactionId,
    );
  }
}

class MarkKycFailedParams extends Equatable {
  final String transactionId;

  const MarkKycFailedParams({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
