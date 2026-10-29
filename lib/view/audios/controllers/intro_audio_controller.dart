import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:vad/vad.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/open_ai_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/utils/process_arch.dart';
import 'package:voiceclub_partner/core/utils/wav_pcm.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_status_router.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_recording.dart'
    as update_recording;
import 'package:voiceclub_partner/domain/usecases/cleanvoice/clean_audio_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/poll_edit_status_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/file/upload_file.dart';
import 'package:voiceclub_partner/domain/usecases/openai/analyze_audio.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/voice_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class IntroAudioController extends GetxController {
  final String primaryText;
  final String secondaryText;
  final String cityName;
  final String language;

  late final AudioRecorder audioRecorder;
  String? path;
  Directory? appDirectory;
  ValueNotifier<int?> seconds = ValueNotifier<int?>(0);
  Timer? recordingTimer;
  Future<VadIterator?>? _vadPrepareFuture;

  final speechSeconds = 0.obs;
  static const int _minSpeechSeconds = 10;
  static const int _minTotalRecordingSeconds = 5;
  static const double _speechThreshold = 0.65;
  static const int _vadFrameSamples = 1536;
  static const int _vadSampleRate = 16000;

  final isRecording = false.obs;
  final isUploading = false.obs;
  final isCheckingSpeech = false.obs;
  final isRecordingCompleted = false.obs;
  final rejectionReason = Rxn<String>();
  final rejectionFeedback = Rxn<String>();
  final showGoLiveUI = false.obs;
  final showTeamReviewUI = false.obs;
  final processingStatus = ''.obs;
  final isProcessingWorkflow = false.obs;
  final isAnalysisFailed = false.obs;

  // Sample audio player management
  RxMap<String, PlayerController> samplePlayerControllersMap =
      <String, PlayerController>{}.obs;
  var currentSamplePlayerPath = "".obs;

  // CleanVoice related state
  File? cleanedAudioFile;

  // Audio processing context
  RecordingAudioType? currentAudioType;
  String? currentLanguage;

  // Attempt tracking
  int rejectionAttempts = 0;
  static const int maxAttempts = 3;

  // Language/Variant selection state
  final selectedLanguageVariant = Rxn<LanguageVariant>();
  final availableVariants = <LanguageVariant>[].obs;

  // Getters for UI state
  bool get isProcessing => isUploading.value;

  bool get hasCleanedAudio => cleanedAudioFile != null;

  bool get hasEnoughSpeech => (speechSeconds.value) >= _minSpeechSeconds;

  bool get isShowingProcessingUI =>
      isProcessingWorkflow.value || isCheckingSpeech.value;

  bool get canCloseSheet =>
      (!isShowingProcessingUI && !showGoLiveUI.value) || isAnalysisFailed.value;

  String get speechProgress =>
      "${speechSeconds.value}/${_minSpeechSeconds}s speech detected";

  final stopwatch = Stopwatch();

  IntroAudioController({
    required this.primaryText,
    required this.secondaryText,
    required this.cityName,
    required this.language,
  });

  @override
  void onInit() {
    super.onInit();
    _getDir();
    _initialiseControllers();
    _initializeLanguageVariants();
  }

  /// Initialize available language variants based on text availability
  void _initializeLanguageVariants() {
    availableVariants.clear();

    // Add primary variant (English) if text is available
    if (primaryText.isNotEmpty) {
      availableVariants.add(LanguageVariant.primary());
    }

    // Add secondary variant (actual language name) if text is available
    if (secondaryText.isNotEmpty) {
      availableVariants.add(LanguageVariant.secondary(language));
    }

    // Set default selection to first available variant
    if (availableVariants.isNotEmpty) {
      selectedLanguageVariant.value = availableVariants.first;
    }

    Logger.logMessage(
      "Initialized language variants: ${availableVariants.map((v) => v.displayName).join(', ')}",
      name: 'IntroAudioController',
    );
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory?.path}/recording.wav";
  }

  // Sample audio player management methods
  void registerSamplePlayer(PlayerController controller) {
    samplePlayerControllersMap[controller.playerKey] = controller;
  }

  void unregisterSamplePlayer(PlayerController controller) {
    samplePlayerControllersMap.remove(controller.playerKey);
    if (currentSamplePlayerPath.value == controller.playerKey) {
      currentSamplePlayerPath.value = "";
    }
  }

  void stopAndStartSamplePlayer(String playerKey) {
    if (playerKey == currentSamplePlayerPath.value) {
      final playerController = samplePlayerControllersMap[playerKey];
      if (playerController!.playerState.isPlaying) {
        playerController.pausePlayer();
        sl<AnalyticsService>().trackEvent(
          "introAudioSamplePlayerPaused",
          eventProperties: sl<IntroAudioPolicyService>().analyticsProperties,
        );
      } else {
        playerController.startPlayer();
        sl<AnalyticsService>().trackEvent(
          "introAudioSamplePlayerPlayed",
          eventProperties: sl<IntroAudioPolicyService>().analyticsProperties,
        );
      }
      return;
    }

    // Stop all other sample players
    for (var controller in samplePlayerControllersMap.values) {
      controller.pausePlayer();
      sl<AnalyticsService>().trackEvent(
        "introAudioSamplePlayerPaused",
        eventProperties: sl<IntroAudioPolicyService>().analyticsProperties,
      );
    }

    final playerController = samplePlayerControllersMap[playerKey];
    playerController?.startPlayer();
    currentSamplePlayerPath.value = playerController?.playerKey ?? "";
    sl<AnalyticsService>().trackEvent(
      "introAudioSamplePlayerPlayed",
      eventProperties: sl<IntroAudioPolicyService>().analyticsProperties,
    );
  }

  void stopAllSamplePlayers() {
    for (var controller in samplePlayerControllersMap.values) {
      controller.pausePlayer();
    }
    currentSamplePlayerPath.value = "";
  }

  /// Get the current instruction text based on selected language variant
  String get currentInstructionText {
    if (selectedLanguageVariant.value?.variantType == 'primary') {
      return primaryText;
    } else {
      return secondaryText;
    }
  }

  /// Select a language variant
  void selectLanguageVariant(LanguageVariant variant) {
    if (availableVariants.contains(variant)) {
      selectedLanguageVariant.value = variant;

      // Track analytics for language selection
      sl<AnalyticsService>().trackEvent(
        "introAudioLanguageVariantSelected",
        eventProperties: {
          "selectedVariant": variant.variantType,
          "selectedDisplayName": variant.displayName,
          ...sl<IntroAudioPolicyService>().analyticsProperties,
        },
      );

      Logger.logMessage(
        "Language variant selected: ${variant.displayName}",
        name: 'IntroAudioController',
      );
    }
  }

  /// Get the number of available variants
  int get availableVariantCount => availableVariants.length;

  void reupload() {
    // Add haptic feedback for reupload action
    HapticFeedback.lightImpact();

    // Stop all sample players when starting new recording
    stopAllSamplePlayers();

    // Regenerate path for new recording
    if (appDirectory != null) {
      path = "${appDirectory?.path}/recording.wav";
    }
    seconds.value = 0;
    speechSeconds.value = 0;
    isRecording.value = false;
    isCheckingSpeech.value = false;
    isRecordingCompleted.value = false;
    rejectionReason.value = null;
    rejectionFeedback.value = null;
    showGoLiveUI.value = false;
    showTeamReviewUI.value = false;
    processingStatus.value = '';
    isProcessingWorkflow.value = false;
    isAnalysisFailed.value = false;
    clearCleanedAudio();
  }

  void _initialiseControllers() {
    audioRecorder = AudioRecorder();
    // ONNX Runtime (Silero VAD) can SIGBUS on 32-bit ARM.
    if (!is32BitProcess) {
      unawaited(_ensureVadIterator());
    }
  }

  /// Loads Silero once so stop() can score the file without opening a mic.
  Future<VadIterator?> _ensureVadIterator() {
    if (is32BitProcess) return Future.value(null);
    return _vadPrepareFuture ??= _createVadIterator();
  }

  Future<VadIterator?> _createVadIterator() async {
    try {
      final iterator = await VadIterator.create(
        isDebug: false,
        sampleRate: _vadSampleRate,
        frameSamples: _vadFrameSamples,
        positiveSpeechThreshold: _speechThreshold,
        negativeSpeechThreshold: 0.3,
        redemptionFrames: 10,
        preSpeechPadFrames: 6,
        minSpeechFrames: 5,
        model: 'v4',
      );
      Logger.logMessage(
        "Prepared offline Silero VAD iterator",
        name: 'IntroAudioController',
      );
      return iterator;
    } catch (e) {
      _vadPrepareFuture = null;
      Logger.logMessage(
        "Error preparing VAD iterator: $e",
        name: 'IntroAudioController',
      );
      return null;
    }
  }

  /// Run Silero on the saved WAV so recording never shares the microphone.
  Future<int> _countSpeechSecondsWithVad(String filePath) async {
    if (is32BitProcess) {
      return seconds.value ?? 0;
    }

    final iterator = await _ensureVadIterator();
    if (iterator == null) {
      return seconds.value ?? 0;
    }

    try {
      final bytes = await File(filePath).readAsBytes();
      final pcm16k = await Isolate.run(
        () => decodeWavToSileroPcm(bytes),
      ).catchError((_) => decodeWavToSileroPcm(bytes));
      if (pcm16k.isEmpty) {
        Logger.logMessage(
          "Could not decode recording WAV for VAD",
          name: 'IntroAudioController',
        );
        return 0;
      }

      var speechFrames = 0;
      var totalFrames = 0;
      iterator.reset();
      iterator.setVadEventCallback((event) {
        if (event.type != VadEventType.frameProcessed) return;
        totalFrames++;
        if ((event.probabilities?.isSpeech ?? 0) >= _speechThreshold) {
          speechFrames++;
        }
      });

      // Yield between chunks so the processing spinner can keep painting.
      const bytesPerChunk = _vadFrameSamples * 2 * 8;
      for (var offset = 0; offset < pcm16k.length; offset += bytesPerChunk) {
        if (isClosed) return 0;
        final end = (offset + bytesPerChunk).clamp(0, pcm16k.length);
        await iterator.processAudioData(
          Uint8List.sublistView(pcm16k, offset, end),
        );
        await Future<void>.delayed(Duration.zero);
      }

      final speechTime =
          (speechFrames * _vadFrameSamples / _vadSampleRate).round();
      Logger.logMessage(
        "Offline VAD - Speech: ${speechTime}s, Frames: $speechFrames/$totalFrames",
        name: 'IntroAudioController',
      );
      return speechTime;
    } catch (e) {
      Logger.logMessage(
        "Error running offline VAD: $e",
        name: 'IntroAudioController',
      );
      return 0;
    }
  }

  /// Validate speech content from offline VAD on the recorded file
  Future<bool> _validateSpeechInAudioFile(File audioFile) async {
    try {
      final currentSpeechTime = speechSeconds.value;
      final currentTotalTime = seconds.value ?? 0;

      Logger.logMessage(
        "Validating speech - Total: ${currentTotalTime}s, Speech: ${currentSpeechTime}s, Required: ${_minSpeechSeconds}s",
        name: 'IntroAudioController',
      );

      // Return true if we detected enough speech during recording
      return currentSpeechTime >= _minSpeechSeconds;
    } catch (e) {
      Logger.logMessage(
        "Error validating speech in audio file: $e",
        name: 'IntroAudioController',
      );
      return false;
    }
  }

  void startOrStopRecording(RecordingAudioStatus? status) async {
    try {
      if (isRecording.value) {
        // Add haptic feedback for stop recording
        HapticFeedback.mediumImpact();
        await stopRecording();
      } else {
        // Check microphone permission before starting recording
        final micPermissionStatus = await Permission.microphone.status;

        if (!micPermissionStatus.isGranted) {
          // Discard any existing recording state
          reupload();

          // Request microphone permission
          final result = await Permission.microphone.request();

          if (!result.isGranted) {
            // Show appropriate error message based on permission status
            AlertService.showSnackBar(
              snackBarType: SnackBarType.Error,
              title: LocaleKeys.livePermissionDenied.tr,
              subtitle:
                  result.isPermanentlyDenied
                      ? LocaleKeys.microphoneAccessOpenSettings.tr
                      : LocaleKeys.microphoneAccess.tr,
            );
          }
          // Let user long press again to start recording after permission is granted
          return;
        }

        // Add haptic feedback for start recording
        HapticFeedback.mediumImpact();

        // Stop all sample players when starting recording
        stopAllSamplePlayers();

        await audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 44100,
            autoGain: true,
            bitRate: 128000,
          ),
          path: path!,
        );
        // Only set to recording state if start was successful
        isRecording.value = true;

        recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if ((seconds.value ?? 0) >= 30) {
            recordingTimer?.cancel();
            stopRecording();
          } else {
            seconds.value = (seconds.value ?? 0) + 1;
          }
        });
      }
    } catch (_) {
      // On error, ensure recording state is false
      isRecording.value = false;
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording.value) return;

    isRecording.value = false;
    recordingTimer?.cancel();
    isCheckingSpeech.value = true;
    processingStatus.value = LocaleKeys.processingAudio.tr;
    await _waitForLoaderFrame();

    try {
      final recordedPath = await audioRecorder.stop();
      path = recordedPath;
      if (recordedPath == null) return;

      final speechTime = await _countSpeechSecondsWithVad(recordedPath);
      if (isClosed) return;
      speechSeconds.value = speechTime;
      _completeOrRejectRecording(speechTime, seconds.value ?? 0);
    } finally {
      if (!isClosed) {
        isCheckingSpeech.value = false;
        processingStatus.value = '';
      }
    }
  }

  Future<void> _waitForLoaderFrame() async {
    await Future<void>.delayed(Duration.zero);
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
  }

  void _completeOrRejectRecording(int speechTime, int totalTime) {
    if (speechTime >= _minSpeechSeconds &&
        totalTime >= _minTotalRecordingSeconds) {
      isRecordingCompleted.value = true;
      Logger.logMessage(
        "Recording completed - Total: ${totalTime}s, Speech: ${speechTime}s",
        name: 'IntroAudioController',
      );
      return;
    }

    final alertMessage =
        speechTime < _minSpeechSeconds
            ? LocaleKeys.speakLoudlyForSeconds.trParams({
              'count': '$_minSpeechSeconds',
            })
            : LocaleKeys.minimumRecordingDuration.tr;
    Logger.logMessage(
      "Recording rejected - Total: ${totalTime}s, Speech: ${speechTime}s, Required speech: ${_minSpeechSeconds}s",
      name: 'IntroAudioController',
    );
    reupload();
    AlertService.showSnackBar(
      snackBarType: SnackBarType.Warning,
      title: LocaleKeys.liveAlert.tr,
      subtitle: alertMessage,
    );
  }

  @override
  void onClose() {
    final preparing = _vadPrepareFuture;
    _vadPrepareFuture = null;
    preparing?.then((iterator) => iterator?.release());
    audioRecorder.dispose();
    // Dispose all sample players
    for (var controller in samplePlayerControllersMap.values) {
      controller.dispose();
    }
    samplePlayerControllersMap.clear();
    super.onClose();
  }

  void clearCleanedAudio() {
    cleanedAudioFile = null;
  }

  Future<void> analyzeAudioWithOpenAI({
    required RecordingAudioType audioType,
    required String language,
  }) async {
    if (path == null) return;

    sl<AnalyticsService>().trackEvent(
      "aiIntroAudioSubmit",
      eventProperties: {
        "audio_type": audioType.name,
        "language": language,
        "textToSpeak": currentInstructionText,
        "selectedVariant": selectedLanguageVariant.value?.variantType,
        "totalDuration": seconds.value?.toStringAsFixed(1),
        "speechDuration": speechSeconds.value.toStringAsFixed(1),
        "minSpeechRequired": _minSpeechSeconds,
        "hadEnoughSpeech": hasEnoughSpeech,
        ...sl<IntroAudioPolicyService>().analyticsProperties,
      },
    );

    // Add haptic feedback for starting audio analysis
    HapticFeedback.lightImpact();

    // Store context for later use
    currentAudioType = audioType;
    currentLanguage = language;

    isUploading.value = true;
    isProcessingWorkflow.value = true; // Start workflow tracking
    processingStatus.value = LocaleKeys.analyzingAudio.tr;
    stopwatch.start();

    try {
      // Since we're recording in WAV format, we can use the file directly
      final audioFile = File(path!);

      // Validate speech content before proceeding with expensive AI analysis
      final hasValidSpeech = await _validateSpeechInAudioFile(audioFile);
      if (!hasValidSpeech) {
        Logger.logMessage("Insufficient speech detected in audio file");
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Warning,
          title: LocaleKeys.liveInsufficientSpeech.tr,
          subtitle: LocaleKeys.speakForAtLeastSeconds.trParams({
            'count': '$_minSpeechSeconds',
          }),
        );
        return;
      }

      final scriptPrompt = sl<UiLocalizationService>().introAudio?.prompt;

      final appName = Get.find<UserController>().userDetails.value.user?.name;

      // Combine the prompt with currentInstructionText as prefix
      final promptVariables =
          "\nVariables:\nTextToSpeak: $currentInstructionText\nAppName: $appName\n";
      final combinedPrompt = scriptPrompt?.replaceAll(
        "{promptPlaceholder}",
        promptVariables,
      );

      Logger.logMessage(
        "Analyze Audio UseCase Params: audioFile: ${audioFile.path}, model: ${OpenAIConstants.model}, ",
      );

      // Analyze with OpenAI
      final result = await sl<AnalyzeAudioUseCase>().call(
        AnalyzeAudioParams(audioFile: audioFile, prompt: combinedPrompt),
      );

      Logger.logMessage("Analyze Audio UseCase Result: ${result.toString()}");

      if (result is DataSuccess) {
        final transcript =
            result.data!.choices?.first.message?.audio?.transcript;
        if (transcript != null) {
          Logger.logMessage("Reason: ${transcript.reason}");
          Logger.logMessage("Decision: ${transcript.decision?.name}");
          Logger.logMessage("Feedback: ${transcript.feedback}");

          // If decision is ACCEPTED, process the audio
          if (transcript.decision == IntroAudioDecision.APPROVED) {
            sl<AnalyticsService>().trackEvent(
              "aiIntroAudioApproved",
              eventProperties: {
                "audio_type": audioType.name,
                "language": language,
                "textToSpeak": currentInstructionText,
                "selectedVariant": selectedLanguageVariant.value?.variantType,
                "reason": transcript.reason,
                "feedback": transcript.feedback,
                "rejectionAttempts": rejectionAttempts,
                ...sl<IntroAudioPolicyService>().analyticsProperties,
              },
            );
            await _processAudioWorkflow(audioFile, isRejected: false);
          } else {
            // Audio was rejected
            await _handleAudioRejection(audioFile, transcript);
          }
        }
      } else {
        sl<AnalyticsService>().trackEvent(
          "partnerAudioAnalysisError",
          eventProperties: {
            'audioType': currentAudioType?.name,
            'language': currentLanguage,
            'error': result.error?.error.toString(),
            'message': result.error?.message.toString(),
            ...sl<IntroAudioPolicyService>().analyticsProperties,
          },
        );
        isAnalysisFailed.value = true;
        Logger.logMessage(
          "AUDIO ANALYSIS FAILED: error: ${result.error?.error.toString()}, message: ${result.error?.message.toString()}, response: ${result.errorMessage}",
        );
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.liveAnalysisFailed.tr,
          subtitle: LocaleKeys.pleaseTryAgainLater.tr,
        );
      }
    } catch (e) {
      Logger.logMessage("Error in analyzeAudioWithOpenAI: $e");
    } finally {
      isUploading.value = false;
      processingStatus.value = '';
    }
  }

  /// Main workflow to process audio - tries CleanVoice first, falls back to original audio
  Future<void> _processAudioWorkflow(
    File audioFile, {
    bool isRejected = false,
  }) async {
    File? finalAudioFile;

    // Try CleanVoice processing first
    try {
      finalAudioFile = await _attemptCleanVoiceProcessing(audioFile);
      Logger.logMessage("Successfully processed audio with CleanVoice");
    } catch (e) {
      Logger.logMessage(
        "CleanVoice processing failed: $e. Using original audio.",
      );
      finalAudioFile = audioFile; // Fallback to original audio

      sl<AnalyticsService>().trackEvent(
        "cleanAudioFallback",
        eventProperties: {
          "error": e.toString(),
          "audioType": currentAudioType?.name,
          ...sl<IntroAudioPolicyService>().analyticsProperties,
        },
      );
    }

    // Always proceed with upload regardless of CleanVoice success/failure
    await _uploadAndUpdateRecording(finalAudioFile, isRejected: isRejected);

    // Handle UI updates
    await _handleWorkflowCompletion(isRejected);
  }

  /// Handle audio rejection logic
  Future<void> _handleAudioRejection(File audioFile, dynamic transcript) async {
    final fileUrl = await _uploadAndGetUrl(audioFile);
    rejectionAttempts++;
    Logger.logMessage(
      "Audio rejected. Attempt: $rejectionAttempts/$maxAttempts",
    );

    sl<AnalyticsService>().trackEvent(
      "aiIntroAudioRejected",
      eventProperties: {
        "audio_type": currentAudioType?.name,
        "language": currentLanguage,
        "textToSpeak": currentInstructionText,
        "selectedVariant": selectedLanguageVariant.value?.variantType,
        "fileUrl": fileUrl,
        "reason": transcript.reason,
        "feedback": transcript.feedback,
        "rejectionAttempts": rejectionAttempts,
        ...sl<IntroAudioPolicyService>().analyticsProperties,
      },
    );

    if (rejectionAttempts >= maxAttempts) {
      // 3rd attempt failed - proceed with processing but mark as rejected
      Logger.logMessage("Max attempts reached. Proceeding with team review.");
      await _processAudioWorkflow(audioFile, isRejected: true);
    } else {
      // Show rejection reason for retry
      rejectionReason.value = transcript.reason;
      rejectionFeedback.value = transcript.feedback;
      Logger.logMessage(
        "Audio analysis failed. Reason: ${transcript.reason}. Attempts remaining: ${maxAttempts - rejectionAttempts}",
      );
    }
  }

  /// Attempt CleanVoice processing with 2-minute timeout and proper error handling
  Future<File> _attemptCleanVoiceProcessing(File audioFile) async {
    Logger.logMessage("_attemptCleanVoice");
    processingStatus.value = LocaleKeys.cleaningAudio.tr;

    // 1. Start the CleanVoice cleaning process
    final filename = 'intro_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final cleanResult = await sl<CleanAudioUseCase>().call(
      CleanAudioParams(
        audioFile: audioFile,
        filename: filename,
        config: {
          'filler_sound': true,
          'stuttering': true,
          'breath': true,
          'mouth_sound': true,
          'dead_air': true,
          'normalize': true,
          'remove_noise': true,
          'export_format': 'm4a',
        },
      ),
    );

    if (cleanResult is! DataSuccess) {
      throw Exception('Failed to start CleanVoice processing');
    }

    final editResponse = cleanResult.data!;
    Logger.logMessage("CleanVoice job started with ID: ${editResponse.id}");

    // 2. Poll for completion with 2-minute timeout
    final pollResult = await sl<PollEditStatusUseCase>().call(
      PollEditStatusParams(
        editId: editResponse.id,
        pollInterval: const Duration(seconds: 2), // Status timer
        timeout: const Duration(minutes: 1), // Max duration for polling
      ),
    );

    if (pollResult is! DataSuccess) {
      throw Exception(
        'CleanVoice processing failed or timed out after 2 minutes',
      );
    }

    final completedResponse = pollResult.data!;
    if (completedResponse.result?.downloadUrl?.isEmpty == true) {
      throw Exception('No download URL available from CleanVoice');
    }

    // 3. Download the cleaned audio
    sl<AnalyticsService>().trackEvent(
      "cleanAudioSuccess",
      eventProperties: sl<IntroAudioPolicyService>().analyticsProperties,
    );
    final cleanedFile = await _downloadCleanedAudio(
      completedResponse.result!.downloadUrl!,
      'cleaned_$filename',
    );

    return cleanedFile;
  }

  /// Download cleaned audio file from CleanVoice
  Future<File> _downloadCleanedAudio(
    String downloadUrl,
    String filename,
  ) async {
    processingStatus.value = LocaleKeys.processingAudio.tr;

    final cleanedAudioFile = await DefaultCacheManager().getSingleFile(
      downloadUrl,
    );
    Logger.logMessage("Cleaned audio file path: ${cleanedAudioFile.path}");

    // Store the cleaned audio file
    this.cleanedAudioFile = cleanedAudioFile;

    return cleanedAudioFile;
  }

  /// Handle workflow completion UI updates
  Future<void> _handleWorkflowCompletion(bool isRejected) async {
    if (isRejected) {
      // Show team review UI instead of success message
      showTeamReviewUI.value = true;
      rejectionReason.value = null; // Clear rejection reason
      rejectionFeedback.value = null;
    } else {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Success,
        title: LocaleKeys.liveAudioProcessedSuccessfully.tr,
        subtitle: LocaleKeys.liveYourAudioHasBeenProcessed.tr,
      );
    }
  }

  Future<void> _uploadAndUpdateRecording(
    File audioFile, {
    bool isRejected = false,
  }) async {
    try {
      // 1. Upload the file to server
      final fileUrl = await _uploadAndGetUrl(audioFile);

      if (fileUrl != null) {
        // 2. Update recording with appropriate status If rejected then set to pending
        final status =
            isRejected
                ? RecordingAudioStatus.AiRejected.toApiString
                : RecordingAudioStatus.AiApproved.toApiString;

        final updateResult = await sl<update_recording.UpdateRecordingUsecase>()
            .call(
              update_recording.Params(
                url: fileUrl,
                recordingAudioType: currentAudioType!,
                language: currentLanguage!,
                status: status,
                reason: rejectionReason.value ?? "Default Reason",
              ),
            );

        if (updateResult is DataSuccess) {
          Logger.logMessage(
            "Recording updated successfully with status: $status",
          );

          stopwatch.stop();
          final duration = stopwatch.elapsed.inSeconds;

          sl<AnalyticsService>().trackEvent(
            "partnerAudioSuccess",
            eventProperties: {
              'audioType': currentAudioType?.name,
              'language': currentLanguage,
              'isRejected': isRejected,
              'languageType':
                  currentAudioType == RecordingAudioType.Main
                      ? "Primary"
                      : "Secondary",
              'recordUrl': fileUrl,
              'duration': seconds.value?.toStringAsFixed(1),
              'speechDuration': speechSeconds.value.toStringAsFixed(1),
              'speechPercentage':
                  seconds.value != null && seconds.value! > 0
                      ? ((speechSeconds.value) / seconds.value! * 100)
                          .toStringAsFixed(1)
                      : "0",
              "isFromAi": true,
              "timeTaken": duration,
              "hasEnoughSpeech": hasEnoughSpeech,
              ...sl<IntroAudioPolicyService>().analyticsProperties,
            },
          );

          // 3. Fetch updated data
          await Get.find<UserController>().fetchData();

          // 4. Check and update current step
          final voiceController = Get.find<VoiceController>();
          await voiceController.checkAndUpdateCurrentStep();

          // 5. Only check GO LIVE UI if not rejected
          if (!isRejected) {
            await _checkAndShowGoLiveUI();
          }
        } else {
          throw Exception('Failed to update recording');
        }
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      Logger.logMessage("Upload and update error: $e");

      // Show error message but don't break the workflow
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveUploadFailed.tr,
        subtitle: LocaleKeys.liveCouldNotUploadTheAudio.tr,
      );

      // Track error for analytics
      sl<AnalyticsService>().trackEvent(
        "partnerAudioUploadError",
        eventProperties: {
          'audioType': currentAudioType?.name,
          'language': currentLanguage,
          'error': e.toString(),
          ...sl<IntroAudioPolicyService>().analyticsProperties,
        },
      );
    } finally {
      isProcessingWorkflow.value = false; // End workflow tracking
    }
  }

  // Helper method to check if user has different primary and secondary languages
  bool _requiresSecondaryAudio() {
    try {
      final userController = Get.find<UserController>();
      final userDetails = userController.userDetails.value;

      final primaryLanguage = userDetails.primaryLanguage;
      final secondaryLanguage = userDetails.secondaryLanguage;

      // Secondary audio is required if:
      // 1. Secondary language exists AND
      // 2. Secondary language is different from primary language
      return (secondaryLanguage?.isNotEmpty ?? false) &&
          (secondaryLanguage != primaryLanguage);
    } catch (e) {
      Logger.logMessage("Error checking language requirements: $e");
      return false;
    }
  }

  Future<void> _checkAndShowGoLiveUI() async {
    try {
      final userController = Get.find<UserController>();
      final audioStatusList = userController.audioStatusList;

      // Check if both main and secondary audios are approved
      final mainAudio = audioStatusList.firstWhereOrNull(
        (audio) => audio.type == RecordingAudioType.Main,
      );
      final secondaryAudio = audioStatusList.firstWhereOrNull(
        (audio) => audio.type == RecordingAudioType.Secondary,
      );

      final mainApproved =
          mainAudio?.status == RecordingAudioStatus.Approved ||
          mainAudio?.status == RecordingAudioStatus.AiApproved;
      final secondaryApproved =
          secondaryAudio?.status == RecordingAudioStatus.Approved ||
          secondaryAudio?.status == RecordingAudioStatus.AiApproved;

      final requiresSecondaryAudio = _requiresSecondaryAudio();

      Logger.logMessage(
        "Language requirements check: requiresSecondaryAudio=$requiresSecondaryAudio, currentAudioType=${currentAudioType?.name}, mainApproved=$mainApproved, secondaryApproved=$secondaryApproved",
      );

      // Determine when to show GO LIVE UI based on language requirements
      bool shouldShowGoLive = false;

      if (!requiresSecondaryAudio) {
        // User has same primary and secondary languages (or no secondary language)
        // Show GO LIVE when MAIN audio is approved and we're processing MAIN audio
        shouldShowGoLive =
            mainApproved && currentAudioType == RecordingAudioType.Main;

        if (shouldShowGoLive) {
          Logger.logMessage(
            "Single language setup: Main audio approved - showing GO LIVE UI",
          );
        }
      } else {
        // User has different primary and secondary languages
        // Show GO LIVE only when we're processing SECONDARY audio AND both audios are approved
        shouldShowGoLive = mainApproved && secondaryApproved;

        if (shouldShowGoLive) {
          Logger.logMessage(
            "Dual language setup: Both audios approved and processing secondary - showing GO LIVE UI",
          );
        }
      }

      if (shouldShowGoLive) {
        showGoLiveUI.value = true;
        await _autoCompleteOnboardingAfterCelebration();
      } else {
        Get.back();
      }
    } catch (e) {
      Logger.logMessage("Error checking onboarding completion status: $e");
    }
  }

  Future<void> _autoCompleteOnboardingAfterCelebration() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!showGoLiveUI.value) {
      return;
    }

    await OnboardingStatusRouter.completeIntroIfReady(
      isFromAi: true,
      closeBottomSheetBeforeContinue: true,
    );
  }

  Future<String?> _uploadAndGetUrl(File file) async {
    try {
      final uploadResult = await sl<UploadFileUsecase>().call(
        UploadFileParams(recordingFile: file),
      );
      if (uploadResult is DataSuccess && uploadResult.data?.url != null) {
        Logger.logMessage(
          "File uploaded successfully: ${uploadResult.data!.url}",
        );
        return uploadResult.data!.url!;
      } else {
        return null;
      }
    } catch (e) {
      Logger.logMessage(
        "Error: in MarkOnboardingCompleted $e",
        name: 'IntroAudioController',
      );
      return null;
    }
  }
}

class LanguageVariant {
  final String displayName;
  final String variantType;

  const LanguageVariant({required this.displayName, required this.variantType});

  // Factory constructors for common variants
  factory LanguageVariant.primary() =>
      const LanguageVariant(displayName: 'English', variantType: 'primary');

  factory LanguageVariant.secondary(String languageName) =>
      LanguageVariant(displayName: languageName, variantType: 'secondary');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageVariant &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          variantType == other.variantType;

  @override
  int get hashCode => displayName.hashCode ^ variantType.hashCode;

  @override
  String toString() =>
      'LanguageVariant(displayName: $displayName, variantType: $variantType)';
}
