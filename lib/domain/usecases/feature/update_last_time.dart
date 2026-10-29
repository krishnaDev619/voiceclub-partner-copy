import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/feature_repository.dart';

class UpdateLastSeenTimeUseCase implements UseCase<void, UpdateLastSeenParams> {
  final FeatureRepository _featureRepository;

  UpdateLastSeenTimeUseCase(this._featureRepository);

  @override
  Future<void> call(UpdateLastSeenParams params) {
    return _featureRepository.updateLastSeenTime(accountId: params.accountId);
  }
}

class UpdateLastSeenParams extends Equatable {
  final String accountId;

  const UpdateLastSeenParams({required this.accountId});

  @override
  List<Object> get props => [accountId];
}
