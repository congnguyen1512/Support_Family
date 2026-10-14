import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_home_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeniorHomeScheduleDesign extends StatelessWidget {
  const SeniorHomeScheduleDesign({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.onSupportTap,
  });

  final List<SeniorScheduleItem> items;
  final ValueChanged<SeniorScheduleItem> onItemTap;
  final VoidCallback onSupportTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'L\u1ECBch h\u00F4m nay',
          style: GoogleFonts.lexend(
            color: SeniorHomePalette.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onItemTap(item),
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SeniorHomePalette.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: SeniorHomePalette.cardShadow,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: item.accent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.lexend(
                              color: SeniorHomePalette.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: GoogleFonts.beVietnamPro(
                              color: SeniorHomePalette.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: SeniorHomePalette.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.timeLabel,
                        style: GoogleFonts.lexend(
                          color: SeniorHomePalette.primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0FADB3),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'C\u1EA7n h\u1ED7 tr\u1EE3 th\u00EAm?',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'M\u1EDF tr\u00F2 chuy\u1EC7n ho\u1EB7c g\u1ECDi ngay cho ng\u01B0\u1EDDi th\u00E2n n\u1EBFu b\u00E0 c\u1EA7n tr\u1EE3 gi\u00FAp.',
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onSupportTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: SeniorHomePalette.primaryDark,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'M\u1EDF h\u1ED7 tr\u1EE3 gia \u0111\u00ECnh',
                  style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
