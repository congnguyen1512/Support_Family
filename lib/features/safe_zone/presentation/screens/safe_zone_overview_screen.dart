import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';
import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/safe_zone/presentation/widgets/legacy_safe_zone_scope.dart';
import 'package:family_guard/features/safe_zone/presentation/widgets/safe_zone_active_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SafeZoneOverviewScreen extends StatefulWidget {
  const SafeZoneOverviewScreen({super.key});

  @override
  State<SafeZoneOverviewScreen> createState() => _SafeZoneOverviewScreenState();
}

class _SafeZoneOverviewScreenState extends State<SafeZoneOverviewScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Tai lai moi lan mo man hinh de dong bo vung do nguoi cham soc khac tao.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SafeZoneProvider.maybeOf(context)?.refresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SafeZoneProvider.of(context).initialize();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = SafeZoneProvider.of(context);
    final zones = service.zones;
    final members = service.members;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      appBar: AppBackHeaderBar(
        title: 'Quản lý vùng an toàn',
        trailingAreaWidth: 88,
        trailing: TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.safeZoneEditActive),
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: Color(0xCC00ACB2),
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F8F7), Color(0xFFF0F8F7)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _MapCard(mapController: _mapController, zones: zones),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'THANH VIEN GIA DINH',
                style: TextStyle(
                  color: Color(0x9900ACB2),
                  fontSize: 13,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (members.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _EmptyCard(
                  message: 'Chua co thanh vien da xac nhan de ap dung vung an toan.',
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: members
                      .map(
                        (member) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MemberCard(
                            member: member,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LegacySafeZoneScope(
                                    child: SafeZoneMemberScreen(
                                      member: {
                                        'id': member.id,
                                        'name': member.name,
                                        'role': member.ageGroup,
                                        'avatar': member.name.isEmpty
                                            ? 'T'
                                            : member.name.substring(0, 1).toUpperCase(),
                                        'activeZones': member.zoneCount,
                                        'color': member.badgeTextColor,
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.08,
                children: [
                  _ActionCard(
                    icon: Icons.add_location_alt_outlined,
                    label: 'Them vung moi',
                    onTap: () {
                      if (members.isEmpty) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LegacySafeZoneScope(
                            child: SafeZoneMemberScreen(
                              member: {
                                'id': members.first.id,
                                'name': members.first.name,
                                'role': members.first.ageGroup,
                                'avatar': members.first.name.isEmpty
                                    ? 'T'
                                    : members.first.name.substring(0, 1).toUpperCase(),
                                'activeZones': members.first.zoneCount,
                                'color': members.first.badgeTextColor,
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _ActionCard(
                    icon: Icons.history_toggle_off_rounded,
                    label: 'Lich su di chuyen',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.activityHistory),
                  ),
                  _ActionCard(
                    icon: Icons.notifications_active_outlined,
                    label: 'Canh bao',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.safeZoneAlert),
                  ),
                  _ActionCard(
                    icon: Icons.settings_outlined,
                    label: 'Cai dat',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.safeZoneAlertSettings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.mapController,
    required this.zones,
  });

  final MapController mapController;
  final List<SafeZone> zones;

  @override
  Widget build(BuildContext context) {
    final center = zones.isEmpty
        ? const LatLng(10.7769, 106.7009)
        : LatLng(zones.first.latitude, zones.first.longitude);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Container(
        width: double.infinity,
        height: 260,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x1900ACB2), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1400ACB2),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.familyguard.app',
                  maxZoom: 19,
                ),
                CircleLayer(
                  circles: zones
                      .map(
                        (zone) => CircleMarker(
                          point: LatLng(zone.latitude, zone.longitude),
                          radius: zone.radius,
                          useRadiusInMeter: true,
                          color: const Color(0x3300ACB2),
                          borderColor: const Color(0xFF00ACB2),
                          borderStrokeWidth: 2,
                        ),
                      )
                      .toList(),
                ),
                MarkerLayer(
                  markers: zones
                      .map(
                        (zone) => Marker(
                          point: LatLng(zone.latitude, zone.longitude),
                          width: 100,
                          height: 32,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                zone.name,
                                style: const TextStyle(
                                  color: Color(0xFF00ACB2),
                                  fontSize: 11,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _MapButton(
                icon: Icons.my_location_rounded,
                onTap: () => mapController.move(center, 15.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.onTap,
  });

  final SafeZoneMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x1900ACB2)),
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: member.badgeTextColor.withValues(alpha: 0.18),
                  backgroundImage: member.avatarUrl.isEmpty ? null : NetworkImage(member.avatarUrl),
                  child: member.avatarUrl.isEmpty
                      ? Text(
                          member.name.isEmpty ? 'T' : member.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0C1D1A),
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                if (member.isOnline)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: _OnlineDot(size: 13),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      color: Color(0xFF0C1D1A),
                      fontSize: 15,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${member.zoneCount} vung an toan',
                    style: const TextStyle(
                      color: Color(0xFF00ACB2),
                      fontSize: 12,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    member.ageGroup,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0x1900ACB2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF00ACB2),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x1900ACB2), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0x1400ACB2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF00ACB2), size: 22),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0C1D1A),
                  fontSize: 12,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF00ACB2), size: 20),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF00ACB2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 14,
          fontFamily: 'Lexend',
        ),
      ),
    );
  }
}
