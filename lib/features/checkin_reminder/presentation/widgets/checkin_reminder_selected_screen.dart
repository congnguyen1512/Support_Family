import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckinReminderSelectedScreen extends StatelessWidget {
  const CheckinReminderSelectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Stack(
          children: [
            const _TopDecoration(),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: Column(
                  children: [
                    const _Header(),
                    const SizedBox(height: 16),
                    const _SelectedMembersRow(),
                    const SizedBox(height: 12),
                    const _SetupCard(),
                  ],
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
            left: -131.08,
            top: -98,
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
            left: -156,
            top: -80.52,
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
    return AppBackHeaderBar(
      title: 'Lời nhắc hỏi thăm',
      onBack: () => Navigator.maybePop(context),
      titleFontSize: 20,
    );
  }
}
class _SelectedMembersRow extends StatelessWidget {
  const _SelectedMembersRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn thành viên',
              style: GoogleFonts.inter(
                color: const Color(0xFF5D7A7D),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _AvatarTag(
                    label: 'Mẹ',
                    imageUrl:
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&q=80',
                    active: true,
                  ),
                  SizedBox(width: 16),
                  _AvatarTag(
                    label: 'Bố',
                    imageUrl:
                        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=120&q=80',
                    active: false,
                  ),
                  SizedBox(width: 16),
                  _AvatarTag(
                    label: 'Bé Chip',
                    imageUrl: '',
                    active: false,
                    isIcon: true,
                  ),
                  SizedBox(width: 16),
                  _AvatarTag(
                    label: 'Thêm',
                    imageUrl: '',
                    active: false,
                    isAdd: true,
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

class _AvatarTag extends StatelessWidget {
  const _AvatarTag({
    required this.label,
    required this.imageUrl,
    required this.active,
    this.isAdd = false,
    this.isIcon = false,
  });

  final String label;
  final String imageUrl;
  final bool active;
  final bool isAdd;
  final bool isIcon;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.6,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: EdgeInsets.all(isAdd ? 2 : 4),
            decoration: BoxDecoration(
              color: isAdd ? Colors.white.withValues(alpha: 0.5) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isAdd ? const Color(0xFFCBD5E1) : Colors.transparent,
                width: 2,
                style: isAdd ? BorderStyle.solid : BorderStyle.none,
              ),
            ),
            child: isAdd
                ? const Center(
                    child: Icon(Icons.add, size: 18, color: Color(0xFF94A3B8)),
                  )
                : isIcon
                    ? Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sentiment_satisfied_alt,
                            size: 18,
                            color: Color(0xFFA855F7),
                          ),
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person),
                        ),
                      ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF5D7A7D),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.fromLTRB(13, 22, 13, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: const [
          _TimeSection(),
          SizedBox(height: 18),
          _RepeatSection(),
          SizedBox(height: 18),
          _QuestionSection(),
          SizedBox(height: 20),
          _SaveButton(),
        ],
      ),
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'THỜI GIAN GỬI',
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF5D7A7D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.7,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF3F4F6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '07',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A3C40),
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        ':',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00ACB1),
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.2,
                          height: 1,
                        ),
                      ),
                    ),
                    Text(
                      '00',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A3C40),
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 22,
                  top: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x1A00ACB1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'AM',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF00ACB1),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 16 / 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'PM',
                          style: GoogleFonts.beVietnamPro(
                            color: const Color(0xFF5D7A7D),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -10,
                  top: -12,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit, size: 14, color: Color(0xFF00ACB1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatSection extends StatelessWidget {
  const _RepeatSection();

  @override
  Widget build(BuildContext context) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lặp lại',
            style: GoogleFonts.inter(
              color: const Color(0xFF5D7A7D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: days
                .map(
                  (day) => Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE6F4F2)),
                    ),
                    child: Text(
                      day,
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF00ACB1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuestionSection extends StatelessWidget {
  const _QuestionSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Câu hỏi thăm',
            style: GoogleFonts.inter(
              color: const Color(0xFF5D7A7D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 46),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9F9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                Text(
                  'Hôm nay bạn cảm thấy thế\nnào?',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF5D7A7D),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 28 / 18,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: -30,
                  child: Row(
                    children: const [
                      Icon(Icons.mic_none_rounded, size: 24, color: Color(0xFF5D7A7D)),
                      SizedBox(width: 8),
                      Icon(Icons.timer_outlined, size: 18, color: Color(0xFF5D7A7D)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFF0F9F9),
          foregroundColor: const Color(0xFF00ACB1),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: const Color(0x4D00ACB1),
        ),
        icon: const Icon(Icons.save_outlined, size: 18),
        label: Text(
          'Lưu thiết lập',
          style: GoogleFonts.beVietnamPro(
            color: const Color(0xFF00ACB1),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 28 / 18,
          ),
        ),
      ),
    );
  }
}


