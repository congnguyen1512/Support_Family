import 'package:family_guard/features/kid_management/presentation/shared/kid_management_data.dart';
import 'package:family_guard/features/kid_management/presentation/shared/kid_management_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class KidSafetyScreen extends StatelessWidget {
  const KidSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KidDetailScaffold(
      title: 'An toàn',
      padding: const EdgeInsets.fromLTRB(27, 12, 27, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: KidSectionHeading('Vị trí trực tiếp')),
              Text(
                'Đang hoạt động',
                style: kidTextStyle(
                  size: 14,
                  weight: FontWeight.w600,
                  color: const Color(0xFF00696C),
                  height: 20 / 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          KidSurfaceCard(
            padding: const EdgeInsets.all(4),
            radius: 48,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: SizedBox(
                    height: 192,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AbsorbPointer(
                            child: FlutterMap(
                              options: const MapOptions(
                                initialCenter: kidMapCenter,
                                initialZoom: 16,
                                interactionOptions: InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
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
                                      point: safeZoneCenter,
                                      radius: 80,
                                      color: Color(0x4476F5FA),
                                      borderColor: Color(0x3376F5FA),
                                      borderStrokeWidth: 1.5,
                                    ),
                                  ],
                                ),
                                const MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: kidMapCenter,
                                      width: 56,
                                      height: 56,
                                      alignment: Alignment.center,
                                      child: KidMapMarker(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF01ADB2),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_user_outlined,
                                  size: 14,
                                  color: Color(0xFF003A3C),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Vùng an toàn: Bật',
                                  style: kidTextStyle(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: const Color(0xFF003A3C),
                                    height: 16 / 12,
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
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HIỆN TẠI',
                            style: kidTextStyle(
                              size: 12,
                              weight: FontWeight.w500,
                              color: const Color(0xFF3C4949),
                              height: 16 / 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ở trường',
                            style: kidTextStyle(
                              size: 20,
                              weight: FontWeight.w700,
                              color: const Color(0xFF171D1D),
                              height: 28 / 20,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      KidFilledPillButton(
                        label: 'Xem bản đồ',
                        backgroundColor: const Color(0xFF00696C),
                        foregroundColor: Colors.white,
                        onTap: () => openFamilyMap(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const KidSectionHeading('Vùng An Toàn'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5F4),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Column(
              children: [
                KidSafeZoneTile(
                  icon: Icons.home_outlined,
                  title: 'Nhà',
                  subtitle: 'Bán kính 100m',
                  onTap: () => openSafeZone(context),
                ),
                const SizedBox(height: 12),
                KidSafeZoneTile(
                  icon: Icons.school_outlined,
                  title: 'Trường học',
                  subtitle: 'Bán kính 200m',
                  onTap: () => openSafeZone(context),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => openSafeZone(context),
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFBBC9C9),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Color(0xFF00696C),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thêm Vùng an toàn',
                          style: kidTextStyle(
                            size: 14,
                            weight: FontWeight.w700,
                            color: const Color(0xFF00696C),
                            height: 20 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          KidSurfaceCard(
            padding: const EdgeInsets.all(24),
            radius: 48,
            backgroundColor: const Color(0xFFEFF5F4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch sử di chuyển',
                        style: kidTextStyle(
                          size: 18,
                          weight: FontWeight.w700,
                          color: const Color(0xFF171D1D),
                          height: 28 / 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.route_rounded,
                            size: 14,
                            color: Color(0xFF00696C),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Đã di chuyển 3km',
                            style: kidTextStyle(
                              size: 14,
                              weight: FontWeight.w500,
                              color: const Color(0xFF3C4949),
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                KidFilledPillButton(
                  label: 'Xem',
                  backgroundColor: const Color(0xFFBDEBEC),
                  foregroundColor: const Color(0xFF406B6D),
                  onTap: () => openRoutePlayback(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const KidSectionHeading('Cảnh báo gần đây'),
          const SizedBox(height: 16),
          const KidAlertListTile(
            icon: Icons.battery_alert_rounded,
            iconBackground: Color(0xFFBA1A1A),
            backgroundColor: Color(0x4DFFDAD6),
            title: 'Pin yếu',
            subtitle: '12% • 14:30 PM',
            subtitleColor: Color(0xFF93000A),
          ),
          const SizedBox(height: 12),
          const KidAlertListTile(
            icon: Icons.logout_rounded,
            iconBackground: Color(0xFFE2844C),
            backgroundColor: Color(0x4DFFDBCA),
            title: 'Rời khỏi vùng an toàn',
            subtitle: 'Đã rời khỏi khu vực Trường học • 15:15 PM',
            subtitleColor: Color(0xFF592400),
          ),
        ],
      ),
    );
  }
}
