import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/alerts/presentation/screens/child_alert_map_screen.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/calling/presentation/widgets/call_bottom_sheets.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class ChildEmergencyAlertScreen extends StatelessWidget {
  const ChildEmergencyAlertScreen({super.key});

  static const LatLng childLocation = LatLng(16.0544, 108.2022);
  static const String childName = 'Xôi';
  static const String childAvatarUrl =
      'https://images.unsplash.com/photo-1621452773781-0f992fd1f5cb?q=80&w=300&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onBack: () => Navigator.maybePop(context)),
              const SizedBox(height: 14),
              const _ProfileCard(),
              const SizedBox(height: 26),
              const _LocationCard(),
              const SizedBox(height: 26),
              _ActionTile(
                icon: Icons.call_rounded,
                iconColor: const Color(0xFF00696C),
                iconBackground: const Color(0xFFD8F2F2),
                title: 'Gọi Thoại',
                onTap: () => showRoleCallOptionsSheet(
                  context,
                  target: const CallTargetArgs(
                    name: childName,
                    avatarUrl: childAvatarUrl,
                    role: MemberRole.child,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _ActionTile(
                icon: Icons.map_rounded,
                iconColor: const Color(0xFF00696C),
                iconBackground: const Color(0xFFD8F2F2),
                title: 'Xem vị trí',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChildAlertMapScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _ActionTile(
                icon: Icons.chat_bubble_rounded,
                iconColor: const Color(0xFF6D28D9),
                iconBackground: const Color(0xFFF0E7FF),
                title: 'Gửi tin nhắn',
                onTap: () => Navigator.pushNamed(context, AppRoutes.chatList),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () => _showMarkSafeDialog(context),
                borderRadius: BorderRadius.circular(48),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33FF6B6B),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Đánh dấu an toàn',
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Việc đánh dấu an toàn sẽ gửi thông báo cho người thân rằng tình huống đã được xử lý.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF3C4949),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showMarkSafeDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 38),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 50,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Đánh dấu an toàn',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Xôi sẽ được đánh dấu là an toàn khi nhấn nút này. Bạn chắc chắn?',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shadowColor: const Color(0x3319A7A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Đánh dấu là an toàn',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirmed == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu an toàn cho Xôi.')),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_left_rounded, color: Color(0xFFFF6B6B)),
            Text(
              'Cảnh báo khẩn cấp',
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFFFF6B6B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x33FF6B6B), width: 4),
                ),
                child: ClipOval(
                  child: Image.network(
                    ChildEmergencyAlertScreen.childAvatarUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            ChildEmergencyAlertScreen.childName,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF171D1D),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Đang cần trợ giúp',
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFFFF6B6B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatefulWidget {
  const _LocationCard();

  @override
  State<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<_LocationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _markerController;

  @override
  void initState() {
    super.initState();
    _markerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _markerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(
                      initialCenter: ChildEmergencyAlertScreen.childLocation,
                      initialZoom: 17,
                      minZoom: 3,
                      maxZoom: 18,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.familyguard.app',
                      ),
                      const CircleLayer(
                        circles: [
                          CircleMarker(
                            point: ChildEmergencyAlertScreen.childLocation,
                            radius: 72,
                            useRadiusInMeter: true,
                            color: Color(0x1CFF6B6B),
                            borderColor: Color(0x55FF6B6B),
                            borderStrokeWidth: 1.5,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: ChildEmergencyAlertScreen.childLocation,
                            width: 120,
                            height: 120,
                            alignment: Alignment.center,
                            child: AnimatedBuilder(
                              animation: _markerController,
                              builder: (context, _) {
                                final t = _markerController.value;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    for (final scale in [1.0, 1.3, 1.6])
                                      Transform.scale(
                                        scale: scale + t * 0.5,
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFFFF1500)
                                                .withValues(
                                                  alpha: 0.08 + (1 - t) * 0.12,
                                                ),
                                            border: Border.all(
                                              color: const Color(0xFFFF6B6B)
                                                  .withValues(
                                                    alpha: 0.1 + (1 - t) * 0.18,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF1500),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0x33FF6B6B),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0x14FF6B6B),
                              const Color(0x00FFFFFF),
                              const Color(0x26FFD8D8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Color(0xFF3C4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hiện tại',
                            style: GoogleFonts.beVietnamPro(
                              color: const Color(0xFF3C4949),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VỊ TRÍ HIỆN TẠI',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF00696C),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '123 Nguyễn Hữu Thọ, Đà Nẵng',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF171D1D),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF171D1D),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF3C4949)),
          ],
        ),
      ),
    );
  }
}
