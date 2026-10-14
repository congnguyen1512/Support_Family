import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/theme.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

class ReminderListDeleteScreen extends StatefulWidget {
  const ReminderListDeleteScreen({super.key});

  @override
  State<ReminderListDeleteScreen> createState() => _ReminderListDeleteScreenState();
}

class _ReminderListDeleteScreenState extends State<ReminderListDeleteScreen> {
  List<ReminderItemDelete> reminders = [
    ReminderItemDelete(
      id: '1',
      title: 'Uống thuốc huyết áp',
      time: '08:00 - Mỗi ngày',
      iconColor: const Color(0x33FF85A1),
      icon: Icons.medication,
      isActive: true,
    ),
    ReminderItemDelete(
      id: '2',
      title: 'Đo huyết áp',
      time: '09:00, 16:00 - Mỗi ngày',
      iconColor: const Color(0x33118AB2),
      icon: Icons.favorite,
      isActive: true,
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
            appBar: AppBackHeaderBar(
        title: 'Xóa lịch nhắc',
        trailing: TextButton(
          onPressed: _deleteAndReturn,
          child: const Text(
            'Xác nhận',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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

  /// Fix #7: pop(true) để parent biết có thành phần bị xóa và refresh list
  void _deleteAndReturn() {
    final messenger = ScaffoldMessenger.of(context);
    // Lấy danh sách reminder đã chọn (toàn bộ nếu không có multi-select)
    Navigator.pop(context, true); // true = có thay đổi
    messenger.showSnackBar(
      SnackBar(
        content: Text('Đã xóa lịch nhắc'),
        backgroundColor: const Color(0xFF111827),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          textColor: const Color(0xFF00ACB2),
          onPressed: () {
            // TODO: restore deleted reminder
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 32,
        left: 24,
        right: 24,
        bottom: 24,
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
      padding: EdgeInsets.all(16),
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
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bà Lan',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: ResponsiveHelper.sp(context, 18),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Đang ở nhà',
                      style: TextStyle(
                        color: Color(0xFF00ACB2),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '123 ABC St',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: ResponsiveHelper.sp(context, 12),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.battery_charging_full,
                    size: 12,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '85%',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: ResponsiveHelper.sp(context, 12),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: ShapeDecoration(
            image: const DecorationImage(
              image: NetworkImage("https://placehold.co/56x56"),
              fit: BoxFit.cover,
            ),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 2,
                color: Color(0x3300ACB2),
              ),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: ShapeDecoration(
              color: const Color(0xFF22C55E),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        'Lịch nhắc đã tạo',
        style: TextStyle(
          color: Color(0xFF0C1D1A),
          fontSize: ResponsiveHelper.sp(context, 24),
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
          height: 1.33,
          letterSpacing: -0.60,
        ),
      ),
    );
  }

  Widget _buildRemindersList() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Column(
        children: [
          ...reminders.map((reminder) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildReminderCard(reminder),
              )),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderItemDelete reminder) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
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
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: reminder.iconColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Icon(
              reminder.icon,
              color: Colors.white,
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
                    color: reminder.title == 'Uống thuốc huyết áp'
                        ? Colors.black
                        : const Color(0xFF0F172A),
                    fontSize: ResponsiveHelper.sp(context, 16),
                    fontFamily: 'Lexend',
                    fontWeight: reminder.title == 'Uống thuốc huyết áp'
                        ? FontWeight.w700
                        : FontWeight.w400,
                    height: 1.50,
                  ),
                ),
                Text(
                  reminder.time,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: ResponsiveHelper.sp(context, 14),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
          _buildToggleSwitch(reminder),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(ReminderItemDelete reminder) {
    return GestureDetector(
      onTap: () {
        setState(() {
          reminder.isActive = !reminder.isActive;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        padding: EdgeInsets.only(
          top: 2,
          left: reminder.isActive ? 22 : 2,
          right: reminder.isActive ? 2 : 22,
          bottom: 2,
        ),
        decoration: ShapeDecoration(
          color: reminder.isActive
              ? const Color(0xFF00ACB2)
              : const Color(0xFFE2E8F0),
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
                spreadRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/create-reminder');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF00ACB2),
        side: const BorderSide(width: 2, color: Color(0x4C00ACB2)),
      ),
      icon: const Icon(Icons.add, size: 24),
      label: const Text('Thêm nhắc nhở mới'),
    );
  }

}


class ReminderItemDelete {
  final String id;
  final String title;
  final String time;
  final Color iconColor;
  final IconData icon;
  bool isActive;

  ReminderItemDelete({
    required this.id,
    required this.title,
    required this.time,
    required this.iconColor,
    required this.icon,
    required this.isActive,
  });
}



