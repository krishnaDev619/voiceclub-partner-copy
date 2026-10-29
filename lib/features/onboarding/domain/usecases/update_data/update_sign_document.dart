import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/update_data_repository.dart';

class UpdateSignDocument
    implements UseCase<DataState, UpdateSignDocumentParams> {
  final UpdateDataRepository _updateDataRepository;

  UpdateSignDocument(this._updateDataRepository);

  @override
  Future<DataState> call(UpdateSignDocumentParams params) {
    return _updateDataRepository.updateSignDocument(
      documentPath: params.documentPath,
      phoneNumber: params.phoneNumber,
    );
  }
}

class UpdateSignDocumentParams extends Equatable {
  final String documentPath;
  final String phoneNumber;

  const UpdateSignDocumentParams({
    required this.documentPath,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [phoneNumber, documentPath];
}
