import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_dialog.dart';
import 'package:family_guard/features/reminder/data/datasources/reminder_remote_data_source.dart';
import 'package:family_guard/features/reminder/data/models/reminder_model.dart';
import 'package:flutter/material.dart';

class ReminderListEditableScreen extends StatefulWidget {
  const ReminderListEditableScreen({super.key});

  @override
  State<ReminderListEditableScreen> createState() =>
      _ReminderListEditableScreenState();
}

class _ReminderListEditableScreenState extends State<ReminderListEditableScreen> {
  late final ReminderRemoteDataSource _dataSource;
  List<ReminderModel> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = ReminderRemoteDataSourceImpl();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final list = await _dataSource.getReminders();
      if (!mounted) return;
      setState(() {
        _reminders = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reminders = [
          ReminderModel(
            id: 1,
            ownerUid: '',
            memberUid: '',
            title: 'Uống thuốc huyết áp',
            category: 'medicine',
            reminderTime: '08:00',
            scheduleType: 'daily',
            weekdays: [],
            isActive: true,
          ),
          ReminderModel(
            id: 2,
            ownerUid: '',
            memberUid: '',
            title: 'Ăn sáng',
            category: 'food',
            reminderTime: '07:00',
            scheduleType: 'daily',
            weekdays: [],
            isActive: true,
          ),
          ReminderModel(
            id: 3,
            ownerUid: '',
            memberUid: '',
            title: 'Đo huyết áp',
            category: 'health',
            reminderTime: '09:00',
            scheduleType: 'daily',
            weekdays: [],
            isActive: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleToggle(ReminderModel reminder) async {
    final nextState = !reminder.isActive;
    setState(() => reminder.isActive = nextState);
    try {
      await _dataSource.toggleReminder(reminder.id, nextState);
    } catch (e) {
      if (!mounted) return;
      setState(() => reminder.isActive = !nextState);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FFF8), Colors.white],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackHeaderBar(title: 'Lịch nhắc đã tạo'),
              _buildMemberCard(hPad),
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                child: Text(
                  'Lịch nhắc đã tạo',
                  style: TextStyle(
                    color: const Color(0xFF0C1D1A),
                    fontSize: ResponsiveHelper.sp(context, 24),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
                        child: Column(
                          children: [
                            ..._reminders.map(
                              (reminder) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildSwipeableReminderCard(reminder),
                              ),
                            ),
                            _buildAddButton(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x2600ACB2)),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x1400ACB2),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.person, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thành viên gia đình',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: ResponsiveHelper.sp(context, 18),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.home_rounded,
                        size: 14,
                        color: Color(0xFF00ACB2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đang ở nhà',
                        style: TextStyle(
                          color: const Color(0xFF00ACB2),
                          fontSize: ResponsiveHelper.sp(context, 14),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeableReminderCard(ReminderModel reminder) {
    return Dismissible(
      key: Key('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async => false,
      background: _buildSwipeBackground(reminder),
      child: _buildReminderCard(reminder),
    );
  }

  Widget _buildSwipeBackground(ReminderModel reminder) {
    return Container(
      padding: const EdgeInsets.only(right: 16),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => _handleEdit(reminder),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _handleDelete(reminder),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    return GestureDetector(
      onTap: () => _handleEdit(reminder),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x2600ACB2)),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x1400ACB2),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: reminder.iconBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Icon(
                reminder.icon,
                color: reminder.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: ResponsiveHelper.sp(context, 16),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    reminder.formattedTime,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: ResponsiveHelper.sp(context, 14),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _handleToggle(reminder),
              child: _buildToggleSwitch(reminder.isActive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 28,
      padding: EdgeInsets.only(
        left: isActive ? 22 : 2,
        right: isActive ? 2 : 22,
        top: 2,
        bottom: 2,
      ),
      decoration: ShapeDecoration(
        color: isActive ? const Color(0xFF00ACB2) : const Color(0xFFE2E8F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        final res = await Navigator.pushNamed(context, AppRoutes.createReminder);
        if (res == true || res != null) {
          _loadReminders();
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF00ACB2),
        side: const BorderSide(width: 2, color: Color(0x4C00ACB2)),
      ),
      icon: const Icon(Icons.add_circle_outline, size: 24),
      label: const Text('Thêm nhắc nhở mới'),
    );
  }

  Future<void> _handleEdit(ReminderModel reminder) async {
    final res = await Navigator.pushNamed(context, AppRoutes.reminderDetail);
    if (res != null) {
      _loadReminders();
    }
  }

  void _handleDelete(ReminderModel reminder) {
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa lịch nhắc này?',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () async {
        try {
          await _dataSource.deleteReminder(reminder.id);
        } catch (_) {}

        if (!mounted) return;
        setState(() {
          _reminders.removeWhere((item) => item.id == reminder.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa lịch nhắc'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
