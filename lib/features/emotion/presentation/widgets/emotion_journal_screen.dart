import 'package:flutter/material.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:google_fonts/google_fonts.dart';

class EmotionJournalScreen extends StatelessWidget {
  const EmotionJournalScreen({super.key});

  static const _bgColor = Color(0xFFF0F8F7);
  static const _primary = Color(0xFF00ACB1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _TopDecoration(),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
                child: Column(
                  children: [
                    const _Header(),
                    const SizedBox(height: 40),
                    const _MemberMoodCard(
                      name: 'Mẹ',
                      scheduleText: 'Hỏi lúc 07:00 hàng ngày',
                      moodText: 'Tâm trạng hôm nay: Vui vẻ',
                      topBadgeText: 'Đã cập nhật',
                      topBadgeBg: Color(0xFFDCFCE7),
                      topBadgeDot: Color(0xFF22C55E),
                      topBadgeTextColor: Color(0xFF16A34A),
                      avatarBg: Color(0xFFFCE7F3),
                      avatarIcon: Icons.face_3_rounded,
                      avatarIconColor: Color(0xFFEC4899),
                      moodIcon: Icons.sentiment_satisfied_alt_rounded,
                      moodIconColor: Color(0xFFEAB308),
                      moodTextColor: Color(0xFF1A3C40),
                    ),
                    const SizedBox(height: 16),
                    const _MemberMoodCard(
                      name: 'Bố',
                      scheduleText: 'Hỏi lúc 20:00 hàng ngày',
                      moodText: 'Chưa có dữ liệu hôm nay',
                      topBadgeText: 'Chờ cập nhật',
                      topBadgeBg: Color(0xFFF3F4F6),
                      topBadgeDot: Color(0xFF9CA3AF),
                      topBadgeTextColor: Color(0xFF6B7280),
                      avatarBg: Color(0xFFDBEAFE),
                      avatarIcon: Icons.face_retouching_natural,
                      avatarIconColor: Color(0xFF60A5FA),
                      moodIcon: Icons.sentiment_neutral_rounded,
                      moodIconColor: Color(0xFF9CA3AF),
                      moodTextColor: Color(0xFF5D7A7D),
                    ),
                    const SizedBox(height: 16),
                    const _MemberMoodCard(
                      name: 'Bé Chip',
                      scheduleText: 'Theo dõi tự động',
                      moodText: 'Tâm trạng: Căng thẳng',
                      topBadgeText: 'Cần chú ý',
                      topBadgeBg: Color(0xFFFEF9C3),
                      topBadgeDot: Color(0xFFEAB308),
                      topBadgeTextColor: Color(0xFFCA8A04),
                      avatarBg: Color(0xFFF3E8FF),
                      avatarIcon: Icons.emoji_emotions,
                      avatarIconColor: Color(0xFFA855F7),
                      moodIcon: Icons.sentiment_very_dissatisfied_rounded,
                      moodIconColor: Color(0xFFF97316),
                      moodTextColor: Color(0xFF1A3C40),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: _primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                        label: Text(
                          'Xem thêm',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 28 / 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 22,
              bottom: 65,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF00ADB2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x6600ADB2),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white, size: 34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopDecoration extends StatelessWidget {
  const _TopDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -136,
            top: -71,
            child: Container(
              width: 235.08,
              height: 211.52,
              decoration: BoxDecoration(
                color: const Color(0x6604D1D4),
                borderRadius: BorderRadius.circular(62),
              ),
            ),
          ),
          Positioned(
            left: -161,
            top: -53.52,
            child: Container(
              width: 235.08,
              height: 211.52,
              decoration: BoxDecoration(
                color: const Color(0xFF00ACB1),
                borderRadius: BorderRadius.circular(62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const AppBackHeaderBar(
      title: 'Nhật ký cảm xúc',
      backgroundColor: Colors.transparent,
    );
  }
}


class _MemberMoodCard extends StatelessWidget {
  const _MemberMoodCard({
    required this.name,
    required this.scheduleText,
    required this.moodText,
    required this.topBadgeText,
    required this.topBadgeBg,
    required this.topBadgeDot,
    required this.topBadgeTextColor,
    required this.avatarBg,
    required this.avatarIcon,
    required this.avatarIconColor,
    required this.moodIcon,
    required this.moodIconColor,
    required this.moodTextColor,
  });

  final String name;
  final String scheduleText;
  final String moodText;
  final String topBadgeText;
  final Color topBadgeBg;
  final Color topBadgeDot;
  final Color topBadgeTextColor;

  final Color avatarBg;
  final IconData avatarIcon;
  final Color avatarIconColor;

  final IconData moodIcon;
  final Color moodIconColor;
  final Color moodTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80F3F4F6),
            blurRadius: 15,
            offset: Offset(0, 4),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x33F3F4F6), width: 2),
                ),
                child: Container(
                  decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                  child: Icon(avatarIcon, color: avatarIconColor, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF1A3C40),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 28 / 20,
                              ),
                            ),
                          ),
                          _TopBadge(
                            text: topBadgeText,
                            bg: topBadgeBg,
                            dot: topBadgeDot,
                            textColor: topBadgeTextColor,
                          ),
                        ],
                      ),
                      Text(
                        scheduleText,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF5D7A7D),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(moodIcon, color: moodIconColor, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              moodText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: moodTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 16 / 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ACB1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                    shadowColor: const Color(0x4D00ACB1),
                  ),
                  icon: const Icon(Icons.bar_chart_rounded, size: 16),
                  label: Text(
                    'Xem báo cáo',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0x4D87E4DB),
                    foregroundColor: const Color(0xFF00ACB1),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.settings, size: 18),
                  label: Text(
                    'Thiết lập',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                    ),
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

class _TopBadge extends StatelessWidget {
  const _TopBadge({
    required this.text,
    required this.bg,
    required this.dot,
    required this.textColor,
  });

  final String text;
  final Color bg;
  final Color dot;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 15 / 10,
            ),
          ),
        ],
      ),
    );
  }
}
