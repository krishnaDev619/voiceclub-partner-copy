import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/feature_repository.dart';

class MarkWhatsAppGroupAsSeenUseCase
    implements UseCase<void, MarkWhatsAppGroupAsSeenParams> {
  final FeatureRepository _featureRepository;

  MarkWhatsAppGroupAsSeenUseCase(this._featureRepository);

  @override
  Future<void> call(MarkWhatsAppGroupAsSeenParams params) {
    return _featureRepository.markWhatsAppGroupAsSeen(
      accountId: params.accountId,
    );
  }
}

class MarkWhatsAppGroupAsSeenParams extends Equatable {
  final String accountId;

  const MarkWhatsAppGroupAsSeenParams({required this.accountId});

  @override
  List<Object> get props => [accountId];
}
