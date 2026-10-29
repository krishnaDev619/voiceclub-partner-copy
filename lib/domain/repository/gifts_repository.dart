import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/gifts/can_receive_gifts_response.dart';

abstract class GiftsRepository {
  Future<DataState<CanReceiveGiftsResponseModel>> canReceiveGifts({
    required int receiverAccountId,
    required int senderAccountId,
  });
}
