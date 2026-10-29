import 'dart:async';

import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/calling/call_entry_model.dart';
import 'package:voiceclub_partner/domain/usecases/calling/fetch_call_entry_stream.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/landing/retry_screen.dart';

class CallEntryService {
  StreamSubscription<CallEntryModel?>? _callEntryStreamSubscription;
  final _userController = Get.find<UserController>();
  final _callController = sl<CallController>();
  bool _isPaused = false;

  Future<void> initialize() async {
    try {
      // Cancel any existing subscription
      await _callEntryStreamSubscription?.cancel();

      // Get the user's account ID
      final accountId = _userController.accountId;
      if (accountId == 0) {
        Logger.logMessage(
          'Cannot initialize CallEntryService: Invalid account ID',
          isCritical: true,
        );
        _handleStreamError('Invalid account ID');
        return;
      }

      // Fetch and listen to the call entry stream
      final stream = await sl<FetchCallEntryStreamUsecase>().call(
        FetchCallEntryStreamParams(accountId: accountId.toString()),
      );

      if (stream != null) {
        _callEntryStreamSubscription = stream.listen(
          (callEntry) {
            if (callEntry != null &&
                callEntry.channelId != null &&
                callEntry.channelId!.trim().isNotEmpty) {
              _handleNewCallEntry(callEntry.channelId!);
            }
          },
          onError: (error) {
            Logger.logMessage(
              'Error in call entry stream: $error',
              isCritical: true,
            );
            _handleStreamError('Stream error: $error');
          },
        );
      } else {
        _handleStreamError('Failed to initialize call entry stream');
      }
    } catch (e) {
      Logger.logMessage(
        'Error initializing CallEntryService: $e',
        isCritical: true,
      );
      _handleStreamError('Service initialization error: $e');
    }
  }

  void _handleNewCallEntry(String channelId) {
    try {
      // Update the CallController with the new channel ID
      _callController.updateDetails(channelId);
    } catch (e) {
      Logger.logMessage('Error handling new call entry: $e', isCritical: true);
      _handleStreamError('Call entry handling error: $e');
    }
  }

  void _handleStreamError(String errorReason) {
    // Only navigate to RetryScreen if user is not on call and is online
    if (!_callController.isOnCall && _userController.isOnlineOrBusy) {
      // Cancel any existing subscription
      _callEntryStreamSubscription?.cancel();

      // Navigate to RetryScreen
      Get.offAll(() => RetryScreen(errorReason: errorReason));
    }
  }

  void pauseStream() {
    if (!_isPaused && _callEntryStreamSubscription != null) {
      // Cancel the subscription instead of pausing it
      _callEntryStreamSubscription?.cancel();
      _callEntryStreamSubscription = null;
      _isPaused = true;
      Logger.logMessage('Call entry stream paused and subscription cancelled');
    }
  }

  Future<void> resumeStream() async {
    if (_isPaused) {
      // Reinitialize the stream instead of resuming it
      await initialize();
      _isPaused = false;
      Logger.logMessage('Call entry stream reinitialized');
    }
  }

  Future<void> dispose() async {
    try {
      await _callEntryStreamSubscription?.cancel();
    } catch (e) {
      Logger.logMessage(
        'Error disposing CallEntryService: $e',
        isCritical: true,
      );
    }
  }
}
