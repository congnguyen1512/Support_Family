// ignore_for_file: unused_element

import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_route_observer.dart';
import 'package:family_guard/core/session/current_user_view_data.dart';
import 'package:flutter/material.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:family_guard/features/login/domain/entities/auth_session.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePageNoMember extends StatelessWidget {
  const HomePageNoMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          const _BackgroundShapes(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24 + 72),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _TopBar(),
                  SizedBox(height: 12),
                  _EmptyStateCard(),
                  SizedBox(height: 24),
                  _Utilities(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomMenu(current: AppNavTab.home),
    );
  }
}

class _AppColors {
  static const background = Color(0xFFF0F8F7);
  static const primary = Color(0xFF00ACB1);
  static const primaryBright = Color(0xFF04D1D4);
  static const cardStroke = Color(0x3387E4DB);
  static const title = Color(0xFF1A3C40);
  static const subtitle = Color(0xFF5D7A7D);
}

class _BackgroundShapes extends StatelessWidget {
  const _BackgroundShapes();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                color: _AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: _AppColors.primaryBright,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatefulWidget {
  const _TopBar();

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> with RouteAware {
  late Future<AuthSession?> _sessionFuture;
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

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return 'Ch\u00E0o bu\u1ED5i s\u00E1ng';
    }
    if (hour < 18) {
      return 'Ch\u00E0o bu\u1ED5i chi\u1EC1u';
    }
    return 'Ch\u00E0o bu\u1ED5i t\u1ED1i';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSession?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        final user = CurrentUserViewData.fromSession(snapshot.data);
        final avatar = user.avatarUrl.isNotEmpty
            ? NetworkImage(user.avatarUrl)
            : const NetworkImage('https://picsum.photos/seed/family-guard-user/120.jpg');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                '${_greetingFor(DateTime.now())},\n${user.shortName}',
                style: GoogleFonts.beVietnamPro(
                  color: _AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundImage: avatar,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _AppColors.cardStroke, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0x1900ACB1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: _AppColors.primary,
                  size: 46,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Color(0xFFFFB54D),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có thành viên nào',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _AppColors.title,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bắt đầu bảo vệ người thân bằng\ncách kết nối tài khoản của họ ngay\nbây giờ.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _AppColors.subtitle,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shadowColor: _AppColors.primary.withValues(alpha: 0.3),
              ),
              onPressed: () {},
              child: Text(
                'Kết nối ngay',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Utilities extends StatelessWidget {
  const _Utilities();

  @override
  Widget build(BuildContext context) {
    final utilities = [
      _UtilityItem(
        title: 'Thành viên',
        subtitle: 'Quản lí thành viên',
        icon: Icons.home_outlined,
        color: const Color(0xFF00ACB1),
        accent: const Color(0xFFE6F8F7),
      ),
      _UtilityItem(
        title: 'Tâm trạng',
        subtitle: 'Nhật ký hôm nay',
        icon: Icons.favorite_outline,
        color: const Color(0xFFFFB54D),
        accent: const Color(0xFFFFF3E4),
      ),
      _UtilityItem(
        title: 'An toàn',
        subtitle: 'Thiết lập vùng',
        icon: Icons.location_on_outlined,
        color: const Color(0xFFFC5C7D),
        accent: const Color(0xFFFFECF1),
      ),
      _UtilityItem(
        title: 'Lịch nhắc',
        subtitle: 'Nhắc nhớ hằng ngày',
        icon: Icons.notifications_none,
        color: const Color(0xFF37C7FF),
        accent: const Color(0xFFE8F7FF),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiện ích',
                style: GoogleFonts.publicSans(
                  color: _AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: _AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                ),
                child: Text(
                  'Xem tất cả',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: utilities
                  .map(
                    (item) => SizedBox(
                      width: tileWidth,
                      child: _UtilityTile(item: item),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _UtilityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color accent;

  const _UtilityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.accent,
  });
}

class _UtilityTile extends StatelessWidget {
  final _UtilityItem item;

  const _UtilityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _AppColors.cardStroke, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.accent,
              shape: BoxShape.circle,
              border: Border.all(color: item.color.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: GoogleFonts.publicSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _AppColors.title,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.grid_view_rounded, label: ''),
      _NavItem(icon: Icons.history, label: ''),
      _NavItem(icon: Icons.notifications_none, label: ''),
      _NavItem(icon: Icons.person_outline, label: ''),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final isActive = index == 0;
              return _BottomNavButton(item: items[index], active: isActive);
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _BottomNavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;

  const _BottomNavButton({required this.item, this.active = false});

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(item.icon, color: Colors.white),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.icon,
        color: const Color(0xFF8BA0A4),
      ),
    );
  }
}


