import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/theme.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/features/reminder/data/datasources/reminder_remote_data_source.dart';
import 'package:family_guard/features/reminder/data/models/reminder_model.dart';

class ReminderListDeleteScreen extends StatefulWidget {
  const ReminderListDeleteScreen({super.key});

  @override
  State<ReminderListDeleteScreen> createState() => _ReminderListDeleteScreenState();
}

class _ReminderListDeleteScreenState extends State<ReminderListDeleteScreen> {
  late final ReminderRemoteDataSource _dataSource;
  List<ReminderModel> _reminders = [];
  final Set<int> _selectedIds = {};
  bool _isLoading = true;
  bool _isDeleting = false;

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
      // Fallback default demo data if offline
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

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _reminders.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_reminders.map((r) => r.id));
      }
    });
  }

  Future<void> _deleteAndReturn() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 lịch nhắc để xóa'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xóa ${_selectedIds.length} lịch nhắc đã chọn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await _dataSource.bulkDeleteReminders(_selectedIds.toList());
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isDeleting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ${_selectedIds.length} lịch nhắc'),
        backgroundColor: const Color(0xFF111827),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackHeaderBar(
        title: 'Xóa lịch nhắc',
        trailing: _isDeleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: _deleteAndReturn,
                child: Text(
                  'Xác nhận (${_selectedIds.length})',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildTitle(),
                    _buildRemindersList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFFF0FFF8), Colors.white],
        ),
      ),
      child: _buildMemberCard(),
    );
  }

  Widget _buildMemberCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x2600ACB2),
          ),
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
                      Icons.home,
                      size: 16,
                      color: AppColors.primary,
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
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chọn lời nhắc cần xóa',
            style: TextStyle(
              color: const Color(0xFF0C1D1A),
              fontSize: ResponsiveHelper.sp(context, 18),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          TextButton(
            onPressed: _toggleSelectAll,
            child: Text(
              _selectedIds.length == _reminders.length ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
              style: const TextStyle(
                color: Color(0xFF00ACB2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    if (_reminders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'Không có lịch nhắc nào để xóa.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 8,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Column(
        children: [
          ..._reminders.map((reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReminderCard(reminder),
              )),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    final isSelected = _selectedIds.contains(reminder.id);

    return InkWell(
      onTap: () => _toggleSelect(reminder.id),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 2 : 1,
              color: isSelected ? const Color(0xFFEF4444) : const Color(0x2600ACB2),
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 10,
              offset: Offset(0, 2),
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
                      color: const Color(0xFF0F172A),
                      fontSize: ResponsiveHelper.sp(context, 16),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.formattedTime,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: ResponsiveHelper.sp(context, 13),
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelect(reminder.id),
              activeColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }
}
