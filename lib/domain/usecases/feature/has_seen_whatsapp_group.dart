import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/feature_repository.dart';

class HasSeenWhatsAppGroupUseCase
    implements UseCase<bool, HasSeenWhatsAppGroupParams> {
  final FeatureRepository _featureRepository;

  HasSeenWhatsAppGroupUseCase(this._featureRepository);

  @override
  Future<bool> call(HasSeenWhatsAppGroupParams params) {
    return _featureRepository.hasSeenWhatsAppGroup(accountId: params.accountId);
  }
}

class HasSeenWhatsAppGroupParams extends Equatable {
  final String accountId;

  const HasSeenWhatsAppGroupParams({required this.accountId});

  @override
  List<Object> get props => [accountId];
}
