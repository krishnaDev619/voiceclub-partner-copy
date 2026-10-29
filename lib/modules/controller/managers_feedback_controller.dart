import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/manager_feedback_model.dart';
import 'package:voiceclub_partner/domain/usecases/managers_feedback/get_managers_feedback.dart';
import 'package:voiceclub_partner/domain/usecases/managers_feedback/update_managers_feedback_status.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:volume_controller/volume_controller.dart';

class ManagersFeedbackController extends GetxController {
  final managersFeedbackList = <ManagerFeedbackModel>[].obs;
  RxMap<int, bool> managersFeedbackMap = <int, bool>{}.obs;
  final _getManagersFeedbackUseCase = sl<GetManagersFeedbackUseCase>();
  final _updateManagersFeedbackStatusUseCase =
      sl<UpdateManagersFeedbackStatusUseCase>();

  RxBool isLoading = true.obs;

  // Audio Player Management
  RxMap<String, PlayerController> playerControllersMap =
      <String, PlayerController>{}.obs;

  // The path of current player which is being played
  var currentPlayerPath = "".obs;

  Worker? callListener;

  @override
  Future<void> onInit() async {
    await getManagersFeedback();
    isLoading.value = false;
    registerCallListener();
    super.onInit();
  }

  @override
  void onClose() {
    callListener?.dispose();
    super.onClose();
  }

  void registerCallListener() {
    callListener = ever(sl<CallController>().incomingCallPayload, (
      callPayload,
    ) {
      if (callPayload.isNotEmpty) {
        pauseAllPlayers();
      }
    });
  }

  bool get isPendingFeedbackAvailable =>
      managersFeedbackList.isNotEmpty &&
      managersFeedbackList.any((feedback) => feedback.addressed == false);

  int get pendingFeedbackCount =>
      managersFeedbackList
          .where((feedback) => feedback.addressed == false)
          .length;

  Future<void> getManagersFeedback() async {
    final response = await _getManagersFeedbackUseCase.call(
      Params(page: 1, pageSize: 10),
    );
    if (response.data != null) {
      managersFeedbackList.clear();
      managersFeedbackList.value = response.data?.feedbacks ?? [];
      managersFeedbackList.refresh();

      managersFeedbackMap.clear();
      for (var feedback in managersFeedbackList) {
        if (feedback.id != null) {
          managersFeedbackMap[feedback.id!] = false;
        }
      }
    }
  }

  Future<void> updateManagersFeedbackStatus(int id) async {
    final response = await _updateManagersFeedbackStatusUseCase.call(
      UpdateManagersFeedbackParams(id: id),
    );
    sl<AnalyticsService>().trackEvent("feedbackAcknowledged");
    if (response.data != null) {
      getManagersFeedback();
    }
  }

  Future<void> enableIUnderstandButton(int id) async {
    final addressed =
        managersFeedbackList
            .where((element) => element.id == id)
            .first
            .addressed;
    if (addressed == false) {
      managersFeedbackMap[id] = true;
      managersFeedbackMap.refresh();
    }
  }

  /// Call this method everytime when you want to play or pause the player
  Future<void> stopAndStartPlayer({required String playerKey}) async {
    final currentController = playerControllersMap[currentPlayerPath.value];

    if (playerKey == currentPlayerPath.value) {
      // Toggle play/pause on the current player
      if (currentController != null) {
        if (currentController.playerState.isPlaying) {
          currentController.pausePlayer();
        } else {
          currentController.startPlayer();
        }
      }
      return;
    }

    pauseAllPlayers();

    // Start the selected player
    final selectedController = playerControllersMap[playerKey];
    if (selectedController != null) {
      // Check and update device's volume if less than 20%
      final volumeController = VolumeController.instance;
      await volumeController.setVolume(1.0);
      selectedController.startPlayer();
      currentPlayerPath.value = playerKey;
    } else {
      currentPlayerPath.value = "";
    }
  }

  // Pause all players if they are playing
  void pauseAllPlayers() {
    try {
      for (var controller in playerControllersMap.values) {
        if (controller.playerState.isPlaying) {
          controller.pausePlayer();
        }
      }
    } catch (_) {}
  }
}
