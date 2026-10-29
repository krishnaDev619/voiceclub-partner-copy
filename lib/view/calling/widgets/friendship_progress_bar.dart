import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';

class FriendshipProgressBar extends StatefulWidget {
  const FriendshipProgressBar({
    super.key,
    required this.callModel,
    required this.seconds,
    required this.width,
  });

  final CallModel? callModel;
  final double width;
  final int seconds;

  @override
  State<FriendshipProgressBar> createState() => _FriendshipProgressBarState();
}

class _FriendshipProgressBarState extends State<FriendshipProgressBar> {
  num limitFriend = 0;
  num limitGoodFriend = 0;
  num limitBestFriend = 0;
  num totalDurationSeconds = 0;
  double barValue = 0.0;

  @override
  void initState() {
    limitFriend = widget.callModel?.limitFriend ?? 0;
    limitGoodFriend = widget.callModel?.limitGoodFriend ?? 0;
    limitBestFriend = widget.callModel?.limitBestFriend ?? 0;
    totalDurationSeconds = widget.callModel?.totalDurationSeconds ?? 0;
    _calculateBarValue();
    super.initState();
  }

  void _calculateBarValue() {
    if ((widget.callModel?.totalDurationSeconds ?? 0) >= limitBestFriend) {
      barValue = 1.0;
    } else {
      final currentTotalDuration = totalDurationSeconds + widget.seconds;
      final value = currentTotalDuration / limitBestFriend;
      if (value > 1.0) {
        barValue = 1.0;
      } else if (value < 0.0) {
        barValue = 0.0;
      } else {
        barValue = value;
      }
    }
  }

  Color getBarColor() {
    final friendValue = limitFriend / limitBestFriend;
    final goodFriendValue = limitGoodFriend / limitBestFriend;
    if (barValue <= (friendValue)) {
      return const Color(0xFFC2DEF3);
    } else if (barValue <= (goodFriendValue)) {
      return const Color(0xFF67B3EA);
    } else {
      return const Color(0xFF1F679C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendValue = limitFriend / limitBestFriend;
    final goodFriendValue = limitGoodFriend / limitBestFriend;
    final friendFlex = limitFriend.toInt();
    final goodFriendFlex = (limitGoodFriend - limitFriend).toInt();
    final bestFriendFlex = (limitBestFriend - limitGoodFriend).toInt();
    if ((friendValue.isFinite) &&
        (goodFriendValue.isFinite) &&
        (limitBestFriend > limitGoodFriend) &&
        (limitGoodFriend > limitFriend)) {
      const barHeight = 10.0;
      final barBackgroundColor = const Color(
        0xFFBABABA,
      ).withValues(alpha: 0.25);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.width,
                alignment: Alignment.center,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: widget.width,
                      height: barHeight,
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: LinearProgressIndicator(
                        value: barValue,
                        color: getBarColor(),
                        minHeight: 8.0,
                        backgroundColor: barBackgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: friendFlex,
                          child: Container(
                            height: barHeight,
                            color:
                                (barValue >= friendValue)
                                    ? const Color(0xFFC2DEF3)
                                    : barBackgroundColor,
                          ),
                        ),
                        Expanded(
                          flex: goodFriendFlex,
                          child: Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color:
                                  (barValue >= goodFriendValue)
                                      ? const Color(0xFF67B3EA)
                                      : barBackgroundColor,
                              border: const Border.symmetric(
                                vertical: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: bestFriendFlex,
                          child: Container(
                            height: barHeight,
                            color:
                                (barValue >= (1.0))
                                    ? const Color(0xFF1F679C)
                                    : barBackgroundColor,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment:
                          Alignment.lerp(
                            Alignment.centerLeft,
                            Alignment.centerRight,
                            barValue,
                          ) ??
                          Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: getBarColor(),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          height: barHeight + 4.0,
                          width: barHeight + 4.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getBarColor(),
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Expanded(
                    flex: friendFlex,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Friend",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSize.M,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: goodFriendFlex,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Good Friend",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSize.M,
                          color:
                              (barValue >= friendValue)
                                  ? Colors.black
                                  : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: bestFriendFlex,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Best Friend",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSize.M,
                          color:
                              (barValue >= goodFriendValue)
                                  ? Colors.black
                                  : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
