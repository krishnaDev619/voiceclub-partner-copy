import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/gifts/gifts_api_service.dart';
import 'package:voiceclub_partner/data/models/gifts/can_receive_gifts_response.dart';
import 'package:voiceclub_partner/domain/repository/gifts_repository.dart';

class GiftsRepositoryImpl implements GiftsRepository {
  final GiftsApiService _giftsApiService;
  GiftsRepositoryImpl(this._giftsApiService);

  @override
  Future<DataState<CanReceiveGiftsResponseModel>> canReceiveGifts({
    required int receiverAccountId,
    required int senderAccountId,
  }) async {
    try {
      final response = await _giftsApiService.canReceiveGifts(
        receiverAccountId: receiverAccountId,
        senderAccountId: senderAccountId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
