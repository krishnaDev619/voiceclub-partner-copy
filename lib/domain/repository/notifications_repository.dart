import 'package:voiceclub_partner/core/resources/data_state.dart';

abstract class NotificationsRepository {
  Future<DataState<void>> addNotification({
    required int uid,
    required bool isAudio,
    required String audioUrl,
  });

  Future<DataState<void>> testNotification();
}
