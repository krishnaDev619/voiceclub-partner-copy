// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
// import 'package:voiceclub_partner/data/models/course/lesson.dart';
// import 'package:voiceclub_partner/modules/controller/course_controller.dart';

// class CourseVideoPlayerScreen extends StatefulWidget {
//   final VideoPlayerController videoPlayerController;
//   final Lesson lesson;
//   final int chapterId;

//   const CourseVideoPlayerScreen({
//     super.key,
//     required this.videoPlayerController,
//     required this.lesson,
//     required this.chapterId,
//   });

//   @override
//   State<CourseVideoPlayerScreen> createState() =>
//       _CourseVideoPlayerScreenState();
// }

// class _CourseVideoPlayerScreenState extends State<CourseVideoPlayerScreen> {
//   late ChewieController _chewieController;
//   final courseController = Get.find<CourseController>();
//   bool hasNavigatedBack = false;
//   bool showCountdown = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeChewieController();
//     widget.videoPlayerController.addListener(_videoListener);
//   }

//   void _initializeChewieController() {
//     _chewieController = ChewieController(
//       videoPlayerController: widget.videoPlayerController,
//       aspectRatio: 9 / 16,
//       allowFullScreen: false,
//       autoInitialize: true,
//       autoPlay: true,
//       looping: false,
//       showOptions: false,
//       allowPlaybackSpeedChanging: false,
//       materialProgressColors: ChewieProgressColors(
//         playedColor: const Color(0xFFEE6464),
//         bufferedColor: const Color(0xFFCCCCCC),
//         handleColor: const Color(0xFFEE6464),
//         backgroundColor: const Color(0xFF606060),
//       ),
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: Text(
//             errorMessage,
//             style: const TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//   }

//   void _videoListener() {
//     final position = widget.videoPlayerController.value.position;
//     final duration = widget.videoPlayerController.value.duration;
//     if (position >= duration) {
//       if (mounted) {
//         if (!hasNavigatedBack) {
//           hasNavigatedBack = true;
//           Get.back();
//         }
//       }
//     } else if (duration - position <= const Duration(seconds: 5) &&
//         !showCountdown) {
//       setState(() {
//         showCountdown = true;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     widget.videoPlayerController.removeListener(_videoListener);
//     widget.videoPlayerController.dispose();
//     _chewieController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) {
//           hasNavigatedBack = true;
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black54,
//         body: Container(
//           alignment: Alignment.center,
//           height: Get.height,
//           width: Get.width,
//           child: Center(
//             child: Chewie(
//               key: UniqueKey(),
//               controller: _chewieController,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
