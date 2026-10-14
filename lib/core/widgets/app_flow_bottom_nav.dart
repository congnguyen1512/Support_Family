import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:flutter/material.dart';

export 'package:family_guard/core/widgets/app_bottom_menu.dart'
    show AppBottomMenuThirdTab, AppNavTab;

class AppFlowBottomNav extends StatelessWidget {
  const AppFlowBottomNav({
    super.key,
    required this.current,
    this.homeRouteName = AppRoutes.home,
    this.trackingRouteName = AppRoutes.tracking,
    this.settingsRouteName = AppRoutes.settings,
    this.thirdTab = AppBottomMenuThirdTab.notifications,
    this.thirdTabRouteName,
  });

  final AppNavTab current;
  final String homeRouteName;
  final String trackingRouteName;
  final String settingsRouteName;
  final AppBottomMenuThirdTab thirdTab;
  final String? thirdTabRouteName;

  bool get _isSeniorFlow => homeRouteName == AppRoutes.seniorHome;
  AppBottomMenuThirdTab get _effectiveThirdTab =>
      _isSeniorFlow ? AppBottomMenuThirdTab.chat : thirdTab;

  @override
  Widget build(BuildContext context) {
    if (_isSeniorFlow) {
      return SeniorBottomNav(
        current: current,
        homeRouteName: homeRouteName,
        trackingRouteName: trackingRouteName,
        settingsRouteName: settingsRouteName,
        thirdTab: _effectiveThirdTab,
        thirdTabRouteName: thirdTabRouteName,
      );
    }

    return AppBottomMenu(
      current: current,
      homeRouteName: homeRouteName,
      trackingRouteName: trackingRouteName,
      settingsRouteName: settingsRouteName,
      thirdTab: _effectiveThirdTab,
      thirdTabRouteName: thirdTabRouteName,
    );
  }
}

class SeniorBottomNav extends StatelessWidget {
  const SeniorBottomNav({
    super.key,
    required this.current,
    required this.homeRouteName,
    required this.trackingRouteName,
    required this.settingsRouteName,
    this.thirdTab = AppBottomMenuThirdTab.notifications,
    this.thirdTabRouteName,
  });

  final AppNavTab current;
  final String homeRouteName;
  final String trackingRouteName;
  final String settingsRouteName;
  final AppBottomMenuThirdTab thirdTab;
  final String? thirdTabRouteName;

  @override
  Widget build(BuildContext context) {
    AppDependencies.instance.notificationBadgeController.start();

    return Container(
      margin: const EdgeInsets.fromLTRB(6, 0, 6, 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SeniorBottomNavItem(
              icon: Icons.grid_view_rounded,
              active: current == AppNavTab.home,
              onTap: () => _goTo(context, AppNavTab.home),
            ),
          ),
          Expanded(
            child: _SeniorBottomNavItem(
              icon: Icons.map_outlined,
              active: current == AppNavTab.tracking,
              onTap: () => _goTo(context, AppNavTab.tracking),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: AppDependencies.instance.notificationBadgeController,
              builder: (context, _) {
                final showBadge =
                    thirdTab == AppBottomMenuThirdTab.notifications &&
                    AppDependencies
                        .instance
                        .notificationBadgeController
                        .hasPendingNotifications;

                return _SeniorBottomNavItem(
                  icon: thirdTab == AppBottomMenuThirdTab.chat
                      ? Icons.chat_bubble_outline_rounded
                      : Icons.notifications_none_rounded,
                  active: current == AppNavTab.notifications,
                  showBadge: showBadge,
                  onTap: () => _goTo(context, AppNavTab.notifications),
                );
              },
            ),
          ),
          Expanded(
            child: _SeniorBottomNavItem(
              icon: Icons.person_outline_rounded,
              active: current == AppNavTab.settings,
              onTap: () => _goTo(context, AppNavTab.settings),
            ),
          ),
        ],
      ),
    );
  }

  void _goTo(BuildContext context, AppNavTab tab) {
    if (tab == current) {
      return;
    }

    final routeName = switch (tab) {
      AppNavTab.home => homeRouteName,
      AppNavTab.tracking => trackingRouteName,
      AppNavTab.notifications =>
        thirdTabRouteName ??
            (thirdTab == AppBottomMenuThirdTab.chat
                ? AppRoutes.chatList
                : AppRoutes.notifications),
      AppNavTab.settings => settingsRouteName,
    };

    Navigator.pushNamed(context, routeName);
  }
}

class _SeniorBottomNavItem extends StatelessWidget {
  const _SeniorBottomNavItem({
    required this.icon,
    required this.active,
    this.showBadge = false,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final bool showBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF06B3B8) : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x3306B3B8),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? Colors.white : const Color(0xFF98A3B3),
            ),
            if (showBadge)
              const Positioned(
                top: 10,
                right: 10,
                child: _NotificationDot(),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}
