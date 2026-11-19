import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_home_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeniorHomeScheduleDesign extends StatelessWidget {
  const SeniorHomeScheduleDesign({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.onSupportTap,
    this.isLoading = false,
  });

  final List<SeniorScheduleItem> items;
  final ValueChanged<SeniorScheduleItem> onItemTap;
  final VoidCallback onSupportTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch hôm nay',
              style: GoogleFonts.lexend(
                color: SeniorHomePalette.primaryDark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SeniorHomePalette.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} nhắc nhở',
                  style: GoogleFonts.beVietnamPro(
                    color: SeniorHomePalette.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
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
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00B3B8),
              ),
            ),
          )
        else if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
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
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: SeniorHomePalette.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: SeniorHomePalette.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chưa có lịch nhắc hôm nay',
                  style: GoogleFonts.lexend(
                    color: SeniorHomePalette.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mọi sinh hoạt, uống thuốc và lịch hẹn đều đã ổn định hoặc chưa có lịch mới từ người thân.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    color: SeniorHomePalette.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          )
        else
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
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
                      'Cần hỗ trợ thêm?',
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
                'Mở trò chuyện hoặc gọi ngay cho người thân nếu bà cần trợ giúp.',
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
                  'Mở hỗ trợ gia đình',
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
