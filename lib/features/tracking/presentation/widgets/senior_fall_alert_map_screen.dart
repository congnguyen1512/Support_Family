import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class SeniorFallAlertMapScreen extends StatefulWidget {
  const SeniorFallAlertMapScreen({
    super.key,
    this.fallLatitude,
    this.fallLongitude,
    this.seniorLabel,
  });

  final double? fallLatitude;
  final double? fallLongitude;
  final String? seniorLabel;

  @override
  State<SeniorFallAlertMapScreen> createState() =>
      _SeniorFallAlertMapScreenState();
}

class _SeniorFallAlertMapScreenState extends State<SeniorFallAlertMapScreen> {
  static const double _navExtentPx = 82;
  static const double _sheetInitialSize = 0.18;
  static const double _sheetMinSize = 0.12;
  static const double _sheetMaxSize = 0.30;

  double _sheetExtent = _sheetInitialSize;

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        widget.fallLatitude != null && widget.fallLongitude != null;
    final focusPoint = hasLocation
        ? LatLng(widget.fallLatitude!, widget.fallLongitude!)
        : const LatLng(16.0544, 108.2022);
    final displayName = _displayName(widget.seniorLabel);
    const statusText = 'Phát hiện té ngã';
    final showBottomNav = _sheetExtent <= (_sheetMinSize + 0.015);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _AlertMapLayer(
                    focusPoint: focusPoint,
                    displayName: displayName,
                    hasLocation: hasLocation,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.maybePop(context),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1E293B),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: showBottomNav ? 1 : 0,
                    child: const AppBottomMenu(current: AppNavTab.tracking),
                  ),
                ),
                Positioned.fill(
                  bottom: showBottomNav ? _navExtentPx : 0,
                  child: NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      if (!mounted) {
                        return false;
                      }
                      setState(() => _sheetExtent = notification.extent);
                      return false;
                    },
                    child: DraggableScrollableSheet(
                      initialChildSize: _sheetInitialSize,
                      minChildSize: _sheetMinSize,
                      maxChildSize: _sheetMaxSize,
                      snap: true,
                      snapSizes: const [_sheetMinSize, _sheetMaxSize],
                      builder: (context, controller) {
                        return _AlertBottomSheet(
                          scrollController: controller,
                          displayName: displayName,
                          statusText: statusText,
                          hasLocation: hasLocation,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _displayName(String? seniorLabel) {
    final label = seniorLabel?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }

    return 'Người thân';
  }
}

class _AlertMapLayer extends StatelessWidget {
  const _AlertMapLayer({
    required this.focusPoint,
    required this.displayName,
    required this.hasLocation,
  });

  final LatLng focusPoint;
  final String displayName;
  final bool hasLocation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: focusPoint,
              initialZoom: hasLocation ? 15.2 : 12.7,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.familyguard.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: focusPoint,
                    width: 120,
                    height: 140,
                    alignment: Alignment.topCenter,
                    child: _AlertMarker(label: displayName),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          top: 365,
          child: Column(
            children: [
              _MapActionButton(icon: Icons.gps_fixed, onTap: () {}),
              const SizedBox(height: 12),
              _MapActionButton(icon: Icons.layers_outlined, onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertMarker extends StatefulWidget {
  const _AlertMarker({required this.label});

  final String label;

  @override
  State<_AlertMarker> createState() => _AlertMarkerState();
}

class _AlertMarkerState extends State<_AlertMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, _) {
        final t = _blinkController.value;
        final borderColor = Color.lerp(
          const Color(0xFFDE4A4A),
          const Color(0x99FF6B6B),
          t,
        )!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(4, (index) {
                  final phase = (t + index * 0.2) % 1.0;
                  final opacity = 0.15 + (1 - phase) * 0.35;
                  final size = 58.0 + index * 9.0;
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0xFFFF6B6B,
                        ).withValues(alpha: opacity),
                        width: 2,
                      ),
                    ),
                  );
                }),
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2.6),
                    boxShadow: [
                      const BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                      BoxShadow(
                        color: const Color(
                          0x66FF6B6B,
                        ).withValues(alpha: 0.15 + (1 - t) * 0.45),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const ClipOval(
                    child: Icon(
                      Icons.personal_injury_rounded,
                      color: Color(0xFFDC2626),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                widget.label,
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
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
      ),
    );
  }
}

class _AlertBottomSheet extends StatelessWidget {
  const _AlertBottomSheet({
    required this.scrollController,
    required this.displayName,
    required this.statusText,
    required this.hasLocation,
  });

  final ScrollController scrollController;
  final String displayName;
  final String statusText;
  final bool hasLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
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
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF1F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.personal_injury_rounded,
                      color: Color(0xFFDC2626),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          statusText,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF6B6B),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!hasLocation)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5E5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Đang chờ tọa độ từ DB',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFB91C1C),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.inAppCall,
                      arguments: InAppCallArgs(
                        name: displayName,
                        avatarUrl:
                            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
                        role: MemberRole.senior,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.call_rounded, size: 20),
                  label: Text(
                    'Gọi ngay',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
}
