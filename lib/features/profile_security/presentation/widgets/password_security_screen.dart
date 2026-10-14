import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:family_guard/features/profile_security/presentation/screens/change_password_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({
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
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  bool twoFactor = true;
  bool faceId = true;
  bool loginAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBackHeaderBar(
                    title: 'Mật khẩu & Bảo mật',
                    onBack: () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                    titleFontSize: 20,
                  ),
                  const SizedBox(height: 20),
                  _PasswordSection(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ChangePasswordDetailScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SecurityOptionsSection(
                    twoFactor: twoFactor,
                    faceId: faceId,
                    loginAlerts: loginAlerts,
                    onToggle: (type, value) {
                      setState(() {
                        switch (type) {
                          case _SecurityToggleType.twoFactor:
                            twoFactor = value;
                            break;
                          case _SecurityToggleType.faceId:
                            faceId = value;
                            break;
                          case _SecurityToggleType.loginAlerts:
                            loginAlerts = value;
                            break;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const _TrustedDevicesSection(),
                  const SizedBox(height: 20),
                  _DeleteAccountCard(onTap: () => _showDeleteDialog(context)),
                  const SizedBox(height: 16),
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

  Future<void> _showDeleteDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa tài khoản'),
          content: const Text(
            'Tính năng này hiện là giao diện mô phỏng và chưa xóa dữ liệu thật.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}

class _PasswordSection extends StatelessWidget {
  const _PasswordSection({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('THAY ĐỔI MẬT KHẨU'),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: _cardDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Thay đổi mật khẩu',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF111818),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityOptionsSection extends StatelessWidget {
  const _SecurityOptionsSection({
    required this.twoFactor,
    required this.faceId,
    required this.loginAlerts,
    required this.onToggle,
  });

  final bool twoFactor;
  final bool faceId;
  final bool loginAlerts;
  final void Function(_SecurityToggleType type, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('TÙY CHỌN BẢO MẬT'),
        const SizedBox(height: 8),
        Container(
          decoration: _cardDecoration,
          child: Column(
            children: [
              _SecurityOptionRow(
                label: 'Two-Factor Authentication',
                enabled: twoFactor,
                onChanged: (value) =>
                    onToggle(_SecurityToggleType.twoFactor, value),
              ),
              const _DividerLine(),
              _SecurityOptionRow(
                label: 'Face ID Login',
                enabled: faceId,
                onChanged: (value) =>
                    onToggle(_SecurityToggleType.faceId, value),
              ),
              const _DividerLine(),
              _SecurityOptionRow(
                label: 'Login Alerts',
                enabled: loginAlerts,
                onChanged: (value) =>
                    onToggle(_SecurityToggleType.loginAlerts, value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrustedDevicesSection extends StatelessWidget {
  const _TrustedDevicesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('THIẾT BỊ TIN CẬY'),
        const SizedBox(height: 8),
        Container(
          decoration: _cardDecoration,
          child: const Column(
            children: [
              _TrustedDeviceRow(
                icon: Icons.smartphone_outlined,
                deviceName: 'iPhone 15 Pro',
                subtitle: 'Huế • Thiết bị hiện tại',
                subtitleColor: Color(0xFF1BD521),
              ),
              _DividerLine(),
              _TrustedDeviceRow(
                icon: Icons.laptop_mac_outlined,
                deviceName: 'MacBook Pro',
                subtitle: 'Huế • Hoạt động 2h trước',
                trailing: 'Đăng xuất',
                trailingColor: Color(0xFFFF0000),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeleteAccountCard extends StatelessWidget {
  const _DeleteAccountCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: _cardDecoration,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        alignment: Alignment.center,
        child: Text(
          'Xóa Tài Khoản',
          style: GoogleFonts.inter(
            color: const Color(0xFFEF4444),
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF638888).withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          height: 1.3,
        ),
      ),
    );
  }
}

class _SecurityOptionRow extends StatelessWidget {
  const _SecurityOptionRow({
    required this.label,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF111818),
                fontSize: 17,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          _StaticSwitch(enabled: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StaticSwitch extends StatelessWidget {
  const _StaticSwitch({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!enabled),
      child: SizedBox(
        width: 48,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              right: enabled ? -4 : null,
              left: enabled ? null : -4,
              top: -4,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: enabled ? const Color(0xFF2563EB) : Colors.white,
                  shape: BoxShape.circle,
                  border: enabled
                      ? null
                      : Border.all(color: const Color(0xFFCBD5E1), width: 3),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.check_rounded,
                  color: enabled ? Colors.white : Colors.transparent,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustedDeviceRow extends StatelessWidget {
  const _TrustedDeviceRow({
    required this.icon,
    required this.deviceName,
    required this.subtitle,
    this.subtitleColor = const Color(0xFF638888),
    this.trailing,
    this.trailingColor,
  });

  final IconData icon;
  final String deviceName;
  final String subtitle;
  final Color subtitleColor;
  final String? trailing;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111818),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: subtitleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: GoogleFonts.inter(
                color: trailingColor ?? const Color(0xFFEF4444),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
  }
}

const BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(24)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFF3F4F6))),
  boxShadow: [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ],
);

enum _SecurityToggleType { twoFactor, faceId, loginAlerts }
