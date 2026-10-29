import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/data/models/metrics/probation_stat.dart';

class MeetingAttendance {
  final DateTime date;
  final bool? isPresent;

  MeetingAttendance({required this.date, required this.isPresent});
}

class MeetingAttendanceWidget extends StatelessWidget {
  final List<ProbationStat> stats;

  const MeetingAttendanceWidget({super.key, required this.stats});

  // Function to convert the list of stats to a list of MeetingAttendance objects
  List<MeetingAttendance> get attendanceData {
    List<MeetingAttendance> attendanceList = [];
    try {
      for (var stat in stats) {
        if (stat.dateAsDateTime != null) {
          attendanceList.add(
            MeetingAttendance(
              date: stat.dateAsDateTime!,
              isPresent: stat.meetingAttended,
            ),
          );
        }
      }
    } catch (_) {
      // Handle the error, maybe log it or set a state indicating an error occurred
    }
    return attendanceList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8.0, spreadRadius: 2.0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Meeting Attendance',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
          SizedBox(
            height: 88.0,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              scrollDirection: Axis.horizontal,
              itemCount: attendanceData.length,
              itemBuilder: (context, index) {
                return _buildAttendanceCard(attendanceData[index]);
              },
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(MeetingAttendance attendance) {
    return Container(
      width: 60.0,
      margin: const EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('dd MMM').format(attendance.date),
            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          const SizedBox(height: 4.0),
          CircleAvatar(
            radius: 20.0,
            backgroundColor:
                attendance.isPresent == null
                    ? Colors.grey.shade400
                    : (attendance.isPresent ?? false)
                    ? Colors.green
                    : Colors.red,
            child:
                attendance.isPresent == null
                    ? null
                    : Icon(
                      (attendance.isPresent ?? false)
                          ? Icons.check
                          : Icons.close,
                      color: Colors.white,
                    ),
          ),
          const SizedBox(height: 4.0),
          Text(
            DateFormat('EEE').format(attendance.date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
