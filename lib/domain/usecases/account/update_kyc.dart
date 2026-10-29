import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/hyperverge/kyc_data_model.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateKYCUsecase implements UseCase<DataState<void>, Params> {
  final AccountRepository _accountRepository;

  UpdateKYCUsecase(this._accountRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _accountRepository.updateKYC(
      name: params.kycDataModel.accountName,
      panImagePath: params.kycDataModel.panImageFilename ?? "",
      selfieImagePath: "",
      panNumber: params.kycDataModel.panNumber,
      ifsc: params.kycDataModel.ifsc,
      accountNumber: params.kycDataModel.accountNumber,
      isVerified: true,
    );
  }
}

class Params extends Equatable {
  final KYCDataModel kycDataModel;

  const Params({required this.kycDataModel});

  @override
  List<Object> get props => [kycDataModel];
}
