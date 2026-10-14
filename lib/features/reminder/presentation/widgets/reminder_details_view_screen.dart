import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/widgets/app_dialog.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';


/// ============================================================
/// MÀN HÌNH: Chi tiết nhắc nhở
/// View chi tiết reminder với audio đang phát
/// Chuyển đổi từ Figma Dev Mode → Flutter Clean Code
/// ============================================================
class ReminderDetailsViewScreen extends StatefulWidget {
  const ReminderDetailsViewScreen({super.key});

  @override
  State<ReminderDetailsViewScreen> createState() =>
      _ReminderDetailsViewScreenState();
}

class _ReminderDetailsViewScreenState extends State<ReminderDetailsViewScreen> {
  bool _isActive = true;
  bool _isPlaying = true;
  final double _currentProgress = 0.33; // 5 seconds out of 15

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 128,
              ),
              child: Column(
                children: [
                  _buildReminderCard(),
                  const SizedBox(height: 16),
                  _buildVoiceRecordingSection(),
                  const SizedBox(height: 16),
                  _buildRecipientSection(),
                  const SizedBox(height: 16),
                  _buildActivationSection(),
                ],
              ),
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const AppBackHeaderBar(
      title: 'Chi tiết nhắc nhở',
    );
  }

  /// Main reminder card với icon và thông tin
  Widget _buildReminderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0x0C00ACB2),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: ShapeDecoration(
              color: const Color(0x33FF8FA3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Icon(
              Icons.medication,
              color: const Color(0xFFFF8FA3),
              size: 40,
            ),
          ),

          // Title and time
          Column(
            children: [
              Text(
                'Uống thuốc huyết áp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF0C1D1A),
                  fontSize: ResponsiveHelper.sp(context, 24),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: const Color(0xFF00ACB2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '08:00 - Hàng ngày',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF00ACB2),
                      fontSize: ResponsiveHelper.sp(context, 16),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Voice recording section với waveform đang phát
  Widget _buildVoiceRecordingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'GHI \u00C2M GI\u1ECCNG N\u00D3I',
            style: TextStyle(
              color: const Color(0xFF45A191),
              fontSize: ResponsiveHelper.sp(context, 14),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              height: 1.43,
              letterSpacing: 0.70,
            ),
          ),
        ),

        const SizedBox(height: 8),
        // Audio player
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0x0C00ACB2),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Play button
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF00ACB2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x4C00ACB2),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Color(0x4C00ACB2),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(width: 16),
              // Waveform and progress
              Expanded(
                child: Column(
                  children: [
                    // Waveform
                    _buildWaveform(),

                    // Time labels
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0:05',
                          style: TextStyle(
                            color: const Color(0xFF45A191),
                            fontSize: ResponsiveHelper.sp(context, 10),
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                        Text(
                          '0:15',
                          style: TextStyle(
                            color: const Color(0xFF45A191),
                            fontSize: ResponsiveHelper.sp(context, 10),
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Waveform visualization
  Widget _buildWaveform() {
    final heights = [12.0, 20.0, 32.0, 16.0, 24.0, 12.0, 20.0, 8.0, 28.0, 16.0, 24.0, 12.0, 20.0, 32.0, 16.0, 24.0];
    final progressIndex = (_currentProgress * heights.length).floor();

    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(heights.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const SizedBox(width: 4);
          }
          final barIndex = index ~/ 2;
          final isPlayed = barIndex < progressIndex;
          return Container(
            width: 4,
            height: heights[barIndex],
            decoration: ShapeDecoration(
              color: isPlayed
                  ? const Color(0xFF00ACB2)
                  : const Color(0x4C00ACB2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Recipient section
  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'THÀNH VIÊN NHẬN',
            style: TextStyle(
              color: const Color(0xFF45A191),
              fontSize: ResponsiveHelper.sp(context, 14),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              height: 1.43,
              letterSpacing: 0.70,
            ),
          ),
        ),

        const SizedBox(height: 8),
        // Recipient card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0x0C00ACB2),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 2,
                          color: const Color(0x3300ACB2),
                        ),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: Image.network(
                      "https://i.pravatar.cc/150?img=47",
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 12),
                  // Name and role
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bà Lan',
                        style: TextStyle(
                          color: const Color(0xFF0C1D1A),
                          fontSize: ResponsiveHelper.sp(context, 16),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                      Text(
                        'Người nhận chính',
                        style: TextStyle(
                          color: const Color(0xFF45A191),
                          fontSize: ResponsiveHelper.sp(context, 12),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Checkmark
              Icon(
                Icons.check_circle,
                color: const Color(0xFF00ACB2),
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Activation status section
  Widget _buildActivationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'TRẠNG THÁI KÍCH HOẠT',
            style: TextStyle(
              color: const Color(0xFF45A191),
              fontSize: ResponsiveHelper.sp(context, 14),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              height: 1.43,
              letterSpacing: 0.70,
            ),
          ),
        ),

        const SizedBox(height: 8),
        // Toggle card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0x0C00ACB2),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0x1900ACB2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: const Color(0xFF00ACB2),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),
                  // Text
                  Text(
                    'Đang bật nhắc nhở',
                    style: TextStyle(
                      color: const Color(0xFF0C1D1A),
                      fontSize: ResponsiveHelper.sp(context, 16),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ],
              ),

              // Toggle switch
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isActive = !_isActive;
                  });
                },
                child: _buildToggleSwitch(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Toggle switch widget
  Widget _buildToggleSwitch() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 24,
      decoration: ShapeDecoration(
        color: _isActive ? const Color(0xFF00ACB2) : const Color(0xFFE2E8F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: _isActive ? 22 : 2,
            top: 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom action buttons
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 32,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0x1900ACB2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Delete button
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _handleDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('Xóa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF5252),
                    side: const BorderSide(
                      width: 2,
                      color: Color(0xFFFF5252),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),
            // Save button
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Lưu'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === ACTIONS ===

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _handleDelete() {
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa lịch nhắc này?',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa lịch nhắc'),
            backgroundColor: Color(0xFFFF5252),
          ),
        );
      },
    );
  }

  void _handleSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu thay đổi'),
        backgroundColor: Color(0xFF00ACB2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, {
      'isActive': _isActive,
      'saved': true,
    });
  }
}


