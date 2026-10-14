import 'package:flutter/material.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:google_fonts/google_fonts.dart';

class EmotionPulseScreen extends StatefulWidget {
  const EmotionPulseScreen({super.key});

  @override
  State<EmotionPulseScreen> createState() => _EmotionPulseScreenState();
}

class _EmotionPulseScreenState extends State<EmotionPulseScreen> {
  bool weekly = true;

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
                padding: const EdgeInsets.fromLTRB(25, 8, 25, 24),
                child: Column(
                  children: [
                    _Header(onBack: () => Navigator.maybePop(context)),
                    const SizedBox(height: 10),
                    _Segment(
                      weekly: weekly,
                      onChanged: (value) => setState(() => weekly = value),
                    ),
                    const SizedBox(height: 24),
                    const _MemberInfo(),
                    const SizedBox(height: 24),
                    const _ChartCard(),
                    const SizedBox(height: 16),
                    const _TrendCard(),
                    const SizedBox(height: 16),
                    const _StatsRow(),
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
            left: -136.08,
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
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppBackHeaderBar(
      title: 'Nhịp cảm xúc',
      onBack: onBack,
      backgroundColor: Colors.transparent,
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.weekly, required this.onChanged});

  final bool weekly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: weekly ? const Color(0xFF00ACB1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: weekly
                      ? const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Theo tuần',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: weekly ? Colors.white : const Color(0xFF5D7A7D),
                    fontSize: 14,
                    fontWeight: weekly ? FontWeight.w600 : FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !weekly ? const Color(0xFF00ACB1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: !weekly
                      ? const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Theo tháng',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: !weekly ? Colors.white : const Color(0xFF5D7A7D),
                    fontSize: 14,
                    fontWeight: !weekly ? FontWeight.w600 : FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberInfo extends StatelessWidget {
  const _MemberInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: ClipOval(
                child: Image.network(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x6687E4DB),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Mẹ',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A3C40),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 28 / 18,
          ),
        ),
        Text(
          'Cập nhật 2 giờ trước',
          style: GoogleFonts.inter(
            color: const Color(0xFF5D7A7D),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF9FAFB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biểu đồ cảm xúc',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1A3C40),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Chi tiết',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF00ACB1),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 16 / 12,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 14, color: Color(0xFF00ACB1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 192,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.sentiment_very_satisfied, color: Color(0xFF22C55E), size: 20),
                    Icon(Icons.sentiment_satisfied, color: Color(0xFFEAB308), size: 20),
                    Icon(Icons.sentiment_neutral, color: Color(0xFF94A3B8), size: 20),
                    Icon(Icons.sentiment_dissatisfied, color: Color(0xFFF97316), size: 20),
                    Icon(Icons.sentiment_very_dissatisfied, color: Color(0xFFEF4444), size: 20),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChartCanvas(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ChartPainter(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                    .map(
                      (d) => Text(
                        d,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF5D7A7D),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 15 / 10,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final y = 12 + (size.height - 32) * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final points = [
      Offset(size.width * 0.02, size.height * 0.70),
      Offset(size.width * 0.18, size.height * 0.40),
      Offset(size.width * 0.34, size.height * 0.58),
      Offset(size.width * 0.50, size.height * 0.33),
      Offset(size.width * 0.66, size.height * 0.48),
      Offset(size.width * 0.82, size.height * 0.42),
      Offset(size.width * 0.98, size.height * 0.30),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
    }

    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height - 20)
      ..lineTo(points.first.dx, size.height - 20)
      ..close();

    canvas.drawPath(
      fill,
      Paint()..color = const Color(0x3300ACB1),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0EA5A8)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final dotPaint = Paint()..color = const Color(0xFF0EA5A8);
    for (final p in [points[1], points[3], points[5]]) {
      canvas.drawCircle(p, 7, dotPaint);
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(21, 17, 21, 17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0x3387E4DB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFF0EA5A8), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF1A3C40),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 24 / 16,
                    ),
                    children: const [
                      TextSpan(text: 'Xu hướng tuần này: '),
                      TextSpan(text: 'Tích cực', style: TextStyle(color: Color(0xFF00ACB1))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tâm trạng của Mẹ ổn định ở mức cao. Các\nchỉ số cho thấy sự cải thiện rõ rệt vào cuối\ntuần, có thể liên quan đến thời gian nghỉ\nngơi.',
            style: GoogleFonts.inter(
              color: const Color(0xFF5D7A7D),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 22.75 / 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StatCard(
            icon: Icons.thumb_up_alt,
            iconBg: Color(0xFFDCFCE7),
            iconColor: Color(0xFF16A34A),
            value: '5',
            label: 'Số ngày vui vẻ',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.priority_high,
            iconBg: Color(0xFFFFEDD5),
            iconColor: Color(0xFFEA580C),
            value: '1',
            label: 'Ngày cần quan tâm',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF9FAFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF1A3C40),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 32 / 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

