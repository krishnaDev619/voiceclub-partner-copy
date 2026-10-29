import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final bool? allowFullScreen;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.allowFullScreen = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _initializeChewieController();
  }

  void _initializeChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 9 / 16,
      allowFullScreen: widget.allowFullScreen ?? true,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
      showOptions: false,
      allowPlaybackSpeedChanging: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFEE6464),
        bufferedColor: const Color(0xFFCCCCCC),
        handleColor: const Color(0xFFEE6464),
        backgroundColor: const Color(0xFF606060),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: Get.height,
              width: Get.width,
              child: Center(
                child: Chewie(key: UniqueKey(), controller: _chewieController),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.close, size: 30.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
