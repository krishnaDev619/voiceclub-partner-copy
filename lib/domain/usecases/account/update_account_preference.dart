import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateAccountPreferenceUsecase
    implements UseCase<DataState<void>, Params> {
  final AccountRepository _accountRepository;
  UpdateAccountPreferenceUsecase(this._accountRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _accountRepository.updateAccountPreference(
      callPreference: params.callPreference,
      chatPreference: params.chatPreference,
    );
  }
}

class Params extends Equatable {
  final String callPreference;
  final String chatPreference;
  const Params({required this.callPreference, required this.chatPreference});

  @override
  List<Object> get props => [callPreference, chatPreference];
}
