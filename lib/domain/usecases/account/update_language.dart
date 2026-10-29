import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateLanguageUseCase implements UseCase<DataState<void>, Params> {
  final AccountRepository _supplyAccountRepository;
  UpdateLanguageUseCase(this._supplyAccountRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _supplyAccountRepository.updateLanguage(
      firstLanguage: params.firstLanguage,
      secondLanguage: params.secondLanguage,
    );
  }
}

class Params extends Equatable {
  final String firstLanguage;
  final String secondLanguage;

  const Params({required this.firstLanguage, required this.secondLanguage});

  @override
  List<Object> get props => [firstLanguage, secondLanguage];
}
