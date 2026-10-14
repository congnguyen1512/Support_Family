import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';

/// ============================================================
/// SAFE ZONE DELETE CONFIRM SCREEN - Xác nhận xóa vùng an toàn
/// Được dịch và sửa lỗi từ Figma Dev Mode export
/// Hiển thị map nền + modal bottom sheet xác nhận xóa
/// ============================================================
class SafeZoneDeleteConfirmScreen extends StatefulWidget {
  const SafeZoneDeleteConfirmScreen({super.key});

  @override
  State<SafeZoneDeleteConfirmScreen> createState() =>
      _SafeZoneDeleteConfirmScreenState();
}

class _SafeZoneDeleteConfirmScreenState
    extends State<SafeZoneDeleteConfirmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    // Tự động mở modal khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animController.reverse().then((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  void _confirmDelete() {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final service = SafeZoneProvider.read(context);
    final zones = service.zones;
    final zone = zones.isNotEmpty ? zones.first : null;
    final zoneName = zone?.name ?? 'Nhà riêng';

    // Actually remove from service
    if (zone != null) {
      service.removeZone(zone.id);
    }

    _animController.reverse().then((_) {
      if (!mounted) return;
      navigator.popUntil(ModalRoute.withName(AppRoutes.safeZoneActive));
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã xóa vùng an toàn "$zoneName"'),
          backgroundColor: const Color(0xFF111827),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'HOÀN TÁC',
            textColor: const Color(0xFF00ACB2),
            onPressed: () {
              if (zone != null) service.addZone(zone);
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Nền: map + zone circle + AppBar + search bar ──────
          _buildMapBackground(context),

          // ── Lớp mờ overlay ─────────────────────────────────────
          AnimatedBuilder(
            animation: _fadeAnim,
            builder: (_, _) => Opacity(
              opacity: _fadeAnim.value * 0.45,
              child: Container(color: Colors.black),
            ),
          ),

          // ── Modal bottom sheet xác nhận ─────────────────────────
          AnimatedBuilder(
            animation: _slideAnim,
            builder: (_, child) => FractionalTranslation(
              translation: Offset(0, _slideAnim.value),
              child: child,
            ),
            child: _buildConfirmSheet(context),
          ),
        ],
      ),
    );
  }

  // ── Nền bản đồ (tái sử dụng từ edit screen) ───────────────────────
  Widget _buildMapBackground(BuildContext context) {
    final service = SafeZoneProvider.of(context);
    final zones = service.zones;
    final center = zones.isNotEmpty
        ? LatLng(zones.first.latitude, zones.first.longitude)
        : const LatLng(10.7769, 106.7009);
    final radius = zones.isNotEmpty ? zones.first.radius : 500.0;

    return Column(
      children: [
        SizedBox(
          height: 530,
          child: Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.figma_app',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: center,
                          radius: radius / 10,
                          color: const Color(0x4C00ACB2),
                          borderColor: const Color(0xFF00ACB2),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Zone circle + pin ở giữa
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vòng tròn zone
                    Container(
                      width: 256,
                      height: 256,
                      decoration: ShapeDecoration(
                        color: const Color(0x4C00ACB2),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2, color: Color(0xFF00ACB2)),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    // Location pin
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00ACB2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Container(width: 4, height: 8, color: const Color(0xFF00ACB2)),
                      ],
                    ),
                    // Badge bán kính
                    Positioned(
                      bottom: 36,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: ShapeDecoration(
                          color: Colors.white.withValues(alpha: 0.90),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0x3300ACB2)),
                            borderRadius: BorderRadius.circular(9999),
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
                        child: const Text(
                          '500m',
                          style: TextStyle(
                            color: Color(0xFF00ACB2),
                            fontSize: 12,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.33,
                          ),
                        ),
                      ),
                    ),
                    // Resize handle
                    Positioned(
                      right: 4,
                      top: 100,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 2, color: const Color(0xFF00ACB2)),
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
                        child: const Icon(Icons.open_with_rounded,
                            size: 16, color: Color(0xFF00ACB2)),
                      ),
                    ),
                  ],
                ),
              ),

              // Nút GPS
              Positioned(
                right: 16,
                bottom: 80,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 10,
                        offset: Offset(0, 8),
                        spreadRadius: -6,
                      ),
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 25,
                        offset: Offset(0, 20),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: Color(0xFF00ACB2), size: 22),
                ),
              ),

              // Search bar
              Positioned(
                left: 16,
                right: 16,
                top: 76,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 1, color: Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    shadows: const [
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
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: Color(0xFF9CA3AF), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tìm địa điểm mới',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay AppBar
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: AppBackHeaderBar(
                  title: 'Vùng an toàn',
                  onBack: _dismiss,
                ),
              ),
            ],
          ),
        ),

        // Bottom panel phía sau (mờ do overlay)
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Modal xác nhận xóa ────────────────────────────────────────────
  Widget _buildConfirmSheet(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 40,
              offset: Offset(0, -12),
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.only(
            top: 20, left: 24, right: 24, bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pull handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),

            // Icon cảnh báo
            Container(
              width: 72,
              height: 72,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14EF4444),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Color(0xFFEF4444),
                size: 36,
              ),
            ),

            // Tiêu đề
            const Text(
              'Xóa vùng an toàn?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 22,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.36,
              ),
            ),

            const SizedBox(height: 12),

            // Tên + địa chỉ vùng
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: ShapeDecoration(
                color: const Color(0xFFFFFBEB),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFFDE68A)),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Color(0xFFD97706),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nhà riêng',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '123 Đường Nguyễn Huệ, Quận 1, TP. HCM',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Thông báo cảnh báo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              margin: const EdgeInsets.only(bottom: 28),
              decoration: ShapeDecoration(
                color: const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFFECACA)),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Sau khi xóa, tất cả dữ liệu liên quan tới vùng an toàn này sẽ bị mất vĩnh viễn và không thể khôi phục.',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        height: 1.54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Nút hành động
            Row(
              children: [
                // Nút Hủy
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _dismiss,
                      child: const Text('Hủy'),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Nút Xóa
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _confirmDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                      icon: const Icon(Icons.delete_rounded, size: 20),
                      label: const Text('Xóa vùng'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




