import 'package:flutter/material.dart';

class SeniorBottomNav extends StatelessWidget {
  const SeniorBottomNav({
    super.key,
    required this.currentRoute,
    required this.homeRouteName,
    required this.trackingRouteName,
    required this.notificationsRouteName,
    required this.settingsRouteName,
  });

  final String currentRoute;
  final String homeRouteName;
  final String trackingRouteName;
  final String notificationsRouteName;
  final String settingsRouteName;

  @override
  Widget build(BuildContext context) {
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
              active: currentRoute == homeRouteName,
              onTap: () => _goTo(context, homeRouteName),
            ),
          ),
          Expanded(
            child: _SeniorBottomNavItem(
              icon: Icons.map_outlined,
              active: currentRoute == trackingRouteName,
              onTap: () => _goTo(context, trackingRouteName),
            ),
          ),
          Expanded(
            child: _SeniorBottomNavItem(
              icon: Icons.notifications_none_rounded,
              active: currentRoute == notificationsRouteName,
              onTap: () => _goTo(context, notificationsRouteName),
            ),
          ),
          Expanded(
            child: _SeniorBottomNavItem(
              icon: Icons.person_outline_rounded,
              active: currentRoute == settingsRouteName,
              onTap: () => _goTo(context, settingsRouteName),
            ),
          ),
        ],
      ),
    );
  }

  void _goTo(BuildContext context, String routeName) {
    if (routeName == currentRoute) return;
    Navigator.pushNamed(context, routeName);
  }
}

class _SeniorBottomNavItem extends StatelessWidget {
  const _SeniorBottomNavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
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
        child: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : const Color(0xFF98A3B3),
        ),
      ),
    );
  }
}
