import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/agreement_repository.dart';

class UpdateSignDocument implements UseCase<DataState, Params> {
  final AgreementRepository _agreementRepository;

  UpdateSignDocument(this._agreementRepository);

  @override
  Future<DataState> call(Params params) {
    return _agreementRepository.updateSignDocument(
      documentPath: params.documentPath,
      phoneNumber: params.phoneNumber,
    );
  }
}

class Params extends Equatable {
  final String documentPath;
  final String phoneNumber;

  const Params({required this.documentPath, required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber, documentPath];
}
