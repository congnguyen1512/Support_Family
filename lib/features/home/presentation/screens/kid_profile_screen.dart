// ignore_for_file: unused_element

import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/session/current_user_view_data.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:family_guard/features/home/presentation/screens/kid_flow_models.dart';
import 'package:family_guard/features/notification/presentation/screens/notification_screen.dart';
import 'package:family_guard/features/profile_security/presentation/screens/personal_info_screen.dart';
import 'package:family_guard/features/settings/presentation/screens/settings_app_theme_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KidProfileScreen extends StatelessWidget {
  const KidProfileScreen({super.key});

  static const _bg = Color(0xFFF7FBFF);
  static const _surface = Colors.white;
  static const _teal = Color(0xFF11B7B3);
  static const _tealDark = Color(0xFF0D7F7B);
  static const _text = Color(0xFF16304B);
  static const _muted = Color(0xFF73839B);
  static const _softBlue = Color(0xFFEAF4FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 126),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    FutureBuilder(
                      future: AppDependencies.instance.getSavedSessionUseCase(),
                      builder: (context, snapshot) {
                        return _buildProfileCard(
                          CurrentUserViewData.fromSession(snapshot.data),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildFamilyTrustCard(context),
                    const SizedBox(height: 18),
                    _buildActionList(context),
                    const SizedBox(height: 18),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomMenu(
                current: AppNavTab.settings,
                homeRouteName: AppRoutes.kidHome,
                trackingRouteName: AppRoutes.kidLocation,
                settingsRouteName: AppRoutes.kidProfile,
                thirdTab: AppBottomMenuThirdTab.chat,
                thirdTabRouteName: AppRoutes.kidChatList,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Center(
        child: Text(
          'Thông tin cá nhân',
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            color: _text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _legacyBuildProfileCard(CurrentUserViewData userView) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFE7D8), Color(0xFFF7C6B4)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  userView.initials,
                  style: GoogleFonts.lexend(
                    color: _text,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Xôi',
            style: GoogleFonts.lexend(
              color: _text,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '12 tuổi',
            style: GoogleFonts.beVietnamPro(
              color: _muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(CurrentUserViewData userView) {
    return _buildProfileCardContainer(
      initials: userView.initials,
      shortName: userView.shortName,
      ageLabel: userView.ageLabel,
    );
  }

  Widget _buildProfileCardContainer({
    required String initials,
    required String shortName,
    required String ageLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFE7D8), Color(0xFFF7C6B4)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.isEmpty ? 'U' : initials,
                  style: GoogleFonts.lexend(
                    color: _text,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            shortName.isEmpty ? 'Ban' : shortName,
            style: GoogleFonts.lexend(
              color: _text,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (ageLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              ageLabel,
              style: GoogleFonts.beVietnamPro(
                color: _muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFamilyTrustCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kết nối gia đình của con',
                  style: GoogleFonts.lexend(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.kidChatList),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _softBlue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Mở chat',
                    style: GoogleFonts.lexend(
                      color: _tealDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...KidFlowModels.threads
                  .skip(1)
                  .take(2)
                  .map(
                    (thread) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: thread.person.accent,
                        child: Text(
                          thread.person.initial,
                          style: GoogleFonts.lexend(
                            color: _text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Mẹ, Bố và 1 người khác luôn thấy vị trí khi khẩn cấp',
                  style: GoogleFonts.beVietnamPro(
                    color: _muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.safeZone),
          borderRadius: BorderRadius.circular(32),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFC8DEE0),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 20,
                      color: Color(0xFF0C6E71),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vùng An Toàn',
                        style: GoogleFonts.beVietnamPro(
                          color: const Color(0xFF0A6F74),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A6F74),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Đang Bật',
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [_safeZoneChip('Nhà'), _safeZoneChip('Trường học')],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              _profileMenuRow(
                icon: Icons.account_circle_outlined,
                title: 'Thông tin cá nhân',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PersonalInfoScreen(
                      showBackButton: false,
                      homeRouteName: AppRoutes.kidHome,
                      trackingRouteName: AppRoutes.kidLocation,
                      settingsRouteName: AppRoutes.kidProfile,
                      thirdTab: AppBottomMenuThirdTab.chat,
                      thirdTabRouteName: AppRoutes.kidChatList,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFD7DEE4)),
              _profileMenuRow(
                icon: Icons.notifications,
                title: 'Thông báo',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const NotificationScreen(showBottomNav: false),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFD7DEE4)),
              _profileMenuRow(
                icon: Icons.palette_outlined,
                title: 'Màu sắc ứng dụng',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsAppThemeScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _safeZoneChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.beVietnamPro(
          color: const Color(0xFF0A6F74),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }

  Widget _profileMenuRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7B858A), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF23272A),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF747D83),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'Đăng xuất',
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            color: const Color(0xFFEF4444),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  'Đăng xuất?',
                  style: GoogleFonts.lexend(
                    color: _text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn OK để quay về màn hình đăng nhập, hoặc Hủy để tiếp tục.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    color: _muted,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _text,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('OK'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      await AppDependencies.instance.logoutUseCase();
      if (!context.mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }
}
