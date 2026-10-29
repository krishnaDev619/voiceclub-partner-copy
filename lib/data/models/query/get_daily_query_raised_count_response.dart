class GetDailyQueryRaisedCountResponse {
  final int? dailyQueryRaisedCount;
  final int? dailyQueryLimit;
  const GetDailyQueryRaisedCountResponse({
    required this.dailyQueryRaisedCount,
    required this.dailyQueryLimit,
  });

  factory GetDailyQueryRaisedCountResponse.fromJson(Map<String, dynamic> data) {
    return GetDailyQueryRaisedCountResponse(
      dailyQueryRaisedCount: data['sessions_raised'] as int?,
      dailyQueryLimit: data['allowed_session_count'] as int?,
    );
  }
}
