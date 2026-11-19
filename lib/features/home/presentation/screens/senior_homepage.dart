import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/services/kid_reminder_notification_scheduler.dart';
import 'package:family_guard/core/widgets/buttons/app_back_button.dart';
import 'package:family_guard/core/fall_detection/presentation/fall_detection_debug_panel.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/home/domain/entities/quick_contact.dart';
import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_home_data.dart';
import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_home_schedule_design.dart';
import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_sos_sheet.dart';
import 'package:family_guard/features/reminder/data/datasources/reminder_remote_data_source.dart';
import 'package:family_guard/features/reminder/data/models/reminder_model.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeniorHomePage extends StatefulWidget {
  const SeniorHomePage({super.key});

  @override
  State<SeniorHomePage> createState() => _SeniorHomePageState();
}

class _SeniorHomePageState extends State<SeniorHomePage> {
  QuickContact? _quickContact;
  bool _isLoadingQuickContact = true;
  List<ReminderModel> _reminders = [];
  bool _isLoadingReminders = true;

  @override
  void initState() {
    super.initState();
    _loadQuickContact();
    _loadReminders();
  }

  Future<void> _loadQuickContact() async {
    try {
      final contact = await AppDependencies.instance.getQuickContactUseCase();
      if (mounted) {
        setState(() {
          _quickContact = contact;
          _isLoadingQuickContact = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải liên hệ nhanh: $e');
      if (mounted) {
        setState(() => _isLoadingQuickContact = false);
      }
    }
  }

  Future<void> _loadReminders() async {
    try {
      final list = await ReminderRemoteDataSourceImpl().getReminders();
      if (mounted) {
        setState(() {
          _reminders = list;
          _isLoadingReminders = false;
        });
        _scheduleSeniorReminders(list);
      }
    } catch (e) {
      debugPrint('Lỗi tải lịch nhắc người cao tuổi: $e');
      if (mounted) {
        setState(() => _isLoadingReminders = false);
      }
    }
  }

  void _scheduleSeniorReminders(List<ReminderModel> list) {
    List<ReminderNotificationItem> activeToday;
    if (list.isNotEmpty) {
      activeToday = list.where((r) => r.isActive).map((r) {
        return ReminderNotificationItem(
          id: r.id,
          title: r.title,
          reminderTime: r.reminderTime,
          subtitle: r.subtitle,
        );
      }).toList();
    } else {
      activeToday = SeniorHomeMockData.schedule.asMap().entries.map((e) {
        return ReminderNotificationItem(
          id: 1000 + e.key,
          title: e.value.title,
          reminderTime: e.value.timeLabel,
          subtitle: e.value.subtitle,
        );
      }).toList();
    }
    ReminderNotificationScheduler.instance.scheduleToday(activeToday);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFC),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _SeniorBackground()),
            Positioned.fill(
              child: RefreshIndicator(
                color: const Color(0xFF00AEB4),
                onRefresh: () async {
                  await Future.wait([
                    _loadQuickContact(),
                    _loadReminders(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 12),
                      _buildStatusPill(),
                      const SizedBox(height: 10),
                      _buildTitle(),
                      const SizedBox(height: 14),
                      _buildSosHero(context),
                      const SizedBox(height: 18),
                      _buildQuickContactCard(context),
                      const SizedBox(height: 20),
                      _buildScheduleSection(context),
                      const SizedBox(height: 24),
                      const FallDetectionDebugPanel(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const AppFlowBottomNav(
                current: AppNavTab.home,
                homeRouteName: AppRoutes.seniorHome,
                trackingRouteName: AppRoutes.seniorTracking,
                settingsRouteName: AppRoutes.seniorSettings,
                thirdTabRouteName: AppRoutes.seniorNotifications,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.menu_rounded,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu đang được hoàn thiện.')),
          ),
        ),
        Expanded(
          child: Text(
            'Support Family',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              color: const Color(0xFF00AEB4),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _CircleIconButton(
          icon: Icons.person_outline_rounded,
          onTap: () => Navigator.pushNamed(context, AppRoutes.seniorSettings),
        ),
      ],
    );
  }

  Widget _buildStatusPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2FBF3),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: Color(0xFF1D9C63),
            ),
            const SizedBox(width: 6),
            Text(
              'Hoạt động',
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF1C503D),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      width: double.infinity,
      child: Center(
        child: Text(
          'Bạn an toàn',
          style: GoogleFonts.lexend(
            color: const Color(0xFF17233D),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSosHero(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => _showSosSheet(context),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF4773), Color(0xFFE9154A)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55FF7E9E),
                blurRadius: 36,
                spreadRadius: 4,
                offset: Offset(0, 18),
              ),
            ],
            border: Border.all(color: const Color(0xFFFF8DA8), width: 9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 42,
              ),
              const SizedBox(height: 4),
              Text(
                'SOS',
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickContactCard(BuildContext context) {
    final contact = _quickContact;
    return InkWell(
      onTap: () => contact == null
          ? _showAddQuickContactSheet(context)
          : _showQuickContactOptions(context, contact),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liên hệ nhanh',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF17233D),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_isLoadingQuickContact) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Đang tải...',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF7A869A),
                        fontSize: 12,
                      ),
                    ),
                  ] else if (contact != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${contact.name} • ${contact.phone}',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF6A768E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'Thêm người để gọi nhanh khi cần hỗ trợ.',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF7A869A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => contact == null
                  ? _showAddQuickContactSheet(context)
                  : _startQuickCall(contact),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF00B3B8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  contact == null ? Icons.add_rounded : Icons.call_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    List<SeniorScheduleItem> scheduleItems = _reminders
        .where((r) => r.isActive)
        .map((r) => SeniorScheduleItem.fromReminder(r))
        .toList();

    if (scheduleItems.isEmpty) {
      scheduleItems = SeniorHomeMockData.schedule;
    }

    return SeniorHomeScheduleDesign(
      items: scheduleItems,
      isLoading: _isLoadingReminders,
      onItemTap: (item) => _showReminderDetailSheet(context, item),
      onSupportTap: () => _showSupportOptionsSheet(context),
    );
  }

  Future<void> _showReminderDetailSheet(
    BuildContext context,
    SeniorScheduleItem item,
  ) async {
    final reminder = item.reminderModel;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: item.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF8F5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.timeLabel,
                            style: GoogleFonts.lexend(
                              color: const Color(0xFF0B6E73),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          style: GoogleFonts.lexend(
                            color: const Color(0xFF17233D),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEDF2F7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết & Ghi chú',
                      style: GoogleFonts.lexend(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle.isNotEmpty
                          ? item.subtitle
                          : 'Đến giờ thực hiện theo lịch nhắc của gia đình.',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF1E293B),
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (reminder?.memberName != null &&
                        reminder!.memberName!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: Color(0xFF00ACB2),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Lịch được gửi bởi: ${reminder.memberName}',
                            style: GoogleFonts.beVietnamPro(
                              color: const Color(0xFF00ACB2),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Đóng',
                        style: GoogleFonts.lexend(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF1D9C63),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Bà đã ghi nhận hoàn thành lịch nhắc này!',
                                    style: GoogleFonts.beVietnamPro(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF00ACB2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text(
                        'Đã hoàn thành',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSupportOptionsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Hỗ trợ gia đình',
                style: GoogleFonts.lexend(
                  color: const Color(0xFF17233D),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bà muốn liên lạc với người thân bằng cách nào?',
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF7A869A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F7F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_rounded, color: Color(0xFF00B3B8)),
                ),
                title: Text(
                  'Gọi cho người thân',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  _quickContact != null
                      ? 'Gọi nhanh cho ${_quickContact!.name}'
                      : 'Mở danh bạ người thân',
                  style: GoogleFonts.beVietnamPro(fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (_quickContact != null) {
                    _startQuickCall(_quickContact!);
                  } else {
                    _showAddQuickContactSheet(context);
                  }
                },
              ),
              const Divider(height: 16, thickness: 0.8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F0FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                title: Text(
                  'Nhắn tin gia đình',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Mở cuộc trò chuyện cùng con cháu',
                  style: GoogleFonts.beVietnamPro(fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, AppRoutes.chatList);
                },
              ),
              const Divider(height: 16, thickness: 0.8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFDC2626),
                  ),
                ),
                title: Text(
                  'Báo động SOS',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                subtitle: Text(
                  'Gửi tín hiệu khẩn cấp đến toàn bộ gia đình',
                  style: GoogleFonts.beVietnamPro(fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showSosSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showQuickContactOptions(
    BuildContext context,
    QuickContact contact,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E8EE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                contact.name,
                style: GoogleFonts.lexend(
                  color: const Color(0xFF17233D),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                contact.phone,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF7A869A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F7F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_rounded, color: Color(0xFF00B3B8)),
                ),
                title: Text(
                  'Gọi ngay',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _startQuickCall(contact);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, color: Color(0xFF64748B)),
                ),
                title: Text(
                  'Thay đổi người liên hệ',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAddQuickContactSheet(context);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
                  ),
                ),
                title: Text(
                  'Xóa liên hệ nhanh',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _deleteQuickContact();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteQuickContact() async {
    try {
      await AppDependencies.instance.deleteQuickContactUseCase();
      if (mounted) {
        setState(() => _quickContact = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa liên hệ nhanh.')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi xóa liên hệ nhanh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa liên hệ nhanh: $e')),
        );
      }
    }
  }

  Future<void> _showSosSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SeniorSosSheet(
          onSafeTap: () => Navigator.pop(sheetContext),
          onEmergencyTap: () async {
            Navigator.pop(sheetContext);
            try {
              final loc =
                  AppDependencies.instance.locationTrackingService.lastLocation;
              await AppDependencies.instance.createFallNotificationUseCase(
                location: loc,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi cảnh báo khẩn cấp đến người thân!'),
                    backgroundColor: Color(0xFFFF1717),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Lỗi gửi cảnh báo SOS: $e');
            }

            if (!context.mounted) return;
            if (_quickContact == null) {
              _showAddQuickContactSheet(context);
              return;
            }
            _startQuickCall(_quickContact!);
          },
        );
      },
    );
  }

  Future<void> _showAddQuickContactSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E8EE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Thêm liên hệ nhanh',
                style: GoogleFonts.lexend(
                  color: const Color(0xFF17233D),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn muốn thêm liên hệ bằng cách nào?',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF73839B),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              _QuickAddOption(
                icon: Icons.contact_page_outlined,
                title: 'Danh bạ',
                subtitle: 'Chọn từ danh bạ gia đình của bạn',
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final result = await Navigator.of(context)
                      .push<QuickContact>(
                        MaterialPageRoute(
                          builder: (_) => const _SeniorContactDirectoryScreen(),
                        ),
                      );
                  _applyQuickContact(result);
                },
              ),
              const SizedBox(height: 12),
              _QuickAddOption(
                icon: Icons.dialpad_rounded,
                title: 'Số điện thoại',
                subtitle: 'Thêm số điện thoại thủ công',
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final result = await Navigator.of(context)
                      .push<QuickContact>(
                        MaterialPageRoute(
                          builder: (_) => const _SeniorAddPhoneScreen(),
                        ),
                      );
                  _applyQuickContact(result);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF17233D),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyQuickContact(QuickContact? contact) async {
    if (contact == null || !mounted) return;
    try {
      final saved =
          await AppDependencies.instance.saveQuickContactUseCase(contact);
      if (mounted) {
        setState(() => _quickContact = saved);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu ${saved.name} vào liên hệ nhanh.')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi lưu liên hệ nhanh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu liên hệ nhanh: $e')),
        );
      }
    }
  }

  void _startQuickCall(QuickContact contact) {
    Navigator.pushNamed(
      context,
      AppRoutes.inAppCall,
      arguments: InAppCallArgs(
        name: contact.name,
        avatarUrl: contact.avatarUrl ??
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
        role: MemberRole.adult,
      ),
    );
  }
}

class _SeniorContactDirectoryScreen extends StatefulWidget {
  const _SeniorContactDirectoryScreen();

