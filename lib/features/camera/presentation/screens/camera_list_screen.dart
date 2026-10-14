import 'dart:ui';

import 'package:family_guard/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kCameraPreviewImage = 'assets/images/image_family.png';
const _kScreenBackground = Color(0xFFF0F8F7);
const _kHeaderBackground = Color(0xB3F8FAFC);
const _kTitleColor = Color(0xFF0D9488);
const _kPrimaryCta = Color(0xFF00ACB1);
const _kBodyText = Color(0xFF3C4949);

class CameraListScreen extends StatefulWidget {
  const CameraListScreen({
    super.key,
    this.hasCamera = false,
    this.showSuccessPopup = false,
  });

  final bool hasCamera;
  final bool showSuccessPopup;

  @override
  State<CameraListScreen> createState() => _CameraListScreenState();
}

class _CameraListScreenState extends State<CameraListScreen> {
  late final bool _hasCamera = widget.hasCamera;
  bool _didShowSuccessPopup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.showSuccessPopup || _didShowSuccessPopup) {
      return;
    }
    _didShowSuccessPopup = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _showCameraSuccessPopup(context);
    });
  }

  Future<void> _showCameraSuccessPopup(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: 320,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F5F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF1DA8AA),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Thêm camera thành công',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Camera đã được liên kết. Bạn có thể xem trực tiếp và nhận cảnh báo khi có chuyển động bất thường.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF3C4949),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimaryCta,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Xong',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 20 / 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCameraNotificationDialog(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Bật thông báo camera?',
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Bạn muốn nhận cảnh báo từ camera Phòng khách khi phát hiện chuyển động bất thường chứ?',
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF3C4949),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Hủy',
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryCta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Xác nhận',
                style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (accepted == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Đã bật thông báo cho camera Phòng khách.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _startAddCameraFlow(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.cameraAddConnect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kScreenBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                _TopAppBar(
                  onBack: () => Navigator.maybePop(context),
                  onAdd: () => _startAddCameraFlow(context),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      const Positioned(
                        right: -64,
                        top: -40,
                        child: _BackgroundOrb(
                          size: 220,
                          color: Color(0xFF93F0E7),
                          opacity: 0.3,
                        ),
                      ),
                      const Positioned(
                        left: -80,
                        top: 250,
                        child: _BackgroundOrb(
                          size: 192,
                          color: Color(0xFF00ACB1),
                          opacity: 0.2,
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            if (_hasCamera) ...[
                              _CameraFilledCard(
                                onNotificationTap: () =>
                                    _showCameraNotificationDialog(context),
                              ),
                            ] else ...[
                              const SizedBox(height: 16),
                              const _HeroIllustration(),
                              const SizedBox(height: 24),
                              _EmptyCard(
                                onConnectNow: () =>
                                    _startAddCameraFlow(context),
                              ),
                              const SizedBox(height: 40),
                              const _SupportChip(),
                            ],
                          ],
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
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.onBack, required this.onAdd});

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(18, 0, 14, 0),
      decoration: const BoxDecoration(
        color: _kHeaderBackground,
        border: Border(bottom: BorderSide(color: Color(0x80E2E8F0))),
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
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Color(0xFF0D9488),
                  ),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Danh sách camera',
                  style: GoogleFonts.beVietnamPro(
                    color: _kTitleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 28 / 18,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFF33BDC1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF33BDC1).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraFilledCard extends StatelessWidget {
  const _CameraFilledCard({required this.onNotificationTap});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phòng khách',
                        style: GoogleFonts.beVietnamPro(
                          color: const Color(0xFF161D1D),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 28 / 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00ACB2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trực tuyến',
                            style: GoogleFonts.beVietnamPro(
                              color: const Color(0xFF3C4949),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onNotificationTap,
                  icon: const Icon(
                    Icons.settings,
                    color: Color(0xFF0A6F74),
                    size: 20,
                  ),
                  tooltip: 'Thông báo camera',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 256,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 32,
            top: 32,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                color: const Color(0x3387E4DB),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 156,
            height: 156,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF6F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFF12A8AF),
                  borderRadius: BorderRadius.circular(56),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 66,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 35,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.videocam_off_outlined,
                color: Color(0xFF0A6F74),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onConnectNow});

  final VoidCallback onConnectNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 30, 32, 32),
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
        children: [
          Text(
            'Chưa có camera nào',
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              color: _kPrimaryCta,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 32 / 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Bắt đầu bảo vệ người thân bằng\ncách kết nối camera giám sát AI\ntrong nhà bạn.',
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              color: _kBodyText,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 26 / 16,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConnectNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryCta,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                shadowColor: const Color(0x3300ACB1),
              ),
              child: Text(
                'Kết nối ngay',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SupportChip extends StatelessWidget {
  const _SupportChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: Color(0xFF0F7D80),
          ),
          const SizedBox(width: 10),
          Text(
            'HỖ TRỢ KỸ THUẬT 24/7',
            style: GoogleFonts.beVietnamPro(
              color: _kBodyText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
