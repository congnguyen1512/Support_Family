import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/theme/app_dimens.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// Screen: Ghi âm lời nhắc (Voice Recording)
/// Giao diện ghi âm với:
/// - Nút mic lớn có sóng phát ra (animated rings)
/// - Waveform visualizer bars
/// - Timer hiển thị 00:XX
/// - Trạng thái "ĐANG GHI ÂM..."
/// - Nút Tạm dừng / Ghi âm lại
/// - Nút Lưu lời nhắc
class VoiceRecordingScreen extends StatefulWidget {
  const VoiceRecordingScreen({super.key});

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen>
    with TickerProviderStateMixin {
  // Recording state
  bool _isRecording = true;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRecording && !_isPaused) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          _buildHeader(context),          // Main content area — cố định, không scroll
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.spacing24,
              ),
              child: Column(
                children: [
                  // Phần trên: mic section chiếm không gian linh hoạt
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: _buildMicSection(),
                    ),
                  ),

                  // Timer
                  _buildTimer(),

                  const SizedBox(height: AppDimens.spacing8),

                  // Status text
                  _buildStatus(),

                  // Ph?n du?i: description v?i kho?ng tr?ng linh ho?t
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _buildDescription(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action panel
          _buildBottomPanel(),
        ],
      ),
    );
  }

  // -- Header --
  Widget _buildHeader(BuildContext context) {
    return AppBackHeaderBar(
      title: 'Ghi âm lời nhắc',
      onBack: () => _showDiscardDialog(context),
    );
  }

  // -- Mic with animated rings + waveform --
  Widget _buildMicSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mic section co giãn theo không gian có sẵn, tối đa 240
        final size = constraints.maxHeight.clamp(120.0, 240.0);
        final micSize = size * 0.67; // ~160 khi size=240
        final borderWidth = (micSize * 0.05).clamp(4.0, 8.0);
        final iconSize = micSize * 0.35;

        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _waveController]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (_isRecording && !_isPaused)
                    _buildPulseRing(size * 0.53, 0.3 * (1 - _pulseController.value * 0.4)),
                  if (_isRecording && !_isPaused)
                    _buildPulseRing(size * 0.4, 0.5 * (1 - _pulseController.value * 0.3)),
                  if (_isRecording && !_isPaused) _buildWaveformBars(),
                  Container(
                    width: micSize,
                    height: micSize,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: borderWidth,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTint30,
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPaused ? Icons.pause_rounded : Icons.mic,
                      size: iconSize,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPulseRing(double radius, double opacity) {
    final scale = 1.0 + _pulseController.value * 0.15;
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaveformBars() {
    const barHeights = [48.0, 64.0, 96.0, 80.0, 128.0, 80.0, 96.0, 64.0, 48.0];
    return Opacity(
      opacity: 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barHeights.length, (i) {
          final baseH = barHeights[i];
          final animFactor =
              0.6 + 0.4 * math.sin(_waveController.value * math.pi + i * 0.5);
          final h = baseH * animFactor;
          return Container(
            width: 4,
            height: h,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  // -- Timer display --

  Widget _buildTimer() {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        color: AppColors.textSlate,
        fontSize: ResponsiveHelper.sp(context, 48),
        fontWeight: FontWeight.w700,
        height: 1,
        letterSpacing: 6,
      ),
    );
  }

  // -- Status text --

  Widget _buildStatus() {
    final text = _isPaused ? 'T\u1EA0M D\u1EEANG' : '\u0110ANG GHI \u00C2M...';
    return Text(
      text,
      style: TextStyle(
        color: _isPaused ? AppColors.textMuted : AppColors.primary,
        fontSize: ResponsiveHelper.sp(context, 14),
        fontWeight: FontWeight.w500,
        letterSpacing: 1.4,
      ),
    );
  }

  // -- Description --

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.spacing16),
      child: Text(
        'Ghi âm bằng giọng của bạn để\nngười thân cảm thấy gần gũi hơn',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSlateLight,
          fontSize: ResponsiveHelper.sp(context, 16),
          fontWeight: FontWeight.w400,
          height: 1.63,
        ),
      ),
    );
  }

  // -- Bottom action panel --

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusRound),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.spacing24,
            AppDimens.spacing20,
            AppDimens.spacing24,
            AppDimens.spacing8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleAction(
                    icon: _isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    label: _isPaused ? 'Tiếp tục' : 'Tạm dừng',
                    bgColor: AppColors.primaryTint10,
                    iconColor: AppColors.primary,
                    onTap: _togglePause,
                  ),

                  const SizedBox(width: 80),

                  _buildCircleAction(
                    icon: Icons.refresh_rounded,
                    label: 'Ghi âm lại',
                    bgColor: AppColors.divider,
                    iconColor: AppColors.textSlateLight,
                    onTap: _onRestart,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacing16),

              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeightXLarge,
                child: ElevatedButton(
                  onPressed: _onSave,
                  child: const Text('Lưu lời nhắc'),
                ),
              ),

              const SizedBox(height: AppDimens.spacing8),

              // Home indicator bar
              Center(
                child: Container(
                  width: 118,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppDimens.radiusCircle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: AppDimens.spacing8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSlateLight,
              fontSize: ResponsiveHelper.sp(context, 14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // -- Actions --

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _onRestart() {
    setState(() {
      _elapsedSeconds = 0;
      _isPaused = false;
      _isRecording = true;
    });
  }

  void _onSave() {
    // TODO: Lưu file ghi âm thực tế
    Navigator.pop(context, {
      'duration': _elapsedSeconds,
      'saved': true,
    });
  }

  void _showDiscardDialog(BuildContext context) {
    if (_elapsedSeconds == 0) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy ghi âm?'),
        content: const Text(
          'Bản ghi âm hiện tại sẽ bị xóa. Bạn có chắc muốn thoát?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Ở lại',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close screen
            },
            child: const Text(
              'Thoát',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}


