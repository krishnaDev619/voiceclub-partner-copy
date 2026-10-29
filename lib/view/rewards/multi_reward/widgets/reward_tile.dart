import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/multi_reward_screen.dart';

class RewardTile extends StatelessWidget {
  final Rewards ds;

  const RewardTile({super.key, required this.ds});

  String getFormattedDate(DateTime date) {
    final formattedDate = DateFormat("dd/MM/yyyy").format(date);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => MultiRewardScreen(ds: ds));
      },
      child: Container(
        height: 140.0,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: (ds.colorCode ?? "").toColor(),
          boxShadow: [
            BoxShadow(
              offset: const Offset(4, 4),
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2.0,
            ),
            BoxShadow(
              offset: const Offset(-4, -4),
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2.0,
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 8.0,
          top: 8.0,
          bottom: 8.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    ds.name ?? "",
                    style: const TextStyle(
                      fontWeight: Weight.heavy,
                      color: Colors.black,
                      fontSize: FontSize.xXL,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                  Flexible(
                    child: Text(
                      ds.description ?? "",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: FontSize.L,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Visibility(
                      visible: ds.endsOn != null,
                      child: Text(
                        "End Date : ${getFormattedDate(ds.endsOn ?? DateTime.now())}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: FontSize.M,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4.0),
            SizedBox(
              width: 90.0,
              height: 110.0,
              child: SvgPicture.network(ds.imageUrl ?? "", fit: BoxFit.contain),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (ds.colorCodeDark ?? "").toColor().withValues(
                    alpha: 0.3,
                  ),
                ),
                padding: const EdgeInsets.all(4.0),
                child: const Icon(Icons.chevron_right, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
