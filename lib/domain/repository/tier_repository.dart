import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/tier/get_weekly_online_duration_response.dart';

abstract class TierRepository {
  Future<DataState<GetWeeklyOnlineDurationResponseModel>>
  getWeeklyOnlineDuration();
}
