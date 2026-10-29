import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/data/models/rewards/my_rank.dart';
import 'package:voiceclub_partner/data/models/rewards/ranks.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';

class MultiRewardsTable extends StatelessWidget {
  final List<Ranks> rankings;
  final MyRank? myRank;
  final String? headerString;
  final Rewards reward;

  const MultiRewardsTable({
    super.key,
    required this.rankings,
    required this.myRank,
    required this.headerString,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.hardEdge,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(1.0),
                1: FlexColumnWidth(1.0),
                2: FlexColumnWidth(4.0),
                3: FlexColumnWidth(2.0),
                4: FlexColumnWidth(2.0),
              },
              children: <TableRow>[
                _buildTableRow(
                  index: 0,
                  avatarUrl: '',
                  name: '',
                  value: 0,
                  reward: 0,
                  headerString: headerString ?? " ",
                  header: true,
                ),
                for (final ranking in rankings)
                  _buildTableRow(
                    index: (ranking.rank ?? 0).toInt(),
                    avatarUrl:
                        ranking.user?.avatar ??
                        AvatarService.getRandomAvatarUrl(),
                    name: ranking.user?.name ?? 'Anon',
                    value: (ranking.value ?? 0),
                    reward: (ranking.rewardAmount ?? 0),
                    headerString: headerString ?? " ",
                    header: false,
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
            visible: myRank != null,
            child: Container(
              height: 66.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (reward.colorCodeDark ?? "").toColor(),
                    (reward.colorCodeSecondary ?? "").toColor(),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: _buildMyRankTableRow(
                index: (myRank?.rank ?? -1).toInt(),
                avatarUrl: myRank?.user?.avatar,
                name: myRank?.user?.name ?? 'Myself',
                value: (myRank?.value ?? 0),
                reward: (myRank?.rewardAmount ?? 0),
                headerString: headerString ?? " ",
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyRankTableRow({
    required int index,
    required String? avatarUrl,
    required String name,
    required num value,
    required num reward,
    required String headerString,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              index.toString(),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: CustomProfilePicture(
            avatarURL: avatarUrl,
            name: name,
            radius: 16.0,
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              maxLines: 1,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    headerString,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSize.S,
                    ),
                  ),
                ),
                Text(
                  Formatter.formatNumValue(value),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Reward",
                    style: TextStyle(color: Colors.white, fontSize: FontSize.S),
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetConstants.coinIc,
                      height: 20.0,
                      width: 20.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      Formatter.formatNumValue(reward),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow({
    required int index,
    required String? avatarUrl,
    required String name,
    required num value,
    required String headerString,
    required num reward,
    bool header = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            header
                ? const Border(
                  bottom: BorderSide(color: Colors.black12, width: 0.5),
                )
                : null,
      ),
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            child: Text(
              header ? ' ' : index.toString(),
              maxLines: header ? 2 : 1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        header
            ? const SizedBox()
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: CustomProfilePicture(
                avatarURL: avatarUrl,
                name: name,
                radius: 16.0,
              ),
            ),
        Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            child: Text(
              header ? ' ' : name,
              maxLines: header ? 2 : 1,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: header ? 4.0 : 8.0,
            vertical: 8.0,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              header
                  ? (headerString.capitalizeFirst ?? "")
                  : Formatter.formatNumValue(value),
              maxLines: header ? 2 : 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: header ? 11.0 : 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: header ? 4.0 : 8.0,
            vertical: 8.0,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Visibility(
              visible: header,
              replacement: Row(
                children: [
                  SvgPicture.asset(
                    AssetConstants.coinIc,
                    height: 20.0,
                    width: 20.0,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    Formatter.formatNumValue(reward),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              child: const Text(
                'Reward',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
