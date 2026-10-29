import 'package:voiceclub_partner/core/resources/data_state.dart';

abstract class RingingRepository {
  Future<DataState<void>> setRing({required String channelId});
}
