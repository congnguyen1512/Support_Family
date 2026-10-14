import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/theme/app_colors.dart';

/// ============================================================
/// SAFE ZONE ALERT SCREEN – Cảnh báo vùng an toàn
/// Hiển thị cảnh báo thành viên đã rời/vào vùng an toàn
/// Dùng dữ liệu thật từ SafeZoneService + FlutterMap
/// ============================================================
class SafeZoneAlertScreen extends StatelessWidget {
  const SafeZoneAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu thật: thành viên đầu tiên + vùng đầu tiên
    final service = SafeZoneProvider.of(context);
    final member = service.members.isNotEmpty ? service.members.first : null;
    final zone = service.zones.isNotEmpty ? service.zones.first : null;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: SafeZoneAlertCard(
          memberName: member?.name ?? 'Không xác định',
          zoneName: zone?.name ?? 'Không xác định',
          latitude: zone?.latitude ?? 10.7769,
          longitude: zone?.longitude ?? 106.7009,
          radius: zone?.radius ?? 500,
          alertType: 'đã rời',
          timestamp: '15:30, 13/02/2024',
        ),
      ),
    );
  }
}

class SafeZoneAlertCard extends StatelessWidget {
  final String memberName;
  final String zoneName;
  final double latitude;
  final double longitude;
  final double radius;
  final String alertType;
  final String timestamp;

  const SafeZoneAlertCard({
    super.key,
    required this.memberName,
    required this.zoneName,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.alertType,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Card chiếm tối đa 95% chiều rộng, không vượt quá 440px
    final cardWidth = (screenWidth * 0.95).clamp(0.0, 440.0);
    // Card chiếm tối đa 95% chiều cao, không vượt quá 900px
    final cardMaxHeight = (screenHeight * 0.95).clamp(0.0, 900.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: cardWidth,
        maxHeight: cardMaxHeight,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 50,
              offset: Offset(0, 25),
              spreadRadius: -12,
            ),
          ],
        ),
        // SingleChildScrollView phòng trường hợp màn hình rất nhỏ
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header: icon cảnh báo + tiêu đề ─────────────────
                _buildHeader(),

                // ── Card thông tin thành viên ─────────────────────────
                _buildMemberCard(),

                const SizedBox(height: 16),

                // ── Bản đồ vùng an toàn (mini-map thật) ─────────────
                _buildMiniMap(),

                const SizedBox(height: 16),

                // ── Khu vực nút hành động ─────────────────────────────
                _buildActions(context),

                // ── Home indicator bar ────────────────────────────────
                _buildHomeIndicator(),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar icon cảnh báo
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
              boxShadow: [
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
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFF5252),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tiêu đề — overflow.ellipsis phòng text dài
          const Text(
            'Cảnh báo vùng an toàn',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: Color(0xFFFF5252),
              fontSize: 24,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // ── Member card ────────────────────────────────────────────────────
  Widget _buildMemberCard() {
    // Lấy chữ cái đầu tên thành viên
    final initials = memberName.isNotEmpty
        ? memberName.split(' ').last[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: ShapeDecoration(
          color: AppColors.background,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x1900ACB2)),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar thành viên
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: const Color(0xFFE5E7EB),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 40,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tên thành viên (dynamic)
            Text(
              memberName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF0C1D1A),
                fontSize: 24,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 4),
            // Trạng thái (dynamic)
            Text(
              '$alertType $zoneName',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                color: Color(0xFFFF5252),
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
            const SizedBox(height: 4),
            // Thời gian (dynamic)
            Text(
              timestamp,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mini-map thật (FlutterMap) ──────────────────────────────────────
  Widget _buildMiniMap() {
    final center = LatLng(latitude, longitude);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AspectRatio(
        aspectRatio: 354 / 198,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFF3F4F6),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Bản đồ thật
              IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 14,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.figma_app',
                    ),
                    // Vòng tròn geofence
                    CircleLayer(circles: [
                      CircleMarker(
                        point: center,
                        radius: (radius / 20).clamp(12.0, 60.0),
                        color: const Color(0x2200ACB2),
                        borderColor: const Color(0xFF00ACB2),
                        borderStrokeWidth: 2,
                      ),
                    ]),
                    // Marker vị trí hiện tại (chấm đỏ — ngoài vùng)
                    MarkerLayer(markers: [
                      Marker(
                        point: LatLng(
                          latitude + 0.004, // Offset nhẹ so với tâm vùng
                          longitude + 0.003,
                        ),
                        width: 16,
                        height: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252),
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.white),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              // Badge "VÙNG AN TOÀN"
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: ShapeDecoration(
                    color: Colors.white.withValues(alpha: 0.90),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'VÙNG AN TOÀN',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 10,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nút "Gọi điện" (primary)
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang gọi cho người thân...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.phone_rounded, size: 20),
              label: const Text('Gọi điện'),
            ),
          ),
          const SizedBox(height: 16),

          // Nút "Xem vị trí" (outlined)
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.safeZoneActive);
              },
              icon: const Icon(Icons.location_on_rounded, size: 20),
              label: const Text('Xem vị trí'),
            ),
          ),
          const SizedBox(height: 16),

          // Nút "Đóng" (text)
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                'Đóng',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Home indicator bar ────────────────────────────────────────────
  Widget _buildHomeIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Container(
          width: 134,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
    );
  }
}


