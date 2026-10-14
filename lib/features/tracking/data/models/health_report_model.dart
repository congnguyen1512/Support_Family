import 'package:family_guard/features/tracking/data/models/health_activity_log_model.dart';

class HealthReportModel {
  final String memberUid;
  final String memberName;
  final String period; // 'today' | 'week' | 'month'
  final int totalReminders;
  final int completionRate;
  final int onTimeRate;
  final int lateRate;
  final int missedRate;
  final String onTimeChange;
  final String lateChange;
  final String missedChange;
  final List<HealthActivityLogModel> recentLogs;

  const HealthReportModel({
    required this.memberUid,
    required this.memberName,
    this.period = 'month',
    this.totalReminders = 0,
    this.completionRate = 95,
    this.onTimeRate = 95,
    this.lateRate = 3,
    this.missedRate = 2,
    this.onTimeChange = '+1%',
    this.lateChange = '-0.5%',
    this.missedChange = '-0.5%',
    this.recentLogs = const [],
  });

  factory HealthReportModel.fromJson(Map<String, dynamic> json) {
    final memberMap = json['member'] is Map
        ? Map<String, dynamic>.from(json['member'] as Map)
        : null;

    final logs = <HealthActivityLogModel>[];
    if (json['recent_logs'] is List) {
      for (final e in json['recent_logs'] as List) {
        if (e is Map) {
          logs.add(HealthActivityLogModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return HealthReportModel(
      memberUid: memberMap?['uid']?.toString() ?? '',
      memberName: memberMap?['name']?.toString() ?? 'Thành viên',
      period: json['period']?.toString() ?? 'month',
      totalReminders: json['total_reminders'] is int
          ? json['total_reminders'] as int
          : int.tryParse('${json['total_reminders']}') ?? 0,
      completionRate: json['completion_rate'] is int
          ? json['completion_rate'] as int
          : int.tryParse('${json['completion_rate']}') ?? 95,
      onTimeRate: json['on_time_rate'] is int
          ? json['on_time_rate'] as int
          : int.tryParse('${json['on_time_rate']}') ?? 95,
      lateRate: json['late_rate'] is int
          ? json['late_rate'] as int
          : int.tryParse('${json['late_rate']}') ?? 3,
      missedRate: json['missed_rate'] is int
          ? json['missed_rate'] as int
          : int.tryParse('${json['missed_rate']}') ?? 2,
      onTimeChange: json['on_time_change']?.toString() ?? '+1%',
      lateChange: json['late_change']?.toString() ?? '-0.5%',
      missedChange: json['missed_change']?.toString() ?? '-0.5%',
      recentLogs: logs,
    );
  }
}
