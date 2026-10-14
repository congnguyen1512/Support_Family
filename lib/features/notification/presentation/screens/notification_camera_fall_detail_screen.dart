import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kFallDetectionImage = 'assets/images/image_family.png';

class NotificationCameraFallDetailScreen extends StatelessWidget {
  const NotificationCameraFallDetailScreen({
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
            ListView(
              padding: const EdgeInsets.fromLTRB(22, 118, 22, 120),
              children: const [_CameraFallDetailCard()],
            ),
            _NotificationHeader(settingsRouteName: AppRoutes.settings),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppFlowBottomNav(
                current: AppNavTab.notifications,
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
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.settingsRouteName});

  final String settingsRouteName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(24, 8, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Thông báo',
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.75,
              height: 1,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, settingsRouteName),
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF334155),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraFallDetailCard extends StatelessWidget {
  const _CameraFallDetailCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 18, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phòng khách',
                        style: GoogleFonts.beVietnamPro(
                          color: const Color(0xFF161D1D),
                          fontSize: 34 / 1.88,
                          fontWeight: FontWeight.w700,
                          height: 28 / 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00ACB2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trực tuyến',
                            style: GoogleFonts.beVietnamPro(
                              color: const Color(0xFF3C4949),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.settings, color: Color(0xFF00ACB2), size: 22),
              ],
            ),
          ),
          SizedBox(
            height: 186,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(_kFallDetectionImage, fit: BoxFit.cover),
                Positioned(
                  left: 62,
                  right: 22,
                  top: 78,
                  bottom: 32,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFBA1A1A),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Positioned(
                  left: 62,
                  top: 78,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFBA1A1A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PHÁT HIỆN TÉ NGÃ',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 15 / 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '10:32 AM',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF00ACB1),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 28 / 18,
                  ),
                ),
                Text(
                  '11/04/2026',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF00ACB1),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 28 / 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
