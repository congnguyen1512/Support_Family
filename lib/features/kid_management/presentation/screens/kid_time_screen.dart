import 'dart:ui' as ui;

import 'package:family_guard/features/kid_management/presentation/screens/kid_automation_screen.dart';
import 'package:family_guard/features/kid_management/presentation/shared/kid_management_data.dart';
import 'package:family_guard/features/kid_management/presentation/shared/kid_management_ui.dart';
import 'package:flutter/material.dart';

class KidTimeScreen extends StatefulWidget {
  const KidTimeScreen({super.key});

  @override
  State<KidTimeScreen> createState() => _KidTimeScreenState();
}

class _KidTimeScreenState extends State<KidTimeScreen> {
  bool _focusModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return KidDetailScaffold(
      title: 'Thời gian',
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thời gian sử dụng',
            style: kidTextStyle(
              size: 30,
              weight: FontWeight.w800,
              color: const Color(0xFF171D1D),
              height: 36 / 30,
              letterSpacing: -0.75,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Theo dõi thời gian sử dụng điện thoại hằng ngày, và quản lí các ứng dụng được phép,...',
            style: kidTextStyle(
              size: 14,
              weight: FontWeight.w400,
              color: const Color(0xFF3C4949),
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 22),
          KidSurfaceCard(
            padding: const EdgeInsets.all(32),
            radius: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian sử dụng hôm nay',
                  style: kidTextStyle(
                    size: 14,
                    weight: FontWeight.w500,
                    color: const Color(0xFF3C4949),
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '3h 15m',
                      style: kidTextStyle(
                        size: 48,
                        weight: FontWeight.w800,
                        color: const Color(0xFF171D1D),
                        height: 48 / 48,
                        letterSpacing: -2.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_down_rounded,
                            size: 14,
                            color: Color(0xFF00696C),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '12%',
                            style: kidTextStyle(
                              size: 14,
                              weight: FontWeight.w600,
                              color: const Color(0xFF00696C),
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const KidProgressLine(
                  progress: 0.65,
                  backgroundColor: Color(0xFFEFF5F4),
                  foregroundColor: Color(0xFF01ADB2),
                  height: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          KidSurfaceCard(
            padding: const EdgeInsets.all(24),
            radius: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hằng Tuần',
                  style: kidTextStyle(
                    size: 18,
                    weight: FontWeight.w600,
                    color: const Color(0xFF171D1D),
                    height: 28 / 18,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 128, child: _WeeklyUsageChart()),
              ],
            ),
          ),
          const SizedBox(height: 22),
          KidSurfaceCard(
            padding: const EdgeInsets.all(24),
            radius: 48,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Ứng dụng',
                      style: kidTextStyle(
                        size: 18,
                        weight: FontWeight.w600,
                        color: const Color(0xFF171D1D),
                        height: 28 / 18,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF334155),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const KidUsageCategoryRow(
                  icon: Icons.sports_esports_outlined,
                  iconBackground: Color(0x1A01ADB2),
                  iconColor: Color(0xFF01ADB2),
                  label: 'Trò chơi',
                  value: '1h 50m',
                  progress: 0.80,
                  progressColor: Color(0xFF01ADB2),
                ),
                const SizedBox(height: 24),
                const KidUsageCategoryRow(
                  icon: Icons.share_outlined,
                  iconBackground: Color(0xFFBDEBEC),
                  iconColor: Color(0xFF406B6D),
                  label: 'Mạng xã hội',
                  value: '1h 12m',
                  progress: 0.50,
                  progressColor: Color(0xFFBDEBEC),
                ),
                const SizedBox(height: 24),
                const KidUsageCategoryRow(
                  icon: Icons.menu_book_outlined,
                  iconBackground: Color(0x33E2844C),
                  iconColor: Color(0xFFE2844C),
                  label: 'Giáo dục',
                  value: '40m',
                  progress: 0.30,
                  progressColor: Color(0xFFE2844C),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          KidSurfaceCard(
            padding: const EdgeInsets.all(24),
            radius: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giới hạn',
                  style: kidTextStyle(
                    size: 18,
                    weight: FontWeight.w600,
                    color: const Color(0xFF171D1D),
                    height: 28 / 18,
                  ),
                ),
                const SizedBox(height: 16),
                const KidLimitPill(label: 'Trò chơi', value: '2h mỗi ngày'),
                const SizedBox(height: 12),
                const KidLimitPill(label: 'Mạng xã hội', value: '2h mỗi ngày'),
                const SizedBox(height: 16),
                KidFilledPillButton(
                  label: 'Chỉnh sửa giới hạn',
                  backgroundColor: const Color(0xFF01ADB2),
                  foregroundColor: Colors.white,
                  onTap: () =>
                      pushKidScreen(context, const KidAutomationScreen()),
                  trailingIcon: Icons.edit_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          KidSurfaceCard(
            padding: const EdgeInsets.all(24),
            radius: 48,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chế độ tập trung',
                        style: kidTextStyle(
                          size: 18,
                          weight: FontWeight.w600,
                          color: const Color(0xFF171D1D),
                          height: 28 / 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tắt thông báo không cần thiết và chặn các ứng dụng giải trí trong giờ học.',
                        style: kidTextStyle(
                          size: 12,
                          weight: FontWeight.w400,
                          color: const Color(0xFF3C4949),
                          height: 19.5 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                KidHubSwitch(
                  value: _focusModeEnabled,
                  onChanged: (value) {
                    setState(() => _focusModeEnabled = value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyUsageChart extends StatelessWidget {
  const _WeeklyUsageChart();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _WeeklyUsageChartPainter(),
        );
      },
    );
  }
}

class _WeeklyUsageChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final barHeights = [36.0, 32.0, 64.0, 18.0, 96.0, 10.0, 6.0];
    final lineValues = [32.0, 28.0, 36.0, 40.0, 92.0, 84.0, 60.0];
    final baseY = size.height - 26;
    final segmentWidth = size.width / labels.length;

    final trackPaint = Paint()..color = const Color(0xFFEFF5F4);
    final barPaint = Paint()..color = const Color(0xFF01ADB2);
    final lightBarPaint = Paint()..color = const Color(0x3301ADB2);
    final linePaint = Paint()
      ..color = const Color(0x9917D4DC)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final linePath = ui.Path();
    for (var i = 0; i < labels.length; i++) {
      final centerX = segmentWidth * i + segmentWidth / 2;
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 4, baseY - 96, 8, 96),
        const Radius.circular(999),
      );
      canvas.drawRRect(trackRect, trackPaint);

      final paint = i == 4 || i == 2 ? barPaint : lightBarPaint;
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 4, baseY - barHeights[i], 8, barHeights[i]),
        const Radius.circular(999),
      );
      canvas.drawRRect(barRect, paint);

      final point = Offset(centerX, baseY - lineValues[i]);
      if (i == 0) {
        linePath.moveTo(point.dx, point.dy);
      } else {
        final prevX = segmentWidth * (i - 1) + segmentWidth / 2;
        final prevY = baseY - lineValues[i - 1];
        final controlX = (prevX + point.dx) / 2;
        linePath.cubicTo(
          controlX,
          prevY,
          controlX,
          point.dy,
          point.dx,
          point.dy,
        );
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: kidTextStyle(
            size: 10,
            weight: FontWeight.w700,
            color: i == 4 ? const Color(0xFF01ADB2) : const Color(0xFF3C4949),
            height: 15 / 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, size.height - 15),
      );
    }

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
