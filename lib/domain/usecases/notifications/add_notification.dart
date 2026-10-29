import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/notifications_repository.dart';

class AddNotificationUsecase implements UseCase<DataState<void>, Params> {
  final NotificationsRepository _notificationsRepository;
  AddNotificationUsecase(this._notificationsRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _notificationsRepository.addNotification(
      uid: params.uid,
      isAudio: params.isAudio,
      audioUrl: params.audioUrl,
    );
  }
}

class Params extends Equatable {
  final int uid;
  final bool isAudio;
  final String audioUrl;

  const Params({
    required this.uid,
    required this.isAudio,
    required this.audioUrl,
  });

  @override
  List<Object> get props => [uid, isAudio, audioUrl];
}
