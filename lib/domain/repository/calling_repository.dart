import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/calling/accept_call_response.dart';
import 'package:voiceclub_partner/data/models/calling/call_details_response.dart';
import 'package:voiceclub_partner/data/models/calling/call_entry_model.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';
import 'package:voiceclub_partner/data/models/calling/call_state_model.dart';
import 'package:voiceclub_partner/data/models/calling/get_hung_call.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/data/models/calling/place_call_response.dart';
import 'package:voiceclub_partner/data/models/get_logs_grouped_response.dart';

abstract class CallingRepository {
  Future<DataState<PlaceCallResponseModel>> placeCall({required int demandUid});

  Future<DataState<CallModel>> getCurrentCall(String channelId);

  Future<DataState<void>> endCall(
    String channelId,
    bool callRejected,
    int accountId,
    String declineReason,
  );

  Future<DataState<void>> setRing(String channelId);

  Future<DataState<GetLogsGroupedResponseModel>> getLogsGrouped({
    required String type,
    required String period,
    required int page,
    required int pageSize,
  });

  Future<DataState<AcceptCallResponseModel>> acceptCall(String channelId);

  Future<DataState> pingCall({required String channelId});

  Future<DataState<GetCallDetailsResponseModel>> getCallDetails({
    required String channelId,
  });

  Future<DataState<GetReverseCallingStatsResponseModel>>
  getReverseCallingStats({required int demandAccountId});

  Future<DataState<GetHungCallModel>> getHungCall();

  Future<DataState> endHungCall({required String channelId});

  // Firebase methods
  Stream<CallStateModel?>? fetchCallStateStream({required String channelId});

  Stream<CallEntryModel?>? fetchCallEntryStream({required String accountId});
}
