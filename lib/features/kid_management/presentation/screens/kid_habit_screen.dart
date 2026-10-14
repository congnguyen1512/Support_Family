import 'package:family_guard/features/kid_management/presentation/shared/kid_management_data.dart';
import 'package:family_guard/features/kid_management/presentation/shared/kid_management_ui.dart';
import 'package:flutter/material.dart';

class KidHabitScreen extends StatefulWidget {
  const KidHabitScreen({super.key});

  @override
  State<KidHabitScreen> createState() => _KidHabitScreenState();
}

class _KidHabitScreenState extends State<KidHabitScreen> {
  int _selectedEmotion = 1;

  static const _emotionOptions = [
    ('Hạnh phúc', Icons.sentiment_very_satisfied_rounded),
    ('Vui', Icons.sentiment_satisfied_rounded),
    ('Buồn', Icons.sentiment_dissatisfied_rounded),
    ('Tức Giận', Icons.sentiment_very_dissatisfied_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return KidDetailScaffold(
      title: 'Thói quen',
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thói quen hằng ngày',
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
            'Theo dõi thói quen sinh hoạt hàng ngày và sức khỏe tinh thần.',
            style: kidTextStyle(
              size: 14,
              weight: FontWeight.w400,
              color: const Color(0xFF3C4949),
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 34),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5F4),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cảm xúc',
                  style: kidTextStyle(
                    size: 18,
                    weight: FontWeight.w700,
                    color: const Color(0xFF171D1D),
                    height: 28 / 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '84%',
                      style: kidTextStyle(
                        size: 36,
                        weight: FontWeight.w800,
                        color: const Color(0xFF171D1D),
                        height: 40 / 36,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Tích cực',
                        style: kidTextStyle(
                          size: 14,
                          weight: FontWeight.w500,
                          color: const Color(0xFF3A6567),
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _EmotionBars(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          KidSurfaceCard(
            padding: const EdgeInsets.all(25),
            radius: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theo dõi cảm xúc',
                  style: kidTextStyle(
                    size: 18,
                    weight: FontWeight.w700,
                    color: const Color(0xFF171D1D),
                    height: 28 / 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_emotionOptions.length, (index) {
                    final option = _emotionOptions[index];
                    final selected = index == _selectedEmotion;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedEmotion = index),
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF01ADB2)
                                    : const Color(0xFFE9EFEF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option.$2,
                                size: 20,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              option.$1,
                              textAlign: TextAlign.center,
                              style: kidTextStyle(
                                size: 10,
                                weight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? const Color(0xFF00696C)
                                    : const Color(0xFF3C4949),
                                height: 15 / 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _WeekLabel('MON'),
                    _WeekLabel('TUE'),
                    _WeekLabel('WED'),
                    _WeekLabel('THU'),
                    _WeekLabel('FRI'),
                  ],
                ),
                const SizedBox(height: 8),
                const KidProgressLine(
                  progress: 0.70,
                  backgroundColor: Color(0xFFE9EFEF),
                  foregroundColor: Color(0xFFE2844C),
                  height: 4,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Xu hướng ổn định kể từ thứ Hai',
                    style: kidTextStyle(
                      size: 10,
                      weight: FontWeight.w400,
                      color: const Color(0xFF3C4949),
                      height: 15 / 10,
                    ),
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

class _EmotionBars extends StatelessWidget {
  const _EmotionBars();

  @override
  Widget build(BuildContext context) {
    const heights = [40.0, 58.0, 54.0, 86.0, 67.0, 43.0, 82.0];
    const colors = [
      Color(0x3301ADB2),
      Color(0x3301ADB2),
      Color(0x6601ADB2),
      Color(0xFF01ADB2),
      Color(0x9901ADB2),
      Color(0x4D01ADB2),
      Color(0xCC01ADB2),
    ];

    return SizedBox(
      height: 112,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(heights.length, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                height: heights[index],
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(999),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WeekLabel extends StatelessWidget {
  const _WeekLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: kidTextStyle(
        size: 10,
        weight: FontWeight.w700,
        color: const Color(0x993C4949),
        height: 15 / 10,
      ),
    );
  }
}
