import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_route_observer.dart';
import 'package:family_guard/core/session/current_user_view_data.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:family_guard/features/profile_security/presentation/screens/personal_info_screen.dart';
import 'package:family_guard/features/profile_security/presentation/widgets/password_security_screen.dart';
import 'package:family_guard/features/settings/presentation/screens/settings_app_theme_screen.dart';
import 'package:family_guard/features/settings/presentation/screens/settings_notification_preferences_screen.dart';
import 'package:family_guard/features/settings/presentation/screens/settings_safety_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const _SettingsHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileCard(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PersonalInfoScreen(
                                homeRouteName: homeRouteName,
                                trackingRouteName: trackingRouteName,
                                settingsRouteName: settingsRouteName,
                                thirdTabRouteName: notificationsRouteName,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SectionBlock(
                          title: 'Tài khoản',
                          items: [
                            _MenuItemData(
                              icon: Icons.person_outline,
                              iconBg: const Color(0xFFEFF6FF),
                              iconColor: const Color(0xFF2563EB),
                              label: 'Thông tin cá nhân',
                              onTap: (ctx) => Navigator.of(ctx).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PersonalInfoScreen(
                                    homeRouteName: homeRouteName,
                                    trackingRouteName: trackingRouteName,
                                    settingsRouteName: settingsRouteName,
                                    thirdTabRouteName: notificationsRouteName,
                                  ),
                                ),
                              ),
                            ),
                            _MenuItemData(
                              icon: Icons.lock_outline,
                              iconBg: const Color(0xFFEEF2FF),
                              iconColor: const Color(0xFF4F46E5),
                              label: 'Mật khẩu & Bảo mật',
                              onTap: (ctx) => Navigator.of(ctx).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PasswordSecurityScreen(
                                    homeRouteName: homeRouteName,
                                    trackingRouteName: trackingRouteName,
                                    notificationsRouteName:
                                        notificationsRouteName,
                                    settingsRouteName: settingsRouteName,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SectionBlock(
                          title: 'Gia đình',
                          items: [
                            _MenuItemData(
                              icon: Icons.groups_2_outlined,
                              iconBg: const Color(0x3317E8E8),
                              iconColor: const Color(0xFF00ACB1),
                              label: 'Quản lý thành viên',
                              onTap: (ctx) => Navigator.pushNamed(
                                ctx,
                                AppRoutes.memberList,
                              ),
                            ),
                            _MenuItemData(
                              icon: Icons.location_on_outlined,
                              iconBg: const Color(0xFFECFDF5),
                              iconColor: const Color(0xFF16A34A),
                              label: 'Vùng an toàn',
                              onTap: (ctx) =>
                                  Navigator.pushNamed(ctx, AppRoutes.safeZone),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SectionBlock(
                          title: 'Tùy chọn',
                          items: [
                            _MenuItemData(
                              icon: Icons.notifications_none,
                              iconBg: const Color(0xFFFFF7ED),
                              iconColor: const Color(0xFFEA580C),
                              label: 'Thông báo',
                              onTap: (ctx) => Navigator.of(ctx).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      SettingsNotificationPreferencesScreen(
                                        homeRouteName: homeRouteName,
                                        trackingRouteName: trackingRouteName,
                                        settingsRouteName: settingsRouteName,
                                        notificationsRouteName:
                                            notificationsRouteName,
                                      ),
                                ),
                              ),
                            ),
                            _MenuItemData(
                              icon: Icons.palette_outlined,
                              iconBg: const Color(0xFFFAF5FF),
                              iconColor: const Color(0xFF9333EA),
                              label: 'Màu sắc ứng dụng',
                              onTap: (ctx) => Navigator.of(ctx).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => SettingsAppThemeScreen(
                                    homeRouteName: homeRouteName,
                                    trackingRouteName: trackingRouteName,
                                    settingsRouteName: settingsRouteName,
                                    notificationsRouteName:
                                        notificationsRouteName,
                                  ),
                                ),
                              ),
                            ),
                            _MenuItemData(
                              icon: Icons.shield_outlined,
                              iconBg: const Color(0xFFF3F4F6),
                              iconColor: const Color(0xFF6B7280),
                              label: 'An toàn',
                              onTap: (ctx) => Navigator.of(ctx).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => SettingsSafetyScreen(
                                    homeRouteName: homeRouteName,
                                    trackingRouteName: trackingRouteName,
                                    settingsRouteName: settingsRouteName,
                                    notificationsRouteName:
                                        notificationsRouteName,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _LogoutButton(onTap: () => _showLogoutDialog(context)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppFlowBottomNav(
                current: AppNavTab.settings,
                homeRouteName: homeRouteName,
                trackingRouteName: trackingRouteName,
                settingsRouteName: settingsRouteName,
                thirdTabRouteName: notificationsRouteName,
              ),
            ),
          ],
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
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111818),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn OK để quay về màn hình đăng nhập, hoặc Hủy để ở lại.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF638888),
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
                          foregroundColor: const Color(0xFF334155),
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
      await AppDependencies.instance.locationTrackingService.stop();
      AppDependencies.instance.safeZoneService.reset();
      await AppDependencies.instance.logoutUseCase();
      if (!context.mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F8F7),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      child: Text(
        'Cài đặt',
        style: GoogleFonts.inter(
          color: const Color(0xFF111818),
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.85,
          height: 42.5 / 34,
        ),
      ),
    );
  }
}

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> with RouteAware {
  late Future<dynamic> _sessionFuture;
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _sessionFuture = AppDependencies.instance.getSavedSessionUseCase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _route) {
      if (_route is PageRoute) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _sessionFuture = AppDependencies.instance.getSavedSessionUseCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _sessionFuture,
      builder: (context, snapshot) {
        final session = snapshot.data;
        final user = CurrentUserViewData.fromSession(session);
        final email = session?.profile.email.trim().isNotEmpty == true
            ? session!.profile.email.trim()
            : session?.email ?? '';

        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFF3F4F6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        color: const Color(0xFFE2E8F0),
                      ),
                      child: ClipOval(
                        child: user.avatarUrl.isNotEmpty
                            ? Image.network(
                                user.avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _ProfileInitials(initials: user.initials),
                              )
                            : _ProfileInitials(initials: user.initials),
                      ),
                    ),
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF111818),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF638888),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileInitials extends StatelessWidget {
  const _ProfileInitials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          color: const Color(0xFF334155),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.title, required this.items});

  final String title;
  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              color: const Color(0xFF638888).withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _SectionItem(item: item),
                  if (index < items.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 68),
                      child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SectionItem extends StatelessWidget {
  const _SectionItem({required this.item});

  final _MenuItemData item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => item.onTap(context),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.inter(
                  color: const Color(0xFF111818),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final void Function(BuildContext context) onTap;
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          'Đăng xuất',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFFEF4444),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
