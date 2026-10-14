import 'package:flutter/material.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';

enum AppNavTab { home, tracking, notifications, settings }
enum AppBottomMenuThirdTab { notifications, chat }

class AppBottomMenu extends StatelessWidget {
	const AppBottomMenu({
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

	@override
	Widget build(BuildContext context) {
		AppDependencies.instance.notificationBadgeController.start();

		return Container(
			margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			decoration: BoxDecoration(
				color: const Color(0xFFFFFFFF),
				borderRadius: BorderRadius.circular(24),
			),
			child: Row(
				children: [
					Expanded(
						child: _MenuItem(
							icon: Icons.dashboard_outlined,
							activeIcon: Icons.dashboard,
							active: current == AppNavTab.home,
							onTap: () => _goTo(context, AppNavTab.home),
						),
					),
					Expanded(
						child: _MenuItem(
							icon: Icons.map_outlined,
							activeIcon: Icons.map,
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

								return _MenuItem(
									icon: thirdTab == AppBottomMenuThirdTab.chat
											? Icons.chat_bubble_outline_rounded
											: Icons.notifications_none_rounded,
									activeIcon: thirdTab == AppBottomMenuThirdTab.chat
											? Icons.chat_bubble_rounded
											: Icons.notifications_rounded,
									active: current == AppNavTab.notifications,
									showBadge: showBadge,
									onTap: () => _goToThirdTab(context),
								);
							},
						),
					),
					Expanded(
						child: _MenuItem(
							icon: Icons.person_outline_rounded,
							activeIcon: Icons.person_rounded,
							active: current == AppNavTab.settings,
							onTap: () => _goTo(context, AppNavTab.settings),
						),
					),
				],
			),
		);
	}

	void _goTo(BuildContext context, AppNavTab tab) {
		if (tab == current) return;

		final String routeName;
		switch (tab) {
			case AppNavTab.home:
				routeName = homeRouteName;
				break;
			case AppNavTab.tracking:
				routeName = trackingRouteName;
				break;
			case AppNavTab.notifications:
				routeName = AppRoutes.notifications;
				break;
			case AppNavTab.settings:
				routeName = settingsRouteName;
				break;
		}

		Navigator.pushNamed(context, routeName);
	}

	void _goToThirdTab(BuildContext context) {
		if (current == AppNavTab.notifications) return;

		final routeName = thirdTabRouteName ??
				(thirdTab == AppBottomMenuThirdTab.chat
						? AppRoutes.chatList
						: AppRoutes.notifications);
		Navigator.pushNamed(context, routeName);
	}
}

class _MenuItem extends StatelessWidget {
	const _MenuItem({
		required this.icon,
		required this.activeIcon,
		required this.active,
		this.showBadge = false,
		required this.onTap,
	});

	final IconData icon;
	final IconData activeIcon;
	final bool active;
	final bool showBadge;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			borderRadius: BorderRadius.circular(999),
			onTap: onTap,
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 180),
				curve: Curves.easeOut,
				width: 48,
				height: 48,
				decoration: BoxDecoration(
					shape: BoxShape.circle,
					color: active ? const Color(0xFF0FAEB3) : Colors.transparent,
					boxShadow: active
							? const [
									BoxShadow(
										color: Color(0x330FAEB3),
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
							active ? activeIcon : icon,
							color: active ? Colors.white : const Color(0xFF8E96A3),
							size: 21,
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
