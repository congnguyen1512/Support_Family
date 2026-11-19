import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _identifierController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập email hoặc số điện thoại');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AppDependencies.instance.apiClient.post(
        '/auth/forgot-password',
        body: {'identifier': identifier},
        requiresAuth: false,
      );

      if (!mounted) return;
      setState(() {
        _isSuccess = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Yêu cầu không thành công: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBackHeaderBar(title: 'Quên mật khẩu'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _isSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 44,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Đặt lại mật khẩu',
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Nhập email hoặc số điện thoại đã đăng ký của bạn để nhận hướng dẫn khôi phục tài khoản Support Family.',
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
            decoration: InputDecoration(
              hintText: 'Email hoặc số điện thoại',
              hintStyle: GoogleFonts.lexend(color: AppColors.textHint, fontSize: 14),
              prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.primary),
              suffixIcon: _identifierController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20, color: AppColors.textMuted),
                      onPressed: () {
                        setState(() {
                          _identifierController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.lexend(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Gửi liên kết khôi phục',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: Text(
            'Quay lại đăng nhập',
            style: GoogleFonts.lexend(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 36),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 50,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Đã gửi yêu cầu khôi phục!',
          style: GoogleFonts.lexend(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Nếu tài khoản tồn tại trong hệ thống Support Family, chúng tôi đã gửi email/tin nhắn hướng dẫn đặt lại mật khẩu đến ${_identifierController.text}.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Quay lại Đăng nhập',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
