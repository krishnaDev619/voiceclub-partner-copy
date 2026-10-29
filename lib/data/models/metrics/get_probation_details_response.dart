import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/course/remote/lesson_dto.dart';
import 'package:voiceclub_partner/data/models/metrics/probation_cutoff.dart';
import 'package:voiceclub_partner/data/models/metrics/probation_stat.dart';

class GetProbationDetailsResponseModel {
  final bool? videoWatched;
  final PartnerCurrentStatus? stage;
  final List<ProbationStat>? stats;
  final ProbationCutoff? cutoff;
  final List<LessonDto>? tutorials;

  GetProbationDetailsResponseModel({
    this.videoWatched,
    this.stage,
    this.stats,
    this.cutoff,
    this.tutorials,
  });

  GetProbationDetailsResponseModel.fromJson(Map<String, dynamic> json)
    : videoWatched = json['video_watched'] as bool?,
      stage = (json['stage'] as String? ?? "").toPartnerCurrentStatus(),
      stats =
          (json['stats'] as List?)
              ?.map(
                (dynamic e) =>
                    ProbationStat.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      cutoff =
          (json['cutoff'] as Map<String, dynamic>?) != null
              ? ProbationCutoff.fromJson(json['cutoff'] as Map<String, dynamic>)
              : null,
      tutorials =
          (json['tutorials'] as List?)
              ?.map(
                (dynamic e) => LessonDto.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'video_watched': videoWatched,
    'stage': stage?.name,
    'stats': stats?.map((e) => e.toJson()).toList(),
    'cutoff': cutoff?.toJson(),
    'tutorials': tutorials?.map((e) => e.toJson()).toList(),
  };

  List<ProbationStat> get sortedAndFilledStats {
    Logger.logMessage("ENTERING sortedAndFilledStats", name: "probation");
    final resultStats = <ProbationStat>[];
    try {
      // If stats is null or empty, return 7 empty models starting from today.
      if (stats?.isEmpty ?? true) {
        return List.generate(7, (index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          return ProbationStat(date: DateFormat('yyyy-MM-dd').format(date));
        });
      } else {
        // Sort the existing stats by date in ascending order.
        final sortedStats =
            stats!.where((stat) => stat.date != null).toList()
              ..sort((a, b) => a.dateAsDateTime!.compareTo(b.dateAsDateTime!));
        // Find the LAST (most recent) date in stats
        final latestDate = sortedStats.last.dateAsDateTime!;
        // Generate 7 dates starting from (LAST - 6 days) to LAST
        final startDate = latestDate.subtract(const Duration(days: 6));

        for (int i = 0; i < 7; i++) {
          final currentDate = startDate.add(Duration(days: i));
          final dateString = DateFormat('yyyy-MM-dd').format(currentDate);

          // Check if an entry exists for the current date
          final existingStat = sortedStats.firstWhereOrNull((stat) {
            final statDate = stat.dateAsDateTime;
            return statDate?.year == currentDate.year &&
                statDate?.month == currentDate.month &&
                statDate?.day == currentDate.day;
          });
          if (existingStat != null) {
            // If an entry exists, use it
            resultStats.add(existingStat);
          } else {
            // If no entry exists, create a new ProbationStat with the current date
            resultStats.add(ProbationStat(date: dateString));
          }
        }
        return resultStats;
      }
    } catch (_) {
      return resultStats;
    }
  }
}
