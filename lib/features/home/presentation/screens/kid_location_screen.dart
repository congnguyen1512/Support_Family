import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KidLocationScreen extends StatelessWidget {
  const KidLocationScreen({super.key});

  static const _bg = Color(0xFFF7FBFF);
  static const _surface = Colors.white;
  static const _teal = Color(0xFF11B7B3);
  static const _tealDark = Color(0xFF0C7D7A);
  static const _text = Color(0xFF16304B);
  static const _muted = Color(0xFF73839B);
  static const _softBlue = Color(0xFFE8F7FF);
  static const _softMint = Color(0xFFE8FAF6);
  static const _headerActionSize = 42.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 124),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 18),
                    _buildMapCard(context),
                    const SizedBox(height: 18),
                    _buildSafeZoneSection(context),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomMenu(
                current: AppNavTab.tracking,
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: _headerActionSize, height: _headerActionSize),
        Expanded(
          child: Text(
            'Vị trí',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              color: _text,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.kidChatList),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: _headerActionSize,
            height: _headerActionSize,
            decoration: const BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: _teal),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.18,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF2F8FF), Color(0xFFE4FBF8)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _KidMapPainter()),
                  ),
                  Positioned(
                    top: 34,
                    right: 44,
                    child: _mapDot(const Color(0xFFCAA7FF)),
                  ),
                  Positioned(
                    top: 80,
                    left: 58,
                    child: _mapDot(const Color(0xFFFFB674)),
                  ),
                  Positioned(
                    bottom: 70,
                    right: 70,
                    child: _mapDot(const Color(0xFF6FE1DB)),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _teal.withValues(alpha: 0.14),
                          ),
                          child: Center(
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _teal,
                              ),
                              child: const Icon(
                                Icons.my_location_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _softMint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: _teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRUNG TÂM HIỆN TẠI',
                                  style: GoogleFonts.beVietnamPro(
                                    color: _muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Trường học',
                                  style: GoogleFonts.lexend(
                                    color: _text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.safeZone,
                            ),
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
                                'Xem vùng',
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  icon: Icons.access_time_rounded,
                  label: 'Cập nhật 2 phút trước',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoChip(
                  icon: Icons.route_rounded,
                  label: 'Đang trong vùng an toàn',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafeZoneSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vùng An Toàn',
            style: GoogleFonts.lexend(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _zoneTile(
            title: 'Trường học',
            subtitle: 'Trường THCS Tân Hưng',
            tag: 'HIỆN TẠI',
            selected: true,
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: 12),
          _zoneTile(
            title: 'Nhà',
            subtitle: 'Chung cư CT4 Peace',
            tag: null,
            selected: false,
            icon: Icons.home_rounded,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.kidChatList),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Xác nhận đến nơi',
                style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required String? tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? _softMint : const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? _teal.withValues(alpha: 0.35)
              : const Color(0xFFE8EEF5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? _teal : const Color(0xFFDFF2F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: selected ? Colors.white : _teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          color: _text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.lexend(
                            color: _tealDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.beVietnamPro(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? _teal : const Color(0xFFB7C2CF),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _tealDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.beVietnamPro(
                color: _text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _KidMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFDCE7F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final minorRoadPaint = Paint()
      ..color = const Color(0xFFE8F0F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * 0.08, size.height * 0.16)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.22,
        size.width * 0.72,
        size.height * 0.10,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.06,
        size.width * 0.96,
        size.height * 0.28,
      );
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.12, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.56,
        size.width * 0.44,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.22,
        size.width * 0.88,
        size.height * 0.18,
      );
    canvas.drawPath(path2, roadPaint);

    final path3 = Path()
      ..moveTo(size.width * 0.18, size.height * 0.14)
      ..lineTo(size.width * 0.22, size.height * 0.86);
    canvas.drawPath(path3, minorRoadPaint);

    final path4 = Path()
      ..moveTo(size.width * 0.58, size.height * 0.12)
      ..lineTo(size.width * 0.48, size.height * 0.92);
    canvas.drawPath(path4, minorRoadPaint);

    final path5 = Path()
      ..moveTo(size.width * 0.06, size.height * 0.50)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.62,
        size.width * 0.90,
        size.height * 0.68,
      );
    canvas.drawPath(path5, minorRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
