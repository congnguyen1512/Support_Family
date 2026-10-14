import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/fall_detection/data/fall_detection_service.dart';
import 'package:family_guard/core/push_notification/push_notification_service.dart';
import 'package:family_guard/features/login/presentation/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = LoginCubit(AppDependencies.instance.loginUseCase);
  }

  @override
  void dispose() {
    _cubit.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final session = await _cubit.submit();
    if (!mounted || session == null) return;

    await AppDependencies.instance.safeZoneService.initialize(force: true);
    await AppDependencies.instance.locationTrackingService.start();
    await PushNotificationService.instance.syncCurrentTokenToServer();

    if (session.homeType == 'elderly') {
      FallDetectionService.instance.startMonitoring();
    } else {
      await FallDetectionService.instance.stopMonitoring();
    }

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, session.homeRoute, (_) => false);
  }

  void _goToSignup() {
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF5F8F8);
    const brandColor = Color(0xFF0E8C8F);
    const actionColor = Color(0xFF00ADB2);
    const borderColor = Color(0xFF0F172A);
    const textMuted = Color(0xFF475569);
    const lineColor = Color(0xFFE2E8F0);

    return AnimatedBuilder(
      animation: _cubit,
      builder: (context, _) {
        final state = _cubit.state;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/logo_new.png',
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Support Family',
                          style: GoogleFonts.beVietnamPro(
                            color: brandColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.75,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Form(
                        key: _cubit.formKey,
                        child: Column(
                          children: [
                            const _Label(text: 'Email'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _cubit.emailController,
                              obscureText: false,
                              borderColor: borderColor,
                              backgroundColor: bgColor,
                              keyboardType: TextInputType.emailAddress,
                              validator: _cubit.validateEmail,
                            ),
                            const SizedBox(height: 20),
                            const _Label(text: 'Mật khẩu'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _cubit.passwordController,
                              obscureText: state.obscurePassword,
                              borderColor: borderColor,
                              backgroundColor: bgColor,
                              validator: _cubit.validatePassword,
                              suffix: IconButton(
                                onPressed: _cubit.togglePasswordVisibility,
                                icon: Icon(
                                  state.obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.black,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 20),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Quên mật khẩu?',
                                  style: GoogleFonts.publicSans(
                                    color: actionColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 20 / 14,
                                  ),
                                ),
                              ),
                            ),
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFCCD3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Color(0xFFE11D48),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        state.errorMessage!,
                                        style: GoogleFonts.publicSans(
                                          color: const Color(0xFF9F1239),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: actionColor.withValues(
                            alpha: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: const Color(0x3300ADB2),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Đăng nhập',
                                style: GoogleFonts.publicSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 24 / 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: lineColor, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Tiếp tục với',
                            style: GoogleFonts.publicSans(
                              color: const Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 20 / 14,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: lineColor, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: lineColor),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Text(
                              'G',
                              style: GoogleFonts.publicSans(
                                color: const Color(0xFFEA4335),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            label: Text(
                              'Google',
                              style: GoogleFonts.publicSans(
                                color: borderColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: lineColor),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons.apple,
                              color: borderColor,
                              size: 16,
                            ),
                            label: Text(
                              'Apple',
                              style: GoogleFonts.publicSans(
                                color: borderColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Bạn chưa có tài khoản? ',
                          style: GoogleFonts.publicSans(
                            color: textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 20 / 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _goToSignup,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 20),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Đăng ký',
                            style: GoogleFonts.publicSans(
                              color: actionColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 20 / 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.publicSans(
          color: const Color(0xFF0F172A),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 24 / 16,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.obscureText,
    required this.borderColor,
    required this.backgroundColor,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final bool obscureText;
  final Color borderColor;
  final Color backgroundColor;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.publicSans(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}
