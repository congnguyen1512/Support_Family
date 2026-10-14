import 'package:flutter/material.dart';

class ReminderModel {
  ReminderModel({
    required this.id,
    required this.ownerUid,
    required this.memberUid,
    required this.title,
    this.subtitle,
    required this.category,
    required this.reminderTime,
    required this.scheduleType,
    this.scheduleDate,
    required this.weekdays,
    required this.isActive,
    this.voiceUrl,
    this.memberName,
    this.memberAvatar,
  });

  final int id;
  final String ownerUid;
  final String memberUid;
  final String title;
  final String? subtitle;
  final String category; // 'medicine' | 'food' | 'health' | 'other'
  final String reminderTime; // '08:00'
  final String scheduleType; // 'daily' | 'weekly' | 'once' | 'custom'
  final String? scheduleDate;
  final List<int> weekdays;
  bool isActive;
  final String? voiceUrl;
  final String? memberName;
  final String? memberAvatar;

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    final memberUser = json['member_user'] is Map
        ? Map<String, dynamic>.from(json['member_user'] as Map)
        : null;

    final rawWeekdays = json['weekdays'];
    final parsedWeekdays = <int>[];
    if (rawWeekdays is List) {
      for (final w in rawWeekdays) {
        if (w is num) parsedWeekdays.add(w.toInt());
      }
    }

    return ReminderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      ownerUid: json['owner_uid']?.toString() ?? '',
      memberUid: json['member_uid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      category: json['category']?.toString() ?? 'other',
      reminderTime: json['reminder_time']?.toString() ?? '08:00',
      scheduleType: json['schedule_type']?.toString() ?? 'daily',
      scheduleDate: json['schedule_date']?.toString(),
      weekdays: parsedWeekdays,
      isActive: json['is_active'] == true,
      voiceUrl: json['voice_url']?.toString(),
      memberName: memberUser?['name']?.toString(),
      memberAvatar: memberUser?['avata']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_uid': ownerUid,
      'member_uid': memberUid,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'reminder_time': reminderTime,
      'schedule_type': scheduleType,
      'schedule_date': scheduleDate,
      'weekdays': weekdays,
      'is_active': isActive,
      'voice_url': voiceUrl,
    };
  }

  String get formattedTime {
    final time = reminderTime.isNotEmpty ? reminderTime : '08:00';
    switch (scheduleType) {
      case 'daily':
        return '$time - Mỗi ngày';
      case 'weekly':
        return '$time - Hàng tuần';
      case 'once':
        return scheduleDate != null && scheduleDate!.isNotEmpty
            ? '$time - Ngày $scheduleDate'
            : '$time - Một lần';
      case 'custom':
        return '$time - Tùy chỉnh';
      default:
        return '$time - Mỗi ngày';
    }
  }

  IconData get icon {
    switch (category) {
      case 'medicine':
        return Icons.medication_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'health':
        return Icons.favorite_rounded;
      default:
        return Icons.alarm_rounded;
    }
  }

  Color get iconColor {
    switch (category) {
      case 'medicine':
        return const Color(0xFFE84C6F);
      case 'food':
        return const Color(0xFFF5A623);
      case 'health':
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFF00ACB2);
    }
  }

  Color get iconBgColor {
    switch (category) {
      case 'medicine':
        return const Color(0x33FF85A1);
      case 'food':
        return const Color(0x33FFD166);
      case 'health':
        return const Color(0x33118AB2);
      default:
        return const Color(0x2600ACB2);
    }
  }
}
