import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/core/services/kid_reminder_notification_scheduler.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:flutter/material.dart';

class CheckinReminderKidReminderArgs {
  const CheckinReminderKidReminderArgs({
    required this.memberId,
    required this.memberName,
    required this.avatarUrl,
  });

  final String memberId;
  final String memberName;
  final String avatarUrl;
}

class CheckinReminderKidReminderScreen extends StatefulWidget {
  const CheckinReminderKidReminderScreen({super.key, required this.args});

  final CheckinReminderKidReminderArgs args;

  static CheckinReminderKidReminderArgs fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CheckinReminderKidReminderArgs) {
      return args;
    }
    return const CheckinReminderKidReminderArgs(
      memberId: '',
      memberName: 'Thành viên',
      avatarUrl: '',
    );
  }

  @override
  State<CheckinReminderKidReminderScreen> createState() =>
      _CheckinReminderKidReminderScreenState();
}

class _CheckinReminderKidReminderScreenState
    extends State<CheckinReminderKidReminderScreen> {
  late Future<List<_KidReminderItem>> _remindersFuture;
  bool _canManageReminders = false;

  @override
  void initState() {
    super.initState();
    _remindersFuture = _loadReminders();
    _remindersFuture.then(_scheduleNotificationsIfKid);
    _loadManagePermission();
  }

  Future<void> _loadManagePermission() async {
    final session = await AppDependencies.instance.authLocalDataSource
        .getSavedSession();
    final currentUserId = session?.userId.trim() ?? '';
    final memberId = widget.args.memberId.trim();
    if (!mounted) {
      return;
    }

    setState(() {
      _canManageReminders =
          currentUserId.isNotEmpty &&
          memberId.isNotEmpty &&
          currentUserId != memberId;
    });
  }

  Future<List<_KidReminderItem>> _loadReminders() async {
    if (widget.args.memberId.trim().isEmpty) {
      return const <_KidReminderItem>[];
    }

    final data = await AppDependencies.instance.apiClient.get(
      ApiEndpoints.kidReminders,
      queryParameters: {'member_uid': widget.args.memberId},
    );

    if (data is List) {
      return data
          .map((item) => _KidReminderItem.fromJson(item))
          .whereType<_KidReminderItem>()
          .toList();
    }

    return const <_KidReminderItem>[];
  }

  Future<void> _toggleReminder(_KidReminderItem item, bool isActive) async {
    await AppDependencies.instance.apiClient.patch(
      ApiEndpoints.kidReminderById(item.id),
      body: {'is_active': isActive},
    );
    setState(() {
      _remindersFuture = _loadReminders();
    });
  }

  Future<void> _createReminder({
    required String title,
    required String timeLabel,
    required _ReminderScheduleType scheduleType,
    required DateTime? scheduleDate,
    required List<int> weekdays,
  }) async {
    await AppDependencies.instance.apiClient.post(
      ApiEndpoints.kidReminders,
      body: {
        'member_uid': widget.args.memberId,
        'title': title,
        'reminder_time': timeLabel,
        'schedule_type': scheduleType.apiValue,
        'schedule_date': scheduleType == _ReminderScheduleType.once
            ? _formatDate(scheduleDate ?? DateTime.now())
            : null,
        'weekdays': scheduleType == _ReminderScheduleType.weekly
            ? weekdays
            : <int>[],
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _remindersFuture = _loadReminders();
    });
  }

  Future<void> _showCreateSheet() async {
    final titleController = TextEditingController();
    var selectedTime = TimeOfDay.now();
    var scheduleType = _ReminderScheduleType.daily;
    var selectedDate = DateTime.now();
    final selectedWeekdays = <int>{DateTime.now().weekday};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Thêm nhắc nhỏ',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C1D1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Nội dung nhắc',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Giờ nhắc',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.access_time_rounded),
                          label: Text(selectedTime.format(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _ReminderScheduleType.values.map((type) {
                        return ChoiceChip(
                          label: Text(type.label),
                          selected: scheduleType == type,
                          onSelected: (_) {
                            setModalState(() {
                              scheduleType = type;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (scheduleType == _ReminderScheduleType.weekly) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(7, (index) {
                          final weekday = index + 1;
                          return FilterChip(
                            label: Text(_weekdayShortLabel(weekday)),
                            selected: selectedWeekdays.contains(weekday),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  selectedWeekdays.add(weekday);
                                } else {
                                  selectedWeekdays.remove(weekday);
                                }
                              });
                            },
                          );
                        }),
                      ),
                    ],
                    if (scheduleType == _ReminderScheduleType.once) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.event_rounded),
                        label: Text(_formatDate(selectedDate)),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            return;
                          }
                          if (scheduleType == _ReminderScheduleType.weekly &&
                              selectedWeekdays.isEmpty) {
                            return;
                          }
                          final timeLabel = _formatTime(selectedTime);
                          Navigator.of(context).pop();
                          await _createReminder(
                            title: title,
                            timeLabel: timeLabel,
                            scheduleType: scheduleType,
                            scheduleDate: selectedDate,
                            weekdays: selectedWeekdays.toList()..sort(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00ACB2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Lưu nhắc nhỏ',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static String _weekdayShortLabel(int weekday) {
    const labels = {
      1: 'T2',
      2: 'T3',
      3: 'T4',
      4: 'T5',
      5: 'T6',
      6: 'T7',
      7: 'CN',
    };
    return labels[weekday] ?? 'T$weekday';
  }

  Future<void> _scheduleNotificationsIfKid(
    List<_KidReminderItem> reminders,
  ) async {
    final session = await AppDependencies.instance.authLocalDataSource
        .getSavedSession();
    if ((session?.userId.trim() ?? '') != widget.args.memberId.trim()) {
      return;
    }

    await KidReminderNotificationScheduler.instance.scheduleToday(
      reminders
          .where((item) => item.isActive)
          .map(
            (item) => KidReminderNotification(
              id: item.id,
              title: item.title,
              reminderTime: item.reminderTime,
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.kPrimaryLight, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackHeaderBar(
                title: 'Nhắc nhỏ',
                onBack: () => Navigator.maybePop(context),
              ),
              _MemberHeader(
                name: widget.args.memberName,
                avatarUrl: widget.args.avatarUrl,
              ),
              Expanded(
                child: FutureBuilder<List<_KidReminderItem>>(
                  future: _remindersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Không thể tải nhắc nhỏ.',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      );
                    }

                    final reminders =
                        snapshot.data ?? const <_KidReminderItem>[];
                    if (reminders.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có nhắc nhỏ.',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      itemBuilder: (context, index) {
                        final item = reminders[index];
                        return _KidReminderTile(
                          item: item,
                          onToggle: _canManageReminders
                              ? (value) => _toggleReminder(item, value)
                              : null,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: reminders.length,
                    );
                  },
                ),
              ),
              if (_canManageReminders)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.args.memberId.trim().isEmpty
                          ? null
                          : _showCreateSheet,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm nhắc nhỏ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00ACB2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: avatarUrl.trim().isEmpty
                  ? null
                  : NetworkImage(avatarUrl),
              child: avatarUrl.trim().isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0C1D1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vai trò: Trẻ em',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF00ACB2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KidReminderTile extends StatelessWidget {
  const _KidReminderTile({required this.item, required this.onToggle});

  final _KidReminderItem item;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFF00ACB2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0C1D1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.reminderTime} - ${item.scheduleLabel}',
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: item.isActive,
            activeThumbColor: const Color(0xFF00ACB2),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}

class _KidReminderItem {
  const _KidReminderItem({
    required this.id,
    required this.title,
    required this.reminderTime,
    required this.scheduleType,
    required this.scheduleDate,
    required this.weekdays,
    required this.isActive,
  });

  final int id;
  final String title;
  final String reminderTime;
  final _ReminderScheduleType scheduleType;
  final String? scheduleDate;
  final List<int> weekdays;
  final bool isActive;

  String get scheduleLabel {
    switch (scheduleType) {
      case _ReminderScheduleType.daily:
        return 'H\u1EB1ng ng\u00E0y';
      case _ReminderScheduleType.weekly:
        if (weekdays.isEmpty) {
          return 'Theo th\u1EE9';
        }
        return weekdays.map(_weekdayShortLabelText).join(', ');
      case _ReminderScheduleType.once:
        return scheduleDate ?? 'Theo ng\u00E0y';
    }
  }

  static _KidReminderItem? fromJson(dynamic json) {
    if (json is! Map) {
      return null;
    }

    final map = json.cast<String, dynamic>();
    final id = int.tryParse(map['id']?.toString() ?? '');
    if (id == null) {
      return null;
    }

    return _KidReminderItem(
      id: id,
      title: (map['title'] ?? '').toString(),
      reminderTime: (map['reminder_time'] ?? '').toString(),
      scheduleType: _ReminderScheduleType.fromApi(
        (map['schedule_type'] ?? 'daily').toString(),
      ),
      scheduleDate: map['schedule_date']?.toString(),
      weekdays: _weekdaysFromJson(map['weekdays']),
      isActive: map['is_active'] == true,
    );
  }

  static List<int> _weekdaysFromJson(Object? value) {
    if (value is! List) {
      return const <int>[];
    }
    return value
        .map((item) => int.tryParse(item.toString()))
        .whereType<int>()
        .where((item) => item >= 1 && item <= 7)
        .toList();
  }
}

String _weekdayShortLabelText(int weekday) {
  const labels = {
    1: 'T2',
    2: 'T3',
    3: 'T4',
    4: 'T5',
    5: 'T6',
    6: 'T7',
    7: 'CN',
  };
  return labels[weekday] ?? 'T$weekday';
}

enum _ReminderScheduleType {
  daily,
  weekly,
  once;

  String get apiValue {
    switch (this) {
      case _ReminderScheduleType.daily:
        return 'daily';
      case _ReminderScheduleType.weekly:
        return 'weekly';
      case _ReminderScheduleType.once:
        return 'once';
    }
  }

  String get label {
    switch (this) {
      case _ReminderScheduleType.daily:
        return 'H\u1EB1ng ng\u00E0y';
      case _ReminderScheduleType.weekly:
        return 'Theo th\u1EE9';
      case _ReminderScheduleType.once:
        return 'Theo ng\u00E0y';
    }
  }

  static _ReminderScheduleType fromApi(String value) {
    switch (value.trim()) {
      case 'weekly':
        return _ReminderScheduleType.weekly;
      case 'once':
        return _ReminderScheduleType.once;
      case 'daily':
      default:
        return _ReminderScheduleType.daily;
    }
  }
}
