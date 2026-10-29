import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';
import 'package:voiceclub_partner/domain/repository/ui_localization_repository.dart';

class GetUiLanguagesUseCase implements UseCase<List<UiLanguage>, NoParams> {
  GetUiLanguagesUseCase(this._repository);

  final UiLocalizationRepository _repository;

  @override
  Future<List<UiLanguage>> call(NoParams params) {
    return _repository.getLanguages();
  }
}
