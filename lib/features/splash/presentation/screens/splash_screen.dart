import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

class FamilyGuardSplashScreen extends StatefulWidget {
  const FamilyGuardSplashScreen({super.key});

  static const _backgroundColor = Color(0xFFF5F8F8);
  static const _brandTeal = Color(0xFF0E8C8F);
  static const _ctaTeal = Color(0xFF00ADB2);
  static const _bodyText = Color(0xFF475569);
  static const _homeIndicator = Color(0xFFCBD5E1);

  @override
  State<FamilyGuardSplashScreen> createState() =>
      _FamilyGuardSplashScreenState();
}

class _FamilyGuardSplashScreenState extends State<FamilyGuardSplashScreen> {
  @override
  void initState() {
    super.initState();
    _widgetsReady();
  }

  Future<void> _widgetsReady() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) {
      return;
    }

    try {
      final session = await AppDependencies.instance
          .loadCurrentSessionUseCase();
      if (!mounted) {
        return;
      }

      final targetRoute = session?.homeRoute ?? AppRoutes.login;
      Navigator.of(context).pushNamedAndRemoveUntil(targetRoute, (_) => false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: FamilyGuardSplashScreen._backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: FamilyGuardSplashScreen._backgroundColor),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: media.size.height * 0.17,
              child: const _HeroSection(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const _LowerSection(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Center(
                child: Container(
                  height: 6,
                  width: 128,
                  decoration: BoxDecoration(
                    color: FamilyGuardSplashScreen._homeIndicator,
                    borderRadius: BorderRadius.circular(999),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/image_family.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 6),
        Text(
          'Support Family',
          style: GoogleFonts.beVietnamPro(
            color: FamilyGuardSplashScreen._brandTeal,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.75,
          ),
        ),
      ],
    );
  }
}

class _LowerSection extends StatelessWidget {
  const _LowerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 31.25, 32, 64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00F5F8F8), Color(0xFFF5F8F8), Color(0xFFF5F8F8)],
          stops: [0, 0.5, 1],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chào mừng bạn đến với\nSupport Family',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.75,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sự an toàn của gia đình bạn,\n'
            'tất cả ở một nơi.\n'
            'Kết nối, bảo vệ và cập nhật thông tin với\n'
            'cập nhật theo thời gian thực.',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              color: FamilyGuardSplashScreen._bodyText,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.625,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: FamilyGuardSplashScreen._ctaTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    shadowColor: const Color(0x3300ADB2),
                  ).copyWith(
                    elevation: const WidgetStatePropertyAll(0),
                    shadowColor: const WidgetStatePropertyAll(
                      Color(0x3300ADB2),
                    ),
                  ),
              child: Text(
                'BẮT ĐẦU',
                style: GoogleFonts.publicSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.45,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                child: Text.rich(
                  TextSpan(
                    text: 'Bạn đã có tài khoản? ',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Đăng nhập',
                        style: GoogleFonts.inter(
                          color: FamilyGuardSplashScreen._brandTeal,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ],
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
