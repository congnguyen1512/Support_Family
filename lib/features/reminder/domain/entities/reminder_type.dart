import 'package:flutter/material.dart';

/// Model cho loại nhắc nhở trên màn hình Tạo lịch nhắc mới
class ReminderType {
  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const ReminderType({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
