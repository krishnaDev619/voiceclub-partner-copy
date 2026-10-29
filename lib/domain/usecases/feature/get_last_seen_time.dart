import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/feature_repository.dart';

class GetLastSeenTimeUseCase implements UseCase<DateTime?, Params> {
  final FeatureRepository _featureRepository;

  GetLastSeenTimeUseCase(this._featureRepository);

  @override
  Future<DateTime?> call(Params params) {
    return _featureRepository.getLastSeenTime(accountId: params.accountId);
  }
}

class Params extends Equatable {
  final String accountId;

  const Params({required this.accountId});

  @override
  List<Object> get props => [accountId];
}
