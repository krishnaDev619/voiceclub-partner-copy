import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/domain/usecases/social/get_pending_post_status.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';

class PostStatusWidget extends StatefulWidget {
  final String postId;

  const PostStatusWidget({super.key, required this.postId});

  @override
  State<PostStatusWidget> createState() => _PostStatusWidgetState();
}

class _PostStatusWidgetState extends State<PostStatusWidget> {
  late Timer _timer;
  PostModerationStatus _status = PostModerationStatus.PENDING;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final result = await sl<GetPendingPostStatusUsecase>().call(
          GetPendingPostStatusParams(postId: widget.postId),
        );

        if (result is DataSuccess) {
          setState(() {
            _status =
                result.data!.moderationStatus ?? PostModerationStatus.PENDING;
            _errorMessage = result.data!.moderationComment;
          });

          if (_status != PostModerationStatus.PENDING) {
            timer.cancel();
            Future.delayed(
              Duration(
                seconds: _status == PostModerationStatus.REJECTED ? 10 : 5,
              ),
              () {
                if (mounted) {
                  Get.find<ExploreController>().hidePostStatus();
                }
              },
            );
          }
        } else {
          // If we get an errpr, it means the post is no longer pending
          // This can happen when the post is already accepted
          timer.cancel();
          if (mounted) {
            setState(() {
              _status = PostModerationStatus.ACCEPTED;
            });
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                Get.find<ExploreController>().hidePostStatus();
              }
            });
          }
        }
      } catch (e) {
        // If we get a 404, it means the post is no longer pending
        // This can happen when the post is already accepted
        timer.cancel();
        if (mounted) {
          setState(() {
            _status = PostModerationStatus.ACCEPTED;
          });
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              Get.find<ExploreController>().hidePostStatus();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Dummy post thumbnail
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.image, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 12),
          // Status and progress
          Expanded(
            child:
                _status == PostModerationStatus.PENDING
                    ? LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_status == PostModerationStatus.REJECTED &&
                            _errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: FontSize.S,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
          ),
          const SizedBox(width: 12),
          // Status icon
          _buildStatusIcon(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case PostModerationStatus.PENDING:
        return const SizedBox(width: 24, height: 24);
      case PostModerationStatus.ACCEPTED:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green[400],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        );
      case PostModerationStatus.REJECTED:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
        );
    }
  }

  String _getStatusText() {
    switch (_status) {
      case PostModerationStatus.PENDING:
        return 'Your Post was approved';
      case PostModerationStatus.ACCEPTED:
        return 'Post uploaded successfully';
      case PostModerationStatus.REJECTED:
        return 'Failed to upload post';
    }
  }
}
