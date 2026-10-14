import 'package:flutter/material.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_fields.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_form_data.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_step_scaffold.dart';

class SignupSecurityScreen extends StatefulWidget {
  const SignupSecurityScreen({super.key, required this.initialData});

  final SignupFormData initialData;

  @override
  State<SignupSecurityScreen> createState() => _SignupSecurityScreenState();
}

class _SignupSecurityScreenState extends State<SignupSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.initialData.password);
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.trim().length < 6) {
      return 'Mật khẩu không hợp lệ';
    }
    return null;
  }

  String? _confirmValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value.trim() != _passwordController.text.trim()) {
      return 'Mật khẩu không trùng khớp';
    }
    return null;
  }

  void _finishSignup() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SignupStepScaffold(
      title: 'Bảo mật tài khoản',
      subtitle: 'Tạo một mật khẩu mạnh để giữ dữ liệu của gia đình an toàn và riêng tư.',
      stepIndex: 2,
      buttonText: 'Xong',
      onPrimaryPressed: _finishSignup,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SignupLabel(text: 'Mật khẩu'),
            const SizedBox(height: 10),
            SignupTextField(
              hint: 'Nhập mật khẩu',
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: _passwordValidator,
              trailing: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF07A9B0),
                ),
              ),
            ),
            const SizedBox(height: 34),
            const SignupLabel(text: 'Xác nhận'),
            const SizedBox(height: 10),
            SignupTextField(
              hint: 'Xác nhận lại mật khẩu',
              controller: _confirmController,
              obscureText: _obscureConfirm,
              validator: _confirmValidator,
              trailing: IconButton(
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF07A9B0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
