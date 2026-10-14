import 'package:flutter/material.dart';

/// Model cho tính năng nhắc nhở
class ReminderFeature {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const ReminderFeature({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}
