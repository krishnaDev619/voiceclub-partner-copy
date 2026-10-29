import 'dart:async';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/edit_response.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';

class PollEditStatusUseCase
    implements
        UseCase<DataState<CleanVoiceEditResponseModel>, PollEditStatusParams> {
  final CleanVoiceRepository _cleanVoiceRepository;

  PollEditStatusUseCase(this._cleanVoiceRepository);

  @override
  Future<DataState<CleanVoiceEditResponseModel>> call(
    PollEditStatusParams params,
  ) async {
    final completer = Completer<DataState<CleanVoiceEditResponseModel>>();

    Timer? pollTimer;
    Timer? timeoutTimer;

    void cleanup() {
      pollTimer?.cancel();
      timeoutTimer?.cancel();
    }

    // Set up timeout
    timeoutTimer = Timer(params.timeout, () {
      cleanup();
      if (!completer.isCompleted) {
        completer.complete(
          DataFailed(
            DioException(
              requestOptions: RequestOptions(path: ''),
              error: 'CleanVoice processing timeout',
            ),
          ),
        );
      }
    });

    // Start polling
    pollTimer = Timer.periodic(params.pollInterval, (timer) async {
      try {
        final result = await _cleanVoiceRepository.getEditStatus(
          editId: params.editId,
        );

        if (result is DataSuccess) {
          final response = result.data!;

          // Check if processing is complete
          if (response.status == EditStatus.SUCCESS &&
              response.result?.downloadUrl != null) {
            cleanup();
            if (!completer.isCompleted) {
              completer.complete(DataSuccess(response));
            }
            return;
          }

          // Check if processing failed
          if (response.status == EditStatus.FAILURE) {
            cleanup();
            if (!completer.isCompleted) {
              completer.complete(
                DataFailed(
                  DioException(
                    requestOptions: RequestOptions(path: ''),
                    error: 'CleanVoice processing failed: ${response.status}',
                  ),
                ),
              );
            }
            return;
          }

          // Report progress if callback provided
          params.onProgress?.call(response.status);
        } else {
          // Handle API error, but continue polling unless it's a critical error
          if (result is DataFailed && params.onError != null) {
            params.onError!(result.error!);
          }
        }
      } catch (e) {
        // Log error but continue polling
        params.onError?.call(e);
      }
    });

    return completer.future;
  }
}

class PollEditStatusParams {
  final String editId;
  final Duration pollInterval;
  final Duration timeout;
  final Function(EditStatus status)? onProgress;
  final Function(dynamic error)? onError;

  const PollEditStatusParams({
    required this.editId,
    this.pollInterval = const Duration(seconds: 5),
    this.timeout = const Duration(minutes: 10),
    this.onProgress,
    this.onError,
  });
}
