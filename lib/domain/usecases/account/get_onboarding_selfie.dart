import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetOnboardingSelfieUsecase
    implements UseCase<DataState<FileResponseModel>, NoParams> {
  final AccountRepository _supplyAccountRepository;
  GetOnboardingSelfieUsecase(this._supplyAccountRepository);

  @override
  Future<DataState<FileResponseModel>> call(NoParams params) {
    return _supplyAccountRepository.getOnboardingSelfie();
  }
}
