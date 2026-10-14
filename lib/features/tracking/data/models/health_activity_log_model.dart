class HealthActivityLogModel {
  final int id;
  final String memberUid;
  final String title;
  final String category; // 'medicine' | 'checkup' | 'activity' | 'vitals' | 'other'
  final String status; // 'completed' | 'late' | 'missed' | 'pending'
  final String detail;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final String? memberName;
  final String? memberAvatar;

  const HealthActivityLogModel({
    required this.id,
    required this.memberUid,
    required this.title,
    this.category = 'medicine',
    this.status = 'completed',
    this.detail = '',
    required this.scheduledAt,
    this.completedAt,
    this.memberName,
    this.memberAvatar,
  });

  factory HealthActivityLogModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedScheduled;
    try {
      final raw = json['scheduled_at']?.toString() ?? '';
      parsedScheduled = raw.isNotEmpty ? DateTime.parse(raw) : DateTime.now();
    } catch (_) {
      parsedScheduled = DateTime.now();
    }

    DateTime? parsedCompleted;
    if (json['completed_at'] != null) {
      parsedCompleted = DateTime.tryParse('${json['completed_at']}');
    }

    final memberMap = json['member_user'] is Map
        ? Map<String, dynamic>.from(json['member_user'] as Map)
        : null;

    return HealthActivityLogModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      memberUid: json['member_uid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'medicine',
      status: json['status']?.toString() ?? 'completed',
      detail: json['detail']?.toString() ?? '',
      scheduledAt: parsedScheduled,
      completedAt: parsedCompleted,
      memberName: memberMap?['name']?.toString(),
      memberAvatar: memberMap?['avata']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_uid': memberUid,
      'title': title,
      'category': category,
      'status': status,
      'detail': detail,
      'scheduled_at': scheduledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
