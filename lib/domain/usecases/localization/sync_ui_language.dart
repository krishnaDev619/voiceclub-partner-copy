import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/localization/synced_arb.dart';
import 'package:voiceclub_partner/domain/repository/ui_localization_repository.dart';

class SyncUiLanguageUseCase
    implements UseCase<SyncedArb, SyncUiLanguageParams> {
  SyncUiLanguageUseCase(this._repository);

  final UiLocalizationRepository _repository;

  @override
  Future<SyncedArb> call(SyncUiLanguageParams params) {
    return _repository.syncLanguage(params.languageCode);
  }
}

class SyncUiLanguageParams {
  const SyncUiLanguageParams({required this.languageCode});

  final String languageCode;
}
