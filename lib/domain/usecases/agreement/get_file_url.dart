import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/kyc_file/get_file_url.dart';
import 'package:voiceclub_partner/domain/repository/agreement_repository.dart';

class GetFileUrlUseCase
    implements UseCase<DataState<GetFileUrlResponseModel>, GetFileUrlParams> {
  final AgreementRepository _agreementRepository;

  GetFileUrlUseCase(this._agreementRepository);

  @override
  Future<DataState<GetFileUrlResponseModel>> call(GetFileUrlParams params) {
    return _agreementRepository.getFileUrl(fileName: params.fileName);
  }
}

class GetFileUrlParams extends Equatable {
  final String fileName;

  const GetFileUrlParams({required this.fileName});

  @override
  List<Object> get props => [fileName];
}
