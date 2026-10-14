import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsAppThemeScreen extends StatefulWidget {
  const SettingsAppThemeScreen({
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
  State<SettingsAppThemeScreen> createState() => _SettingsAppThemeScreenState();
}

class _SettingsAppThemeScreenState extends State<SettingsAppThemeScreen> {
  String selectedTheme = 'Biển sáng';

  final List<_ThemePreset> presets = const [
    _ThemePreset(
      name: 'Biển sáng',
      accent: Color(0xFF00ACB2),
      background: Color(0xFFF0F8F7),
      surface: Colors.white,
    ),
    _ThemePreset(
      name: 'Hoàng hôn',
      accent: Color(0xFFFF7A59),
      background: Color(0xFFFFF5F0),
      surface: Colors.white,
    ),
    _ThemePreset(
      name: 'Lá non',
      accent: Color(0xFF22C55E),
      background: Color(0xFFF5FFF7),
      surface: Colors.white,
    ),
    _ThemePreset(
      name: 'Đêm dịu',
      accent: Color(0xFF4F46E5),
      background: Color(0xFFF4F5FF),
      surface: Colors.white,
    ),
  ];

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
                    title: 'Màu Sắc Ứng Dụng',
                    onBack: () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                    titleFontSize: 20,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Chọn một bảng màu gần với phong cách Support Family. Thiết kế hiện tại sẽ giữ nguyên cấu trúc, chỉ thay đổi sắc độ nhấn.',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF638888),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...presets.map(
                    (preset) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ThemeOptionCard(
                        preset: preset,
                        selected: selectedTheme == preset.name,
                        onTap: () =>
                            setState(() => selectedTheme = preset.name),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã chọn giao diện $selectedTheme.',
                          ),
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
                        'Áp dụng',
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
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final _ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? preset.accent : const Color(0xFFF3F4F6),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
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
                    preset.name,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF111818),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _swatch(preset.accent),
                      const SizedBox(width: 8),
                      _swatch(preset.background),
                      const SizedBox(width: 8),
                      _swatch(preset.surface),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 112,
              height: 80,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: preset.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 8,
                    decoration: BoxDecoration(
                      color: preset.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: preset.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: preset.accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 12),
              Icon(Icons.check_circle_rounded, color: preset.accent, size: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
    );
  }
}

class _ThemePreset {
  const _ThemePreset({
    required this.name,
    required this.accent,
    required this.background,
    required this.surface,
  });

  final String name;
  final Color accent;
  final Color background;
  final Color surface;
}
