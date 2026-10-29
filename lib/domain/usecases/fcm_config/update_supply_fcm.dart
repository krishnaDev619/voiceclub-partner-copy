import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/fcm_config_repository.dart';

class UpdateSupplyFCMUsecase implements UseCase<DataState<void>, Params> {
  final FCMConfigRepository _fcmConfigRepository;
  UpdateSupplyFCMUsecase(this._fcmConfigRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _fcmConfigRepository.updateSupplyFCM(
      token: params.token,
      version: params.version,
      buildNumber: params.buildNumber,
    );
  }
}

class Params extends Equatable {
  final String token;
  final String? version;
  final int? buildNumber;

  const Params({required this.token, this.version, this.buildNumber});

  @override
  List<Object> get props => [token];
}
