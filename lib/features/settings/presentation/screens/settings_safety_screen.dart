import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsSafetyScreen extends StatefulWidget {
  const SettingsSafetyScreen({
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
  State<SettingsSafetyScreen> createState() => _SettingsSafetyScreenState();
}

class _SettingsSafetyScreenState extends State<SettingsSafetyScreen> {
  bool autoShareLocation = true;
  bool fallDetection = true;
  bool sosConfirmation = false;
  bool routeHistory = true;

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
                    title: 'An Toàn',
                    onBack: () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                    titleFontSize: 20,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Tùy chỉnh những hành động tự động khi có sự cố để gia đình nhận thông tin nhanh và chính xác hơn.',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF638888),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SafetySectionLabel(title: 'Tự động'),
                  const SizedBox(height: 8),
                  _SafetyCard(
                    children: [
                      _SafetyToggleRow(
                        title: 'Chia sẻ vị trí khi có SOS',
                        subtitle: 'Gửi vị trí hiện tại đến người thân',
                        value: autoShareLocation,
                        onChanged: (value) =>
                            setState(() => autoShareLocation = value),
                      ),
                      _divider(),
                      _SafetyToggleRow(
                        title: 'Phát hiện té ngã',
                        subtitle: 'Ưu tiên cảnh báo cho người cao tuổi',
                        value: fallDetection,
                        onChanged: (value) =>
                            setState(() => fallDetection = value),
                      ),
                      _divider(),
                      _SafetyToggleRow(
                        title: 'Yêu cầu xác nhận SOS',
                        subtitle: 'Hạn chế bấm nhầm trong 5 giây đầu',
                        value: sosConfirmation,
                        onChanged: (value) =>
                            setState(() => sosConfirmation = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SafetySectionLabel(title: 'Quản lý'),
                  const SizedBox(height: 8),
                  _SafetyCard(
                    children: [
                      _ActionRow(
                        title: 'Liên hệ ưu tiên',
                        subtitle: 'Chỉnh sửa người nhận cảnh báo',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.priorityContacts,
                        ),
                      ),
                      _divider(),
                      _SafetyToggleRow(
                        title: 'Lưu lịch sử di chuyển',
                        subtitle: 'Dùng cho màn xem lại lộ trình',
                        value: routeHistory,
                        onChanged: (value) =>
                            setState(() => routeHistory = value),
                      ),
                      _divider(),
                      _ActionRow(
                        title: 'Mở vùng an toàn',
                        subtitle: 'Thiết lập nhanh khu vực cần theo dõi',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.safeZone),
                      ),
                    ],
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
}

class _SafetySectionLabel extends StatelessWidget {
  const _SafetySectionLabel({required this.title});

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

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.children});

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

class _SafetyToggleRow extends StatelessWidget {
  const _SafetyToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
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
                  title,
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    ),
                  ),
                ],
              ),
            ),
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
