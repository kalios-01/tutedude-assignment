class SessionHistory {
  final String date; // YYYY-MM-DD format
  final List<int> sessions; // List of session durations in seconds
  final int totalDuration; // Total duration in seconds for the day

  SessionHistory({
    required this.date,
    required this.sessions,
    required this.totalDuration,
  });

  factory SessionHistory.fromTodaySessions(String date, List<int> sessions) {
    final totalDuration = sessions.fold(0, (prev, curr) => prev + curr);
    return SessionHistory(
      date: date,
      sessions: List<int>.from(sessions),
      totalDuration: totalDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sessions': sessions,
      'totalDuration': totalDuration,
    };
  }

  factory SessionHistory.fromJson(Map<String, dynamic> json) {
    return SessionHistory(
      date: json['date'] as String,
      sessions: List<int>.from(json['sessions'] as List),
      totalDuration: json['totalDuration'] as int,
    );
  }
} 