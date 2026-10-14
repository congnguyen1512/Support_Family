import 'package:family_guard/features/kid_management/presentation/screens/kid_automation_screen.dart';
import 'package:family_guard/features/kid_management/presentation/screens/kid_device_control_screen.dart';
import 'package:family_guard/features/kid_management/presentation/screens/kid_habit_screen.dart';
import 'package:family_guard/features/kid_management/presentation/screens/kid_safety_screen.dart';
import 'package:family_guard/features/kid_management/presentation/screens/kid_time_screen.dart';
import 'package:family_guard/features/kid_management/presentation/shared/kid_management_data.dart';
import 'package:family_guard/features/kid_management/presentation/shared/kid_management_ui.dart';
import 'package:flutter/material.dart';

class KidManagementScreen extends StatelessWidget {
  const KidManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Column(
                children: [
                  KidDashboardHeader(
                    onBack: () => Navigator.maybePop(context),
                    onChatTap: () => openChatList(context),
                  ),
                  const SizedBox(height: 10),
                  const KidProfileHeroSection(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        KidQuickActionButton(
                          backgroundColor: const Color(0xFF00696C),
                          icon: Icons.call_outlined,
                          shadowColor: const Color(0x3300696C),
                          onTap: () => openKidCall(context),
                        ),
                        const SizedBox(width: 24),
                        KidQuickActionButton(
                          backgroundColor: const Color(0xFFBDEBEC),
                          icon: Icons.chat_bubble_outline_rounded,
                          iconColor: const Color(0xFF406B6D),
                          shadowColor: const Color(0x223A6567),
                          onTap: () => openKidChat(context),
                        ),
                        const SizedBox(width: 24),
                        KidQuickActionButton(
                          backgroundColor: const Color(0xFFBA1A1A),
                          icon: Icons.notifications_active_outlined,
                          shadowColor: const Color(0x4DBA1A1A),
                          onTap: () => openNotifications(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.96,
                      children: [
                        KidHubCard(
                          title: 'An toàn',
                          description: 'Vị trí, vùng an toàn, cảnh báo',
                          icon: Icons.location_on_outlined,
                          iconBackground: const Color(0x33BDEBEC),
                          iconColor: const Color(0xFF00696C),
                          onTap: () =>
                              pushKidScreen(context, const KidSafetyScreen()),
                        ),
                        KidHubCard(
                          title: 'Thời gian',
                          description: 'Thời gian sử dụng, giới hạn,...',
                          icon: Icons.timelapse_rounded,
                          iconBackground: const Color(0x33BDEBEC),
                          iconColor: const Color(0xFF406B6D),
                          onTap: () =>
                              pushKidScreen(context, const KidTimeScreen()),
                        ),
                        KidHubCard(
                          title: 'Thói quen',
                          description: 'Hoạt động, cảm xúc,...',
                          icon: Icons.psychology_alt_outlined,
                          iconBackground: const Color(0x33E2844C),
                          iconColor: const Color(0xFF9A4E22),
                          onTap: () =>
                              pushKidScreen(context, const KidHabitScreen()),
                        ),
                        KidHubCard(
                          title: 'Trò chuyện',
                          description: 'Gọi, nhắn tin,...',
                          icon: Icons.chat_bubble_outline_rounded,
                          iconBackground: const Color(0x33BDEBEC),
                          iconColor: const Color(0xFF01ADB2),
                          onTap: () => openChatList(context),
                        ),
                        KidHubCard(
                          title: 'Điều khiển',
                          description: 'Khóa thiết bị, điều khiển,...',
                          icon: Icons.devices_other_outlined,
                          iconBackground: const Color(0x33E2E8F0),
                          iconColor: const Color(0xFF475569),
                          onTap: () => pushKidScreen(
                            context,
                            const KidDeviceControlScreen(),
                          ),
                        ),
                        KidHubCard(
                          title: 'Tự động hóa',
                          description: 'Đặt các giới hạn một cách tự động',
                          icon: Icons.smart_toy_outlined,
                          iconBackground: const Color(0x33D8B4FE),
                          iconColor: const Color(0xFF9333EA),
                          onTap: () => pushKidScreen(
                            context,
                            const KidAutomationScreen(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
