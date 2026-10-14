import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_home_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeniorHomeStatusDesign extends StatelessWidget {
  const SeniorHomeStatusDesign({
    super.key,
    required this.stats,
  });

  final List<SeniorHomeStat> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'T\u00ECnh tr\u1EA1ng h\u00F4m nay',
          style: GoogleFonts.lexend(
            color: SeniorHomePalette.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SeniorHomePalette.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: SeniorHomePalette.cardShadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: stat.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(stat.icon, color: stat.iconColor),
                  ),
                  const Spacer(),
                  Text(
                    stat.value,
                    style: GoogleFonts.lexend(
                      color: SeniorHomePalette.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stat.title,
                    style: GoogleFonts.beVietnamPro(
                      color: SeniorHomePalette.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
