import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsNotificationPreferencesScreen extends StatefulWidget {
  const SettingsNotificationPreferencesScreen({
    super.key,
    this.homeRouteName = AppRoutes.home,
    this.trackingRouteName = AppRoutes.tracking,
    this.notificationsRouteName = AppRoutes.notifications,
    this.settingsRouteName = AppRoutes.settings,
  });

  final String homeRouteName;
  final String trackingRouteName;
  final String notificationsRouteName;
  final String settingsRouteName;

  @override
  State<SettingsNotificationPreferencesScreen> createState() =>
      _SettingsNotificationPreferencesScreenState();
}

class _SettingsNotificationPreferencesScreenState
    extends State<SettingsNotificationPreferencesScreen> {
  bool emergencyAlerts = true;
  bool safeZoneAlerts = true;
  bool lowBatteryAlerts = true;
  bool moodAlerts = false;
  bool dailySummary = true;
  bool quietHours = true;
  String previewMode = 'Hiển thị đầy đủ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBackHeaderBar(
                    title: 'Thông Báo',
                    onBack: () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                    titleFontSize: 20,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Điều chỉnh loại cảnh báo bạn muốn nhận trong Support Family để không bỏ lỡ các sự kiện quan trọng.',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF638888),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel(title: 'Ưu tiên'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _ToggleRow(
                        label: 'Cảnh báo khẩn cấp',
                        subtitle: 'Luôn bật cho té ngã và SOS',
                        value: emergencyAlerts,
                        onChanged: (value) =>
                            setState(() => emergencyAlerts = value),
                      ),
                      _divider(),
                      _ToggleRow(
                        label: 'Rời vùng an toàn',
                        subtitle: 'Thông báo khi thành viên ra khỏi khu vực',
                        value: safeZoneAlerts,
                        onChanged: (value) =>
                            setState(() => safeZoneAlerts = value),
                      ),
                      _divider(),
                      _ToggleRow(
                        label: 'Pin yếu',
                        subtitle: 'Nhắc khi thiết bị dưới 15%',
                        value: lowBatteryAlerts,
                        onChanged: (value) =>
                            setState(() => lowBatteryAlerts = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel(title: 'Hoạt động'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _ToggleRow(
                        label: 'Tâm trạng',
                        subtitle: 'Xu hướng cảm xúc và nhật ký hằng ngày',
                        value: moodAlerts,
                        onChanged: (value) => setState(() => moodAlerts = value),
                      ),
                      _divider(),
                      _ToggleRow(
                        label: 'Tóm tắt cuối ngày',
                        subtitle: 'Gửi báo cáo nhanh vào 20:00',
                        value: dailySummary,
                        onChanged: (value) =>
                            setState(() => dailySummary = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel(title: 'Hiển thị'),
                  const SizedBox(height: 8),
                  _Card(
                    children: [
                      _ToggleRow(
                        label: 'Chế độ yên lặng',
                        subtitle: 'Tạm ẩn âm thanh từ 22:00 đến 06:00',
                        value: quietHours,
                        onChanged: (value) =>
                            setState(() => quietHours = value),
                      ),
                      _divider(),
                      _SelectRow(
                        label: 'Xem trước thông báo',
                        value: previewMode,
                        onTap: _cyclePreviewMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã gửi một thông báo thử nghiệm.'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17E8E8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Gửi thông báo thử',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF111818),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppFlowBottomNav(
                current: AppNavTab.settings,
                homeRouteName: widget.homeRouteName,
                trackingRouteName: widget.trackingRouteName,
                settingsRouteName: widget.settingsRouteName,
                thirdTabRouteName: widget.notificationsRouteName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cyclePreviewMode() {
    setState(() {
      previewMode = switch (previewMode) {
        'Hiển thị đầy đủ' => 'Ẩn nội dung',
        'Ẩn nội dung' => 'Chỉ biểu tượng',
        _ => 'Hiển thị đầy đủ',
      };
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color: const Color(0xFF638888),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111818),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF638888),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF2DD4BF),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: const Color(0xFF111818),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                color: const Color(0xFF638888),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

Widget _divider() {
  return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
}
