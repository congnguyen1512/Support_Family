import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class ChildAlertMapScreen extends StatelessWidget {
  const ChildAlertMapScreen({super.key});

  static const LatLng _childLocation = LatLng(16.0544, 108.2022);
  static const LatLng _safeZoneCenter = LatLng(16.0544, 108.2022);
  static const List<LatLng> _routeHistory = [
    LatLng(16.0528, 108.1988),
    LatLng(16.0533, 108.1998),
    LatLng(16.0539, 108.2007),
    LatLng(16.0544, 108.2015),
    LatLng(16.0544, 108.2022),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: const [
                Positioned.fill(child: _AlertMapLayer()),
                Positioned.fill(child: _AlertMapOverlay()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertMapLayer extends StatelessWidget {
  const _AlertMapLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(16.0544, 108.2022),
              initialZoom: 15.5,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.familyguard.app',
              ),
              const CircleLayer(
                circles: [
                  CircleMarker(
                    point: ChildAlertMapScreen._safeZoneCenter,
                    radius: 200,
                    useRadiusInMeter: true,
                    color: Color(0x10FF6B6B),
                    borderColor: Color(0x40FF6B6B),
                    borderStrokeWidth: 1.5,
                  ),
                  CircleMarker(
                    point: ChildAlertMapScreen._childLocation,
                    radius: 96,
                    useRadiusInMeter: true,
                    color: Color(0x26FF6B6B),
                    borderColor: Color(0x66FF6B6B),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: ChildAlertMapScreen._routeHistory,
                    color: Color(0xFFDE4A4A),
                    strokeWidth: 4,
                    borderColor: Color(0xCCFFF5F5),
                    borderStrokeWidth: 1.4,
                  ),
                ],
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                    point: ChildAlertMapScreen._childLocation,
                    width: 120,
                    height: 132,
                    alignment: Alignment.topCenter,
                    child: _AnimatedChildMarker(),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 232,
          child: Column(
            children: const [
              _FloatingButton(icon: Icons.gps_fixed_rounded),
              SizedBox(height: 12),
              _FloatingButton(icon: Icons.layers_outlined),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertMapOverlay extends StatelessWidget {
  const _AlertMapOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x24FF6B6B),
                    const Color(0x12FFF5F5),
                    const Color(0x2EFFCACA),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top + 14,
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFF0F172A),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bản đồ cảnh báo',
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cảnh báo khẩn cấp',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFFFF6B6B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Xôi',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF171D1D),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '123 Nguyễn Hữu Thọ, Đà Nẵng',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF475569),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: 'Cập nhật',
                        value: 'Ngay bây giờ',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoChip(label: 'Khoảng cách', value: '0.5 km'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedChildMarker extends StatefulWidget {
  const _AnimatedChildMarker();

  @override
  State<_AnimatedChildMarker> createState() => _AnimatedChildMarkerState();
}

class _AnimatedChildMarkerState extends State<_AnimatedChildMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final progress = _pulseController.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                for (final multiplier in [1.0, 0.72, 0.44])
                  Transform.scale(
                    scale: 0.84 + progress * multiplier,
                    child: Container(
                      width: 44 + (58 * multiplier),
                      height: 44 + (58 * multiplier),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFFDE4A4A,
                        ).withValues(alpha: 0.08 + (1 - progress) * 0.12),
                        border: Border.all(
                          color: const Color(
                            0xFFDE4A4A,
                          ).withValues(alpha: 0.14 + (1 - progress) * 0.24),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDE4A4A),
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1621452773781-0f992fd1f5cb?q=80&w=300&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Xôi',
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingButton extends StatelessWidget {
  const _FloatingButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: const Color(0xFF475569)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF171D1D),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
