import 'package:family_guard/features/kid_management/presentation/shared/kid_management_data.dart';
import 'package:family_guard/features/kid_management/presentation/shared/kid_management_ui.dart';
import 'package:flutter/material.dart';

class KidAutomationScreen extends StatefulWidget {
  const KidAutomationScreen({super.key});

  @override
  State<KidAutomationScreen> createState() => _KidAutomationScreenState();
}

class _KidAutomationScreenState extends State<KidAutomationScreen> {
  final List<bool> _ruleStates = [true, true, false];

  @override
  Widget build(BuildContext context) {
    return KidDetailScaffold(
      title: 'Tự động',
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF99DFEB),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: Color(0xFF9A4E22),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BÁO CÁO HẰNG TUẦN',
                      style: kidTextStyle(
                        size: 12,
                        weight: FontWeight.w700,
                        color: const Color(0x993C4949),
                        height: 16 / 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Thời gian sử dụng của Xôi đã giảm đi 14% trong tuần trước.',
                  style: kidTextStyle(
                    size: 30,
                    weight: FontWeight.w800,
                    color: const Color(0xFF171D1D),
                    height: 37.5 / 30,
                    letterSpacing: -0.75,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const KidSectionHeading('Quy tắc'),
          const SizedBox(height: 24),
          KidAutomationRuleTile(
            icon: Icons.nightlight_round,
            iconBackground: const Color(0x1A00696C),
            iconColor: const Color(0xFF00696C),
            title: 'Chặn truy cập mạng xã hội sau 22:00 PM',
            subtitle: 'Mỗi ngày',
            value: _ruleStates[0],
            onChanged: (value) => setState(() => _ruleStates[0] = value),
          ),
          const SizedBox(height: 16),
          KidAutomationRuleTile(
            icon: Icons.location_on_outlined,
            iconBackground: const Color(0x1AE2844C),
            iconColor: const Color(0xFF9A4E22),
            title: 'Gửi thông báo khi đến trường',
            subtitle: 'Vùng an toàn: Trường Học',
            value: _ruleStates[1],
            onChanged: (value) => setState(() => _ruleStates[1] = value),
          ),
          const SizedBox(height: 16),
          KidAutomationRuleTile(
            icon: Icons.sports_esports_outlined,
            iconBackground: const Color(0xFFE3E9E9),
            iconColor: const Color(0xFF64748B),
            title: 'Giới hạn chơi game 2h',
            subtitle: 'Hằng ngày',
            value: _ruleStates[2],
            enabledOpacity: 0.8,
            onChanged: (value) => setState(() => _ruleStates[2] = value),
          ),
          const SizedBox(height: 24),
          KidFilledPillButton(
            label: 'Tạo Quy Tắc Mới',
            backgroundColor: const Color(0xFF00696C),
            foregroundColor: Colors.white,
            trailingIcon: Icons.add_circle_outline_rounded,
            onTap: () => openCheckinReminder(context),
            fullWidth: true,
            verticalPadding: 20,
          ),
          const SizedBox(height: 25),
          const KidSectionHeading('Gợi ý'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: KidSuggestionCard(
                  icon: Icons.nightlight_round,
                  iconColor: const Color(0xFF01ADB2),
                  backgroundColor: const Color(0x0D01ADB2),
                  borderColor: const Color(0x1A01ADB2),
                  title: 'Chế độ tập trung khi ngủ',
                  onTap: () => openCheckinReminder(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KidSuggestionCard(
                  icon: Icons.block_rounded,
                  iconColor: const Color(0xFFE2844C),
                  backgroundColor: const Color(0x0DE2844C),
                  borderColor: const Color(0x1AE2844C),
                  title: 'Chặn nội dung 18+',
                  onTap: () => openCheckinReminder(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
