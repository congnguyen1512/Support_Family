import 'package:flutter/material.dart';

enum SafeZoneType {
  home('Nha', Icons.home_rounded, Color(0xFFEFF6FF), Color(0xFF3B82F6)),
  school('Truong hoc', Icons.school_rounded, Color(0xFFFFFBEB), Color(0xFFD97706)),
  hospital('Benh vien', Icons.local_hospital_rounded, Color(0xFFFFF1F2), Color(0xFFF43F5E)),
  custom('Tuy chinh', Icons.tune_rounded, Color(0xFFF8FAFC), Color(0xFF64748B));

  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  const SafeZoneType(this.label, this.icon, this.bgColor, this.iconColor);
}

class AlertConfig {
  final bool leaveAlert;
  final bool enterAlert;
  final bool stayLongAlert;
  final bool pushEnabled;
  final bool smsEnabled;
  final bool callEnabled;
  final int urgencyLevel;

  const AlertConfig({
    this.leaveAlert = true,
    this.enterAlert = true,
    this.stayLongAlert = false,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.callEnabled = false,
    this.urgencyLevel = 1,
  });

  AlertConfig copyWith({
    bool? leaveAlert,
    bool? enterAlert,
    bool? stayLongAlert,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? callEnabled,
    int? urgencyLevel,
  }) {
    return AlertConfig(
      leaveAlert: leaveAlert ?? this.leaveAlert,
      enterAlert: enterAlert ?? this.enterAlert,
      stayLongAlert: stayLongAlert ?? this.stayLongAlert,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      callEnabled: callEnabled ?? this.callEnabled,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
    );
  }
}

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> activeDays;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    this.activeDays = const [1, 2, 3, 4, 5],
  });

  String get label => '${_fmt(startTime)} - ${_fmt(endTime)}';

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeSlot copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<int>? activeDays,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activeDays: activeDays ?? this.activeDays,
    );
  }
}

class AlertRecipient {
  final String id;
  final String name;
  final String initials;
  final Color color;
  bool isSelected;

  AlertRecipient({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
    this.isSelected = false,
  });
}

class SafeZone {
  final String id;
  final String? ownerUid;
  final String? targetUid;
  String name;
  String address;
  double latitude;
  double longitude;
  double radius;
  SafeZoneType zoneType;
  bool isActive;
  bool timeBasedEnabled;
  List<TimeSlot> timeSlots;
  AlertConfig alertConfig;
  List<String> recipientIds;
  DateTime createdAt;
  DateTime updatedAt;

  SafeZone({
    required this.id,
    this.ownerUid,
    this.targetUid,
    required this.name,
    this.address = '',
    this.latitude = 10.7769,
    this.longitude = 106.7009,
    this.radius = 500,
    this.zoneType = SafeZoneType.home,
    this.isActive = true,
    this.timeBasedEnabled = true,
    List<TimeSlot>? timeSlots,
    this.alertConfig = const AlertConfig(),
    this.recipientIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : timeSlots = timeSlots ??
            [
              const TimeSlot(
                startTime: TimeOfDay(hour: 8, minute: 0),
                endTime: TimeOfDay(hour: 18, minute: 0),
              ),
            ],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  SafeZone copyWith({
    String? id,
    String? ownerUid,
    String? targetUid,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? radius,
    SafeZoneType? zoneType,
    bool? isActive,
    bool? timeBasedEnabled,
    List<TimeSlot>? timeSlots,
    AlertConfig? alertConfig,
    List<String>? recipientIds,
  }) {
    return SafeZone(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      targetUid: targetUid ?? this.targetUid,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      zoneType: zoneType ?? this.zoneType,
      isActive: isActive ?? this.isActive,
      timeBasedEnabled: timeBasedEnabled ?? this.timeBasedEnabled,
      timeSlots: timeSlots ?? this.timeSlots,
      alertConfig: alertConfig ?? this.alertConfig,
      recipientIds: recipientIds ?? this.recipientIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  double get centerLatitude => latitude;
  double get centerLongitude => longitude;
  int get radiusMeters => radius.round();
}

class SafeZoneMember {
  final String id;
  final String name;
  final String role;
  final String ageGroup;
  final Color badgeColor;
  final Color badgeBorderColor;
  final Color badgeTextColor;
  final String avatarUrl;
  final bool isOnline;
  final List<String> zoneIds;

  const SafeZoneMember({
    required this.id,
    required this.name,
    this.role = '',
    required this.ageGroup,
    required this.badgeColor,
    required this.badgeBorderColor,
    required this.badgeTextColor,
    this.avatarUrl = '',
    this.isOnline = true,
    this.zoneIds = const [],
  });

  int get zoneCount => zoneIds.length;

  SafeZoneMember copyWith({
    String? id,
    String? name,
    String? role,
    String? ageGroup,
    Color? badgeColor,
    Color? badgeBorderColor,
    Color? badgeTextColor,
    String? avatarUrl,
    bool? isOnline,
    List<String>? zoneIds,
  }) {
    return SafeZoneMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      ageGroup: ageGroup ?? this.ageGroup,
      badgeColor: badgeColor ?? this.badgeColor,
      badgeBorderColor: badgeBorderColor ?? this.badgeBorderColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      zoneIds: zoneIds ?? this.zoneIds,
    );
  }
}
