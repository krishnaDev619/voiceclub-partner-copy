import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:get/get.dart';

class UploadAudioBottomSheetController extends GetxController {
  RxMap<String, PlayerController> playerControllersMap =
      <String, PlayerController>{}.obs;

  //The path of current player which is being played
  var currentPlayerPath = "".obs;

  /// Call this method everytime when you want to play or pause the player
  void stopAndStartPlayer(String playerKey) {
    if (playerKey == currentPlayerPath.value) {
      final playerController = playerControllersMap[playerKey];
      if (playerController!.playerState.isPlaying) {
        playerController.pausePlayer();
      } else {
        playerController.startPlayer();
      }
      return;
    }

    for (var controller in playerControllersMap.values) {
      controller.pausePlayer();
    }

    final playerController = playerControllersMap[playerKey];
    playerController?.startPlayer();
    currentPlayerPath.value = playerController?.playerKey ?? "";
  }
}
