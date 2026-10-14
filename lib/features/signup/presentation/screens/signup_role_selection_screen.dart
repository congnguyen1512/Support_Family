import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/fall_detection/data/fall_detection_service.dart';
import 'package:family_guard/core/network/api_exception.dart';
import 'package:family_guard/core/push_notification/push_notification_service.dart';
import 'package:family_guard/features/signup/data/models/register_request_model.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_form_data.dart';

class SignupRoleSelectionScreen extends StatefulWidget {
  const SignupRoleSelectionScreen({super.key, required this.initialData});

  final SignupFormData initialData;

  @override
  State<SignupRoleSelectionScreen> createState() => _SignupRoleSelectionScreenState();
}

class _SignupRoleSelectionScreenState extends State<SignupRoleSelectionScreen> {
  // 'nguoichamsoc' (Guardian) or 'nguoiduocchamsoc' (User)
  String _selectedRole = 'nguoichamsoc';
  bool _isLoading = false;

  static const _tealColor = Color(0xFF07A9B0);
  static const _titleColor = Color(0xFF0F172A);

  Future<void> _handleFinish() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final birthday = widget.initialData.age.trim();
      final phone = widget.initialData.phone.trim();
      final email = widget.initialData.email.trim();

      final request = RegisterRequestModel(
        fullName: widget.initialData.fullName.trim(),
        phone: phone.isNotEmpty ? phone : null,
        email: email.isNotEmpty ? email : null,
        password: widget.initialData.password,
        birthday: birthday.isNotEmpty ? birthday : null,
        gender: widget.initialData.gender.trim().isNotEmpty ? widget.initialData.gender.trim() : null,
        address: widget.initialData.address.trim().isNotEmpty ? widget.initialData.address.trim() : null,
        role: _selectedRole,
      );

      final session = await AppDependencies.instance.registerUseCase(request);

      if (!mounted) return;

      await AppDependencies.instance.safeZoneService.initialize(force: true);
      await AppDependencies.instance.locationTrackingService.start();
      await PushNotificationService.instance.syncCurrentTokenToServer();

      if (session.homeType == 'elderly') {
        FallDetectionService.instance.startMonitoring();
      } else {
        await FallDetectionService.instance.stopMonitoring();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký tài khoản thành công!')),
      );

      Navigator.pushNamedAndRemoveUntil(context, session.homeRoute, (_) => false);
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'Đăng ký thất bại: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: _tealColor,
                        size: 32,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chào mừng đến với',
                        style: GoogleFonts.publicSans(
                          color: _titleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'FamilyGuard!',
                        style: GoogleFonts.publicSans(
                          color: _titleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Main Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Bạn sẽ sử dụng ứng\ndụng với vai trò nào?',
                textAlign: TextAlign.center,
                style: GoogleFonts.publicSans(
                  color: _titleColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _RoleCard(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'Người hỗ trợ (Guardian)',
                      subtitle: 'Chăm sóc và theo dõi sức khỏe, vị trí của người thân một cách an toàn.',
                      isSelected: _selectedRole == 'nguoichamsoc',
                      onTap: () => setState(() => _selectedRole = 'nguoichamsoc'),
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      icon: Icons.shield_outlined,
                      title: 'Người được chăm sóc (User)',
                      subtitle: 'Chia sẻ vị trí, tâm trạng và nhận các lịch nhắc nhở uống thuốc định kỳ.',
                      isSelected: _selectedRole == 'nguoiduocchamsoc',
                      onTap: () => setState(() => _selectedRole = 'nguoiduocchamsoc'),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: _tealColor,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: _handleFinish,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tiếp tục',
                              style: GoogleFonts.publicSans(
                                color: _tealColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: _tealColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  static const _tealColor = Color(0xFF07A9B0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? _tealColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _tealColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: _tealColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title,
              style: GoogleFonts.publicSans(
                color: const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: GoogleFonts.publicSans(
                color: const Color(0xFF64748B),
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),

            // Indicator line
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: isSelected ? _tealColor : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
