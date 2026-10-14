import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class SeniorFallAlertScreen extends StatelessWidget {
  const SeniorFallAlertScreen({super.key});

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
                Positioned.fill(child: _MapLayer()),
                Positioned.fill(child: _TopLayer()),
                Positioned.fill(child: _BottomLayer()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapLayer extends StatelessWidget {
  const _MapLayer();

  static const LatLng _safeZoneCenter = LatLng(16.0544, 108.2022);
  static const LatLng _seniorPoint = LatLng(16.0529, 108.2058);
  static const LatLng _userPoint = LatLng(16.0544, 108.2022);
  static const List<LatLng> _routeHistory = [
    LatLng(16.0518, 108.2074),
    LatLng(16.0521, 108.2069),
    LatLng(16.0524, 108.2064),
    LatLng(16.0527, 108.2060),
    LatLng(16.0529, 108.2058),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            children: [
              FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(16.0536, 108.2044),
                  initialZoom: 15.4,
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
                        point: _safeZoneCenter,
                        radius: 200,
                        useRadiusInMeter: true,
                        color: Color(0x333B82F6),
                        borderColor: Color(0xFF3B82F6),
                        borderStrokeWidth: 2,
                      ),
                      CircleMarker(
                        point: _seniorPoint,
                        radius: 110,
                        useRadiusInMeter: true,
                        color: Color(0x22FF6B6B),
                        borderColor: Color(0x55FF6B6B),
                        borderStrokeWidth: 1.6,
                      ),
                    ],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routeHistory,
                        color: Color(0xFFDE4A4A),
                        strokeWidth: 4,
                        borderColor: Color(0xCCFFF5F5),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                  const MarkerLayer(
                    markers: [
                      Marker(
                        point: _seniorPoint,
                        width: 120,
                        height: 132,
                        alignment: Alignment.topCenter,
                        child: _AnimatedAlertMarker(),
                      ),
                      Marker(
                        point: _userPoint,
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: _CurrentLocationDot(),
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
                          const Color(0x12FF6B6B),
                          const Color(0x06FFFFFF),
                          const Color(0x1AFFD9D9),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 296,
          child: Column(
            children: const [
              _FloatingButton(icon: Icons.gps_fixed),
              SizedBox(height: 12),
              _FloatingButton(icon: Icons.layers_outlined),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedAlertMarker extends StatefulWidget {
  const _AnimatedAlertMarker();

  @override
  State<_AnimatedAlertMarker> createState() => _AnimatedAlertMarkerState();
}

class _AnimatedAlertMarkerState extends State<_AnimatedAlertMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
                    scale: 0.85 + progress * multiplier,
                    child: Container(
                      width: 44 + (56 * multiplier),
                      height: 44 + (56 * multiplier),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFFDE4A4A,
                        ).withValues(alpha: 0.08 + (1 - progress) * 0.12),
                        border: Border.all(
                          color: const Color(
                            0xFFDE4A4A,
                          ).withValues(alpha: 0.14 + (1 - progress) * 0.26),
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
                      'https://images.unsplash.com/photo-1581579438747-1dc8d17bbce4?q=80&w=300&auto=format&fit=crop',
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
                'Bà nội',
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

class _CurrentLocationDot extends StatelessWidget {
  const _CurrentLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _TopLayer extends StatelessWidget {
  const _TopLayer();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    _FilterChip(label: 'Tất cả'),
                    _FilterChip(label: 'Trẻ em'),
                    _FilterChip(label: 'Ng.Lớn'),
                    _FilterChip(label: 'Ng.Già', selected: true),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 21,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFD7D7) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.beVietnamPro(
            color: selected ? const Color(0xFFDE4A4A) : const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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

class _BottomLayer extends StatelessWidget {
  const _BottomLayer();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _BottomSheetContent(),
          AppBottomMenu(current: AppNavTab.tracking),
        ],
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _avatar(),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bà nội',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phát hiện té ngã',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF6B6B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.battery_charging_full_rounded,
                                  size: 14,
                                  color: Color(0xFF22C55E),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '82%',
                                  style: GoogleFonts.beVietnamPro(
                                    color: const Color(0xFF334155),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          Expanded(
                            child: _PrimaryOutlineButton(label: 'Xem chi tiết'),
                          ),
                          SizedBox(width: 12),
                          _CircleAction(icon: Icons.call_outlined),
                          SizedBox(width: 8),
                          _CircleAction(
                            icon: Icons.chat_bubble_outline_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    title: 'Lần cuối cập nhật',
                    value: 'Ngay bây giờ',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _InfoChip(title: 'Khoảng cách', value: '5 km'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFF6B6B), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.network(
              'https://images.unsplash.com/photo-1581579438747-1dc8d17bbce4?q=80&w=300&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: -3,
          bottom: -3,
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
              size: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryOutlineButton extends StatelessWidget {
  const _PrimaryOutlineButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFD5D5)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.beVietnamPro(
          color: const Color(0xFFFF6B6B),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF475569)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: const Color(0xFFFFD5D5)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFFFF6B6B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFFDE4A4A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
