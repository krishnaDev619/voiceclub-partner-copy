import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/tier/tier_api_service.dart';
import 'package:voiceclub_partner/data/models/tier/get_weekly_online_duration_response.dart';
import 'package:voiceclub_partner/domain/repository/tier_repository.dart';

class TierRepositoryImpl implements TierRepository {
  final TierApiService _supplyTierApiService;

  TierRepositoryImpl(this._supplyTierApiService);

  @override
  Future<DataState<GetWeeklyOnlineDurationResponseModel>>
  getWeeklyOnlineDuration() async {
    try {
      final response = await _supplyTierApiService.getWeeklyOnlineDuration();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
