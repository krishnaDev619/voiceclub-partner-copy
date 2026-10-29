import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/base_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateESignUsecase
    implements UseCase<DataState<BaseResponseModel>, UpdateESignParams> {
  final AccountRepository _accountRepository;

  UpdateESignUsecase(this._accountRepository);

  @override
  Future<DataState<BaseResponseModel>> call(UpdateESignParams params) {
    return _accountRepository.updateESign(
      name: params.name,
      maskedAadhar: params.maskedAadhar,
      signedDocumentPath: params.signedDocumentPath,
      transactionId: params.transactionId,
      ifsc: params.ifsc,
      accountNumber: params.accountNumber,
      type: params.type.name,
      upi: params.upi,
    );
  }
}

class UpdateESignParams extends Equatable {
  final String transactionId;
  final String signedDocumentPath;
  final String maskedAadhar;
  final String name;
  final String ifsc;
  final String accountNumber;
  final EsignType type;
  final String upi;

  const UpdateESignParams({
    required this.transactionId,
    required this.signedDocumentPath,
    required this.maskedAadhar,
    required this.name,
    required this.ifsc,
    required this.accountNumber,
    required this.type,
    required this.upi,
  });

  @override
  List<Object> get props => [transactionId];
}
