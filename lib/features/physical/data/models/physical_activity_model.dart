class PhysicalActivityModel {
  final int id;
  final String ownerUid;
  final String memberUid;
  final String name;
  final String activityType; // 'walking' | 'running' | 'cycling' | 'yoga' | 'swimming' | 'other'
  final int durationMin;
  final String activityTime;
  final List<int> repeatDays;
  final bool enabled;
  final String? memberName;
  final String? memberAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PhysicalActivityModel({
    required this.id,
    required this.ownerUid,
    required this.memberUid,
    required this.name,
    this.activityType = 'walking',
    this.durationMin = 30,
    required this.activityTime,
    this.repeatDays = const [1, 2, 3, 4, 5],
    this.enabled = true,
    this.memberName,
    this.memberAvatar,
    this.createdAt,
    this.updatedAt,
  });

  factory PhysicalActivityModel.fromJson(Map<String, dynamic> json) {
    final memberMap = json['member_user'] is Map
        ? Map<String, dynamic>.from(json['member_user'] as Map)
        : null;

    final daysList = <int>[];
    if (json['repeat_days'] is List) {
      for (final e in json['repeat_days'] as List) {
        final val = int.tryParse('$e');
        if (val != null) daysList.add(val);
      }
    }

    return PhysicalActivityModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      ownerUid: json['owner_uid']?.toString() ?? '',
      memberUid: json['member_uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      activityType: json['activity_type']?.toString() ?? 'walking',
      durationMin: json['duration_min'] is int
          ? json['duration_min'] as int
          : int.tryParse('${json['duration_min']}') ?? 30,
      activityTime: json['activity_time']?.toString() ?? '06:30',
      repeatDays: daysList.isNotEmpty ? daysList : const [1, 2, 3, 4, 5],
      enabled: json['enabled'] as bool? ?? true,
      memberName: memberMap?['name']?.toString(),
      memberAvatar: memberMap?['avata']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse('${json['updated_at']}') : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_uid': ownerUid,
      'member_uid': memberUid,
      'name': name,
      'activity_type': activityType,
      'duration_min': durationMin,
      'activity_time': activityTime,
      'repeat_days': repeatDays,
      'enabled': enabled,
    };
  }
}
