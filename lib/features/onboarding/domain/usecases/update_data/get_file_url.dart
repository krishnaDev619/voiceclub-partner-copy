import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/get_file_url_response.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/update_data_repository.dart';

class GetFileUrlUseCase
    implements UseCase<DataState<GetFileUrlResponseModel>, GetFileUrlParams> {
  final UpdateDataRepository _updateDataRepository;

  GetFileUrlUseCase(this._updateDataRepository);

  @override
  Future<DataState<GetFileUrlResponseModel>> call(GetFileUrlParams params) {
    return _updateDataRepository.getFileUrl(fileName: params.fileName);
  }
}

class GetFileUrlParams extends Equatable {
  final String fileName;

  const GetFileUrlParams({required this.fileName});

  @override
  List<Object> get props => [fileName];
}
