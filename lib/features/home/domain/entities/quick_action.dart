import 'package:flutter/material.dart';

/// Model cho hành động nhanh
class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
