import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/notifications_repository.dart';

class TestNotificationUsecase implements UseCase<DataState<void>, NoParams> {
  final NotificationsRepository _notificationsRepository;
  TestNotificationUsecase(this._notificationsRepository);

  @override
  Future<DataState<void>> call(NoParams params) {
    return _notificationsRepository.testNotification();
  }
}
