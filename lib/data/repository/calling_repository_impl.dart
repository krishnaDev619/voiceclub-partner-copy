import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/data_sources/remote/calling/calling_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/calling/calling_firebase_service.dart';
import 'package:voiceclub_partner/data/models/calling/accept_call_response.dart';
import 'package:voiceclub_partner/data/models/calling/call_details_response.dart';
import 'package:voiceclub_partner/data/models/calling/call_entry_model.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';
import 'package:voiceclub_partner/data/models/calling/call_state_model.dart';
import 'package:voiceclub_partner/data/models/calling/get_hung_call.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/data/models/calling/place_call_response.dart';
import 'package:voiceclub_partner/data/models/get_logs_grouped_response.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class CallingRepositoryImpl implements CallingRepository {
  final CallingApiService _callingApiService;
  final CallingFirebaseService _callingFirebaseService;

  CallingRepositoryImpl(this._callingApiService, this._callingFirebaseService);

  @override
  Future<DataState<PlaceCallResponseModel>> placeCall({
    required int demandUid,
  }) async {
    try {
      final response = await _callingApiService.placeCall(demandUid: demandUid);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<AcceptCallResponseModel>> acceptCall(
    String channelId,
  ) async {
    try {
      final response = await _callingApiService.acceptCall(channelId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> endCall(
    String channelId,
    bool callRejected,
    int uid,
    String declineReason,
  ) async {
    try {
      final response = await _callingApiService.endCall(
        channelId,
        callRejected,
        uid,
        declineReason,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<CallModel>> getCurrentCall(String channelId) async {
    try {
      final response = await _callingApiService.getCurrentCall(channelId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> setRing(String channelId) async {
    try {
      final response = await _callingApiService.setRing(
        channelId: channelId,
        isNotification: false,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetLogsGroupedResponseModel>> getLogsGrouped({
    required String type,
    required String period,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _callingApiService.getLogsGrouped(
        type: type,
        period: period,
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> pingCall({required String channelId}) async {
    try {
      final response = await _callingApiService.pingCall(channelId: channelId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetCallDetailsResponseModel>> getCallDetails({
    required String channelId,
  }) async {
    try {
      final response = await _callingApiService.getCallDetails(
        channelId: channelId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetReverseCallingStatsResponseModel>>
  getReverseCallingStats({required int demandAccountId}) async {
    try {
      final response = await _callingApiService.getReverseCallingStats(
        demandAccountId: demandAccountId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> endHungCall({required String channelId}) async {
    try {
      final response = await _callingApiService.endHungCall(
        channelId: channelId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetHungCallModel>> getHungCall() async {
    try {
      final response = await _callingApiService.getHungCall();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Stream<CallStateModel?>? fetchCallStateStream({required String channelId}) {
    try {
      final firestoreCallStream = _callingFirebaseService.fetchCallStateStream(
        channelId: channelId,
      );

      // Convert the Firestore stream to a Stream<CallStateModel>
      return firestoreCallStream.map((DocumentSnapshot<Object?> snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          String documentId = snapshot.id;
          return CallStateModel.fromFirestore(data, documentId);
        } else {
          // If the document doesn't exist, return a default or handle as needed
          return null;
        }
      });
    } catch (e) {
      Logger.logMessage(
        "Error in fetchCallStateStream Class : CallingRepositoryImpl Error : ${e.toString()}",
        isCritical: true,
      );
      return null;
    }
  }

  @override
  Stream<CallEntryModel?>? fetchCallEntryStream({required String accountId}) {
    try {
      final firestoreCallEntryStream = _callingFirebaseService
          .fetchCallEntryStream(accountId: accountId);

      // Convert the Firestore stream to a Stream<CallEntryModel>
      return firestoreCallEntryStream.map((DocumentSnapshot<Object?> snapshot) {
        if (snapshot.exists && !snapshot.metadata.isFromCache) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          return CallEntryModel.fromFirestore(data);
        } else {
          // If the document doesn't exist, return a default or handle as needed
          return null;
        }
      });
    } catch (e) {
      Logger.logMessage(
        "Error in fetchCallEntryStream Class : CallingRepositoryImpl Error : ${e.toString()}",
        isCritical: true,
      );
      return null;
    }
  }
}
