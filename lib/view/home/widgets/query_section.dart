import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';

class QuerySection extends StatelessWidget {
  const QuerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10.0,
      bottom: 10.0,
      child: GestureDetector(
        onTap: () {
          Get.find<QueriesController>().navigateToQueryChatScreenFromHome(
            source: "QuerySection",
          );
        },
        child: SvgPicture.asset(AssetConstants.queryIc),
      ),
    );
  }
}
