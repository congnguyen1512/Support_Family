import 'package:family_guard/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kCameraPreviewImage = 'assets/images/image_family.png';

class CameraAddConnectScreen extends StatelessWidget {
  const CameraAddConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CameraFlowScaffold(
      title: 'Thêm camera',
      stepIndicator: const _CameraStepIndicator(
        activeStep: 1,
        completedStep: 0,
      ),
      body: Column(
        children: [
          Text(
            'Nhập thông tin để đồng bộ hóa camera của bạn',
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF3C4949),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 22.75 / 14,
            ),
          ),
          const SizedBox(height: 18),
          _RtspCard(
            buttonLabel: 'Kiểm tra kết nối',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.cameraAddConnectPreview),
          ),
        ],
      ),
    );
  }
}

class CameraAddConnectPreviewScreen extends StatelessWidget {
  const CameraAddConnectPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CameraFlowScaffold(
      title: 'Thêm camera',
      stepIndicator: const _CameraStepIndicator(
        activeStep: 1,
        completedStep: 0,
      ),
      body: Column(
        children: [
          Text(
            'Nhập thông tin để đồng bộ hóa camera của bạn',
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF3C4949),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 22.75 / 14,
            ),
          ),
          const SizedBox(height: 18),
          _RtspCard(
            buttonLabel: 'Tiếp theo',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.cameraAddSetup),
          ),
          const SizedBox(height: 24),
          const _CameraPreviewCard(),
        ],
      ),
    );
  }
}

class CameraAddSetupScreen extends StatefulWidget {
  const CameraAddSetupScreen({super.key});

  @override
  State<CameraAddSetupScreen> createState() => _CameraAddSetupScreenState();
}

class _CameraAddSetupScreenState extends State<CameraAddSetupScreen> {
  bool _isDetectionEnabled = false;

  @override
  Widget build(BuildContext context) {
    return _CameraFlowScaffold(
      title: 'Thêm camera',
      stepIndicator: const _CameraStepIndicator(
        activeStep: 2,
        completedStep: 1,
      ),
      body: Column(
        children: [
          const _CameraPreviewCard(),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt tên cho camera',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF161D1D),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên',
                      hintStyle: GoogleFonts.manrope(
                        color: const Color(0xFF6C7A7A),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF93F0E7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.emergency_rounded,
                        size: 22,
                        color: Color(0xFF0A6F74),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Nhận diện té ngã',
                        style: GoogleFonts.beVietnamPro(
                          color: const Color(0xFF161D1D),
                          fontSize: 33 / 1.85,
                          fontWeight: FontWeight.w700,
                          height: 22.5 / 18,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 22,
                      color: Color(0xFF00ACB1),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Sử dụng AI để phát hiện sự cố khẩn cấp.\nHệ thống sẽ tự động gửi cảnh báo nếu phát hiện người thân bị ngã.',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF3C4949),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 22.75 / 14,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(color: Color(0x33BBC9C9), height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kích hoạt nhận diện',
                        style: GoogleFonts.beVietnamPro(
                          color: const Color(0xFF161D1D),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    _DetectionToggle(
                      value: _isDetectionEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isDetectionEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _PrimaryCta(
            label: 'Tiếp theo',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.cameraAddComplete),
          ),
        ],
      ),
    );
  }
}

class CameraAddCompleteScreen extends StatelessWidget {
  const CameraAddCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CameraFlowScaffold(
      title: 'Thêm camera',
      stepIndicator: const _CameraStepIndicator(
        activeStep: 3,
        completedStep: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 98),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F161D1D),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tất cả đã xong',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF00ACB1),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 32 / 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn sẽ nhận được thông báo khi\nnhận diện được té ngã',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF3C4949),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 26 / 16,
                ),
              ),
              const SizedBox(height: 24),
              _PrimaryCta(
                label: 'Tiếp theo',
                onPressed: () => _finish(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finish(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.cameraList,
      (route) =>
          route.settings.name == AppRoutes.home ||
          route.settings.name == AppRoutes.seniorHome,
      arguments: const {'hasCamera': true, 'showSuccessPopup': true},
    );
  }
}

class _CameraFlowScaffold extends StatelessWidget {
  const _CameraFlowScaffold({
    required this.title,
    required this.stepIndicator,
    required this.body,
  });

  final String title;
  final Widget stepIndicator;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                const Positioned(top: 56, right: -102, child: _BlurOrb()),
                Column(
                  children: [
                    _FlowTopAppBar(title: title),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(30, 18, 30, 28),
                        child: Column(
                          children: [
                            stepIndicator,
                            const SizedBox(height: 22),
                            body,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowTopAppBar extends StatelessWidget {
  const _FlowTopAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xB3F8FAFC),
        boxShadow: [
          BoxShadow(
            color: Color(0x80E2E8F0),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF0D9488),
            ),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF0D9488),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 28 / 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraStepIndicator extends StatelessWidget {
  const _CameraStepIndicator({
    required this.activeStep,
    required this.completedStep,
  });

  final int activeStep;
  final int completedStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepItem(
          index: 1,
          label: 'KẾT NỐI',
          activeStep: activeStep,
          completedStep: completedStep,
        ),
        _StepLine(done: completedStep >= 1),
        _StepItem(
          index: 2,
          label: 'THIẾT LẬP',
          activeStep: activeStep,
          completedStep: completedStep,
        ),
        _StepLine(done: completedStep >= 2),
        _StepItem(
          index: 3,
          label: 'HOÀN TẤT',
          activeStep: activeStep,
          completedStep: completedStep,
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 23),
        height: 2,
        decoration: BoxDecoration(
          color: done ? const Color(0xFF00ACB1) : const Color(0xFFDDE4E4),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.index,
    required this.label,
    required this.activeStep,
    required this.completedStep,
  });

  final int index;
  final String label;
  final int activeStep;
  final int completedStep;

  @override
  Widget build(BuildContext context) {
    final isCompleted = index <= completedStep;
    final isActive = index == activeStep;

    return SizedBox(
      width: 45,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF00ACB1)
                  : const Color(0xFFDDE4E4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '$index',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF3C4949),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              color: (isCompleted || isActive)
                  ? const Color(0xFF00ACB1)
                  : const Color(0xFF3C4949),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 15 / 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RtspCard extends StatelessWidget {
  const _RtspCard({required this.buttonLabel, required this.onPressed});

  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A161D1D),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '! Chắc chắn rằng camera của bạn có hỗ trợ RTSP và đã bật nó',
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF00ACB1),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Đường dẫn RTSP',
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF334155),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              style: GoogleFonts.manrope(
                color: const Color(0xFF161D1D),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Dạng rtsp://admin:password@ip:port/stream',
                hintStyle: GoogleFonts.manrope(
                  color: const Color(0xFF6C7A7A),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _PrimaryCta(label: buttonLabel, onPressed: onPressed),
        ],
      ),
    );
  }
}

class _CameraPreviewCard extends StatelessWidget {
  const _CameraPreviewCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(_kCameraPreviewImage, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x99000000),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xB3FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFBA1A1A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TRỰC TIẾP',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF161D1D),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                        height: 15 / 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xB3FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Color(0xFF3C4949),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectionToggle extends StatelessWidget {
  const _DetectionToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 48,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF00ACB1) : const Color(0xFFE3E9E9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: value
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFFD1D5DB),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00ACB1),
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shadowColor: const Color(0x3300ACB1),
        ),
        child: Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: 24 / 1.71,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      height: 256,
      decoration: BoxDecoration(
        color: const Color(0xFF93F0E7).withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
    );
  }
}
