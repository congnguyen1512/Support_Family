import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderNotificationItem {
  const ReminderNotificationItem({
    required this.id,
    required this.title,
    required this.reminderTime,
    this.subtitle,
  });

  final int id;
  final String title;
  final String reminderTime;
  final String? subtitle;
}

typedef KidReminderNotification = ReminderNotificationItem;

class ReminderNotificationScheduler {
  ReminderNotificationScheduler._();

  static final ReminderNotificationScheduler instance =
      ReminderNotificationScheduler._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final List<Timer> _timers = [];
  bool _initialized = false;

  Future<void> scheduleToday(List<ReminderNotificationItem> reminders) async {
    try {
      await _ensureInitialized();
    } catch (_) {
      return;
    }
    _clearTimers();

    final now = DateTime.now();
    for (final reminder in reminders) {
      final dueAt = _dueAtToday(reminder.reminderTime, now);
      if (dueAt == null || !dueAt.isAfter(now)) {
        continue;
      }

      _timers.add(
        Timer(dueAt.difference(now), () {
          _showReminder(reminder);
        }),
      );
    }
  }

  void dispose() {
    _clearTimers();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'family_guard_reminders',
      'Support Family Reminders',
      description: 'Nhắc nhở thuốc men, lịch hẹn và sinh hoạt gia đình',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<void> _showReminder(ReminderNotificationItem reminder) {
    final body = reminder.subtitle?.trim().isNotEmpty == true
        ? reminder.subtitle!.trim()
        : 'Đã đến giờ nhắc nhở của bạn (${reminder.reminderTime})';

    return _plugin.show(
      reminder.id,
      'Nhắc nhở: ${reminder.title}',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'family_guard_reminders',
          'Support Family Reminders',
          channelDescription: 'Nhắc nhở thuốc men, lịch hẹn và sinh hoạt gia đình',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  DateTime? _dueAtToday(String reminderTime, DateTime now) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})$',
    ).firstMatch(reminderTime.trim());
    if (match == null) {
      return null;
    }

    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void _clearTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }
}

typedef KidReminderNotificationScheduler = ReminderNotificationScheduler;