  @override
  State<_SeniorContactDirectoryScreen> createState() =>
      _SeniorContactDirectoryScreenState();
}

class _SeniorContactDirectoryScreenState
    extends State<_SeniorContactDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QuickContact> _directoryContacts = [];
  bool _isLoading = true;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final rels = await AppDependencies.instance.getRelationshipsUseCase();
      final contacts = <QuickContact>[];
      for (final r in rels) {
        if (r.processing == 'xacnhan' && r.relationUser != null) {
          final u = r.relationUser!;
          contacts.add(
            QuickContact(
              name: u.name.isNotEmpty ? u.name : 'Người thân',
              phone: u.phone ?? '',
              avatarUrl: u.avata ??
                  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
              memberUid: r.relationId,
            ),
          );
        }
      }
      if (contacts.isEmpty) {
        contacts.addAll(_defaultMockContacts);
      }
      if (mounted) {
        setState(() {
          _directoryContacts = contacts;
          _selectedId = contacts.first.phone.isNotEmpty
              ? contacts.first.phone
              : contacts.first.name;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _directoryContacts = _defaultMockContacts;
          _selectedId = _defaultMockContacts.first.phone;
          _isLoading = false;
        });
      }
    }
  }

  List<QuickContact> get _filteredContacts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _directoryContacts;
    return _directoryContacts.where((contact) {
      return contact.name.toLowerCase().contains(query) ||
          contact.phone.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _filteredContacts;
    final selected = _directoryContacts.firstWhere(
      (contact) =>
          (contact.phone.isNotEmpty ? contact.phone : contact.name) ==
          _selectedId,
      orElse: () => _directoryContacts.isNotEmpty
          ? _directoryContacts.first
          : const QuickContact(name: '', phone: ''),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Column(
          children: [
            _SheetHeader(
              title: 'Thêm từ danh bạ',
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B3B8),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE8EDF1),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF00B3B8),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Tìm kiếm người thân',
                                      hintStyle: GoogleFonts.beVietnamPro(
                                        color: const Color(0xFF9BA6B2),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (contacts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Không tìm thấy người liên hệ phù hợp.',
                                style: GoogleFonts.beVietnamPro(
                                  color: const Color(0xFF7A869A),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ...contacts.map((contact) {
                            final contactId = contact.phone.isNotEmpty
                                ? contact.phone
                                : contact.name;
                            final isSelected = contactId == _selectedId;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _selectedId = contactId),
                                borderRadius: BorderRadius.circular(16),
                                child: Ink(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE9FAF9)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF8DDDDD)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundImage: NetworkImage(
                                          contact.avatarUrl ??
                                              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              contact.name,
                                              style: GoogleFonts.lexend(
                                                color: const Color(0xFF17233D),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              contact.phone,
                                              style: GoogleFonts.beVietnamPro(
                                                color: const Color(0xFF7A869A),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF00B3B8)
                                              : const Color(0xFFF1F7F8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isSelected
                                              ? Icons.check_rounded
                                              : Icons.add_rounded,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF00B3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selected.name.isNotEmpty
                      ? () => Navigator.pop(context, selected)
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF00B3B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Thêm',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeniorAddPhoneScreen extends StatefulWidget {
  const _SeniorAddPhoneScreen();

  @override
  State<_SeniorAddPhoneScreen> createState() => _SeniorAddPhoneScreenState();
}

class _SeniorAddPhoneScreenState extends State<_SeniorAddPhoneScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Column(
          children: [
            _SheetHeader(
              title: 'Thêm số điện thoại',
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F7F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_rounded,
                        color: Color(0xFF00B3B8),
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const _InputLabel(text: 'Tên liên hệ'),
                    const SizedBox(height: 8),
                    _SeniorTextField(
                      controller: _nameController,
                      hintText: 'Nhập tên',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 22),
                    const _InputLabel(text: 'Phone Number'),
                    const SizedBox(height: 8),
                    _SeniorTextField(
                      controller: _phoneController,
                      hintText: '+1 (555) 000-0000',
                      prefixIcon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Người liên hệ này sẽ được thông báo trong trường hợp có cảnh báo khẩn cấp từ Support Family.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF8791A1),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF00B3B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Thêm',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ tên và số điện thoại.')),
      );
      return;
    }

    Navigator.pop(
      context,
      QuickContact(
        name: name,
        phone: phone,
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=300&auto=format&fit=crop',
      ),
    );
  }
}

class _SeniorBackground extends StatelessWidget {
  const _SeniorBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -92,
            left: -118,
            child: Container(
              width: 232,
              height: 232,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDDF7F7).withValues(alpha: 0.95),
              ),
            ),
          ),
          Positioned(
            top: 118,
            right: -92,
            child: Container(
              width: 198,
              height: 198,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0F7F7).withValues(alpha: 0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFE9F9FA),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF00B3B8)),
      ),
    );
  }
}

class _QuickAddOption extends StatelessWidget {
  const _QuickAddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF00B3B8)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF17233D),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF7A869A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0BAC7)),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          AppBackButton(
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                color: const Color(0xFF17233D),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.beVietnamPro(
          color: const Color(0xFF17233D),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SeniorTextField extends StatelessWidget {
  const _SeniorTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.beVietnamPro(
        color: const Color(0xFF17233D),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF9BA6B2), size: 20),
        hintText: hintText,
        hintStyle: GoogleFonts.beVietnamPro(
          color: const Color(0xFF9BA6B2),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00B3B8)),
        ),
      ),
    );
  }
}

const List<QuickContact> _defaultMockContacts = [
  QuickContact(
    name: 'Bố Hoàng',
    phone: '0901000001',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
  ),
  QuickContact(
    name: 'Mẹ Mai',
    phone: '0901000004',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80',
  ),
  QuickContact(
    name: 'Bé Na',
    phone: '0901000002',
    avatarUrl:
        'https://images.unsplash.com/photo-1596870230751-ebdfce98ec42?w=400&q=80',
  ),
];
