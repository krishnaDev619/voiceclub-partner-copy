import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateNotificationPreferenceUseCase
    implements UseCase<DataState<void>, Params> {
  final AccountRepository _supplyAccountRepository;
  UpdateNotificationPreferenceUseCase(this._supplyAccountRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _supplyAccountRepository.updateNotificationPreference(
      notificationPreference: params.notificationPreference,
    );
  }
}

class Params extends Equatable {
  final String notificationPreference;

  const Params({required this.notificationPreference});

  @override
  List<Object> get props => [notificationPreference];
}
