import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_dialog.dart';
import 'package:flutter/material.dart';

class ReminderListEditableScreen extends StatefulWidget {
  const ReminderListEditableScreen({super.key});

  @override
  State<ReminderListEditableScreen> createState() =>
      _ReminderListEditableScreenState();
}

class _ReminderListEditableScreenState extends State<ReminderListEditableScreen> {
  final List<ReminderItemEditable> _reminders = [
    ReminderItemEditable(
      id: '1',
      title: 'U\u1ED1ng thu\u1ED1c huy\u1EBFt \u00E1p',
      time: '08:00 - M\u1ED7i ng\u00E0y',
      iconColor: const Color(0x33FF85A1),
      icon: Icons.medication,
      isActive: true,
    ),
    ReminderItemEditable(
      id: '2',
      title: '\u0102n s\u00E1ng',
      time: '07:00 - M\u1ED7i ng\u00E0y',
      iconColor: const Color(0x33FFD166),
      icon: Icons.restaurant,
      isActive: true,
    ),
    ReminderItemEditable(
      id: '3',
      title: '\u0110o huy\u1EBFt \u00E1p',
      time: '09:00, 16:00 - M\u1ED7i ng\u00E0y',
      iconColor: const Color(0x33118AB2),
      icon: Icons.favorite,
      isActive: true,
    ),
  ];

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
              const AppBackHeaderBar(title: 'L\u1ECBch nh\u1EAFc \u0111\u00E3 t\u1EA1o'),
              _buildMemberCard(hPad),
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                child: Text(
                  'L\u1ECBch nh\u1EAFc \u0111\u00E3 t\u1EA1o',
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
                child: SingleChildScrollView(
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
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=47'),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2, color: Color(0x3300ACB2)),
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'B\u00E0 Lan',
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
                        '\u0110ang \u1EDF nh\u00E0',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Qu\u1EADn 7',
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
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
                      Icons.battery_charging_full_rounded,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '85%',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
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
      ),
    );
  }

  Widget _buildSwipeableReminderCard(ReminderItemEditable reminder) {
    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async => false,
      background: _buildSwipeBackground(reminder),
      child: _buildReminderCard(reminder),
    );
  }

  Widget _buildSwipeBackground(ReminderItemEditable reminder) {
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

  Widget _buildReminderCard(ReminderItemEditable reminder) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.reminderDetail),
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
                color: reminder.iconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Icon(
                reminder.icon,
                color: _getIconColor(reminder.iconColor),
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
                    reminder.time,
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
              onTap: () {
                setState(() {
                  reminder.isActive = !reminder.isActive;
                });
              },
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
      onPressed: () => Navigator.pushNamed(context, AppRoutes.createReminder),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF00ACB2),
        side: const BorderSide(width: 2, color: Color(0x4C00ACB2)),
      ),
      icon: const Icon(Icons.add_circle_outline, size: 24),
      label: const Text('Th\u00EAm nh\u1EAFc nh\u1EDF m\u1EDBi'),
    );
  }

  Color _getIconColor(Color bgColor) {
    if (bgColor == const Color(0x33FF85A1)) return const Color(0xFFFF85A1);
    if (bgColor == const Color(0x33FFD166)) return const Color(0xFFFFD166);
    if (bgColor == const Color(0x33118AB2)) return const Color(0xFF118AB2);
    return AppColors.primary;
  }

  void _handleEdit(ReminderItemEditable reminder) {
    Navigator.pushNamed(context, AppRoutes.reminderDetail);
  }

  void _handleDelete(ReminderItemEditable reminder) {
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'X\u00E1c nh\u1EADn x\u00F3a',
      content:
          'B\u1EA1n c\u00F3 ch\u1EAFc ch\u1EAFn mu\u1ED1n x\u00F3a l\u1ECBch nh\u1EAFc n\u00E0y?',
      confirmText: 'X\u00F3a',
      icon: Icons.delete_outline_rounded,
      onConfirm: () {
        setState(() {
          _reminders.removeWhere((item) => item.id == reminder.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('\u0110\u00E3 x\u00F3a l\u1ECBch nh\u1EAFc'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      },
    );
  }
}

class ReminderItemEditable {
  ReminderItemEditable({
    required this.id,
    required this.title,
    required this.time,
    required this.iconColor,
    required this.icon,
    required this.isActive,
  });

  final String id;
  final String title;
  final String time;
  final Color iconColor;
  final IconData icon;
  bool isActive;
}
