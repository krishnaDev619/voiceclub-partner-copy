import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/modules/controller/probation_course_controller.dart';
import 'package:voiceclub_partner/view/course/widgets/chapter_tile.dart';

class ProbationVideoWidget extends GetView<ProbationCourseController> {
  const ProbationVideoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: UniqueKey(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: controller.chapters.length,
      itemBuilder: (context, index) {
        return ChapterTile(key: UniqueKey(), index: index);
      },
    );
  }
}
