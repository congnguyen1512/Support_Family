import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_home_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeniorHomeOverviewDesign extends StatelessWidget {
  const SeniorHomeOverviewDesign({
    super.key,
    required this.profile,
    required this.onMapTap,
    required this.onNotificationTap,
    required this.onSosTap,
  });

  final SeniorHomeProfile profile;
  final VoidCallback onMapTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSosTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeniorHomePalette.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: SeniorHomePalette.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFBDEEE7), Color(0xFF8BDDD5)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x3306A8AE), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  'H',
                  style: GoogleFonts.lexend(
                    color: SeniorHomePalette.primaryDark,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.nickname,
                      style: GoogleFonts.lexend(
                        color: SeniorHomePalette.primaryDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.name,
                      style: GoogleFonts.beVietnamPro(
                        color: SeniorHomePalette.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.status,
                      style: GoogleFonts.beVietnamPro(
                        color: SeniorHomePalette.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.lastUpdated,
                      style: GoogleFonts.beVietnamPro(
                        color: SeniorHomePalette.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleAction(
                icon: Icons.notifications_rounded,
                onTap: onNotificationTap,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF08B6BB), Color(0xFF008E93)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.address,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetric(
                        label: 'Pin thi\u1EBFt b\u1ECB',
                        value: profile.battery,
                        icon: Icons.battery_full_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroMetric(
                        label: 'Nh\u1ECBp tim',
                        value: profile.heartRate,
                        icon: Icons.favorite_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroMetric(
                        label: 'V\u1EADn \u0111\u1ED9ng',
                        value: profile.steps,
                        icon: Icons.directions_walk_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onMapTap,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: SeniorHomePalette.primarySoft,
                    foregroundColor: SeniorHomePalette.primaryDark,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.map_rounded),
                  label: Text(
                    'Xem b\u1EA3n \u0111\u1ED3',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSosTap,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFFFECEC),
                    foregroundColor: SeniorHomePalette.danger,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.sos_rounded),
                  label: Text(
                    'SOS kh\u1EA9n',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
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
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: SeniorHomePalette.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: SeniorHomePalette.primary),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
