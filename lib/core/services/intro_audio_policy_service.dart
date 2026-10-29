import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/config/intro_audio_settings_response.dart';
import 'package:voiceclub_partner/domain/usecases/config/get_intro_audio_settings.dart';

class IntroAudioPolicyService {
  static const _passedKeyPrefix = 'new_live_intro_passed_';
  static const _completedAtKeyPrefix = 'new_live_intro_completed_at_';

  final GetIntroAudioSettingsUsecase _getIntroAudioSettingsUsecase;

  IntroAudioPolicyService(this._getIntroAudioSettingsUsecase);

  IntroAudioSettingsResponse? _settings;
  IntroAudioCollectionStep _collectionStep = IntroAudioCollectionStep.probation;
  final Set<int> _passedAccountIds = {};

  IntroAudioCollectionStep get collectionStep => _collectionStep;

  bool? get enabled => _settings?.enabled;

  String? get source => _settings?.source;

  String? get variant => _settings?.variant;

  bool get requiresIntroAtOnboarded =>
      _collectionStep == IntroAudioCollectionStep.probation;

  bool get requiresIntroAtNewLive =>
      _collectionStep == IntroAudioCollectionStep.newLive;

  bool shouldShowAccountRecordVoices({
    required TutorialStage stage,
    bool hasUploadedAllAudios = false,
    RecordingAudioStatus audioApprovalStatus = RecordingAudioStatus.Pending,
    int accountId = 0,
  }) {
    if (_collectionStep == IntroAudioCollectionStep.off) {
      return false;
    }
    if (_collectionStep != IntroAudioCollectionStep.newLive) {
      return true;
    }
    if (stage.isLessThan(TutorialStage.S4)) {
      return false;
    }
    if (stage == TutorialStage.S4) {
      return hasCompletedNewLiveIntroSubmission(
        hasUploadedAllAudios: hasUploadedAllAudios,
        audioApprovalStatus: audioApprovalStatus,
        accountId: accountId,
      );
    }
    return true;
  }

  /// S4 course is done, or the partner is already on S5+.
  bool hasFinishedS4Journey({
    required TutorialStage stage,
    required bool stageCourseCompleted,
  }) {
    if (stage == TutorialStage.DONE || stage.isGreaterThan(TutorialStage.S4)) {
      return true;
    }
    return stage == TutorialStage.S4 && stageCourseCompleted;
  }

  /// NEW_LIVE intro is collected at the end of S4, before S5 / landing.
  bool shouldCollectIntroAfterS4({
    required TutorialStage stage,
    required bool stageCourseCompleted,
  }) {
    return requiresIntroAtNewLive &&
        hasFinishedS4Journey(
          stage: stage,
          stageCourseCompleted: stageCourseCompleted,
        );
  }

  bool get blocksGoOnlineWithoutRecording =>
      _collectionStep == IntroAudioCollectionStep.probation;

  Map<String, dynamic> get analyticsProperties => {
    'introAudioEnabled': enabled,
    'introAudioSource': source,
    'introAudioVariant': variant,
    'introAudioCollectionStep': _collectionStep.apiValue,
    'collectionStep': _collectionStep.apiValue,
  };

  bool hasApprovedRequiredIntros({
    required bool hasUploadedAllAudios,
    required RecordingAudioStatus audioApprovalStatus,
  }) {
    return hasUploadedAllAudios &&
        (audioApprovalStatus == RecordingAudioStatus.Approved ||
            audioApprovalStatus == RecordingAudioStatus.AiApproved);
  }

  /// First NEW_LIVE intro pass is AI approval or KAM approval only.
  /// After that pass is persisted, later KAM reject does not reopen intro.
  bool hasCompletedNewLiveIntroSubmission({
    required bool hasUploadedAllAudios,
    required RecordingAudioStatus audioApprovalStatus,
    int accountId = 0,
  }) {
    if (hasPassedNewLiveIntroLocally(accountId)) {
      return true;
    }
    return hasApprovedRequiredIntros(
      hasUploadedAllAudios: hasUploadedAllAudios,
      audioApprovalStatus: audioApprovalStatus,
    );
  }

  bool hasPassedNewLiveIntroLocally(int accountId) {
    if (accountId == 0) {
      return false;
    }
    return _passedAccountIds.contains(accountId);
  }

  Future<bool> hasPassedNewLiveIntro(int accountId) async {
    if (accountId == 0) {
      return false;
    }
    if (_passedAccountIds.contains(accountId)) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    final passed = prefs.getBool(_passedKey(accountId)) ?? false;
    if (passed) {
      _passedAccountIds.add(accountId);
    }
    return passed;
  }

  Future<void> markNewLiveIntroPassed(int accountId) async {
    if (accountId == 0) {
      return;
    }
    _passedAccountIds.add(accountId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_passedKey(accountId), true);
    Logger.logMessage(
      'Marked NEW_LIVE intro as passed for account=$accountId',
      name: 'IntroAudioPolicy',
    );
  }

  String _passedKey(int accountId) => '$_passedKeyPrefix$accountId';

  String _completedAtKey(int accountId) => '$_completedAtKeyPrefix$accountId';

  Future<void> saveNewLiveIntroCompletedAt(int accountId) async {
    if (accountId == 0) {
      return;
    }
    final completedAt = DateTime.now().toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedAtKey(accountId), completedAt);
    Logger.logMessage(
      'Saved NEW_LIVE intro completedAt=$completedAt for account=$accountId',
      name: 'IntroAudioPolicy',
    );
  }

  Future<DateTime?> getNewLiveIntroCompletedAt(int accountId) async {
    if (accountId == 0) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completedAtKey(accountId));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> clearNewLiveIntroCompletedAt(int accountId) async {
    if (accountId == 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedAtKey(accountId));
    Logger.logMessage(
      'Cleared NEW_LIVE intro completedAt for account=$accountId',
      name: 'IntroAudioPolicy',
    );
  }

  Future<void> fetch() async {
    try {
      final response = await _getIntroAudioSettingsUsecase.call(NoParams());
      if (response.data != null && response.error == null) {
        _settings = response.data;
        _collectionStep = response.data!.parsedCollectionStep;
        Logger.logMessage(
          'Intro audio collectionStep=${_collectionStep.apiValue} '
          'enabled=$enabled source=$source variant=$variant',
          name: 'IntroAudioPolicy',
        );
        return;
      }
    } catch (e) {
      Logger.logMessage(
        'Failed to fetch intro audio settings: $e',
        name: 'IntroAudioPolicy',
      );
    }
    _settings = null;
    _collectionStep = IntroAudioCollectionStep.probation;
  }
}
