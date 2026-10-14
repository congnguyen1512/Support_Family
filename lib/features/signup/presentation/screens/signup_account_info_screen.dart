import 'package:flutter/material.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_fields.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_form_data.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_step_scaffold.dart';

class SignupAccountInfoScreen extends StatefulWidget {
  const SignupAccountInfoScreen({super.key, required this.initialData});

  final SignupFormData initialData;

  @override
  State<SignupAccountInfoScreen> createState() => _SignupAccountInfoScreenState();
}

class _SignupAccountInfoScreenState extends State<SignupAccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _showEitherError = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialData.email);
    _phoneController = TextEditingController(text: widget.initialData.phone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(text)) return 'Mail không hợp lệ';
    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final regex = RegExp(r'^[0-9]{9,11}$');
    if (!regex.hasMatch(text)) return 'Số điện thoại không hợp lệ';
    return null;
  }

  void _goNext() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final eitherFilled = email.isNotEmpty || phone.isNotEmpty;

    setState(() => _showEitherError = !eitherFilled);

    final fieldValid = _formKey.currentState?.validate() ?? false;
    if (!eitherFilled || !fieldValid) return;

    final data = widget.initialData.copyWith(email: email, phone: phone);
    Navigator.pushNamed(context, AppRoutes.signupSecurity, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return SignupStepScaffold(
      title: 'Thông tin tài khoản',
      subtitle: 'Hãy bắt đầu với những bước cơ bản để thiết lập hồ sơ Support Family của bạn.',
      stepIndex: 1,
      buttonText: 'Tiếp theo',
      onPrimaryPressed: _goNext,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SignupLabel(text: 'Email'),
            const SizedBox(height: 10),
            SignupTextField(
              hint: 'Email của bạn',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
              onChanged: (_) {
                if (_showEitherError) {
                  setState(() => _showEitherError = false);
                }
              },
            ),
            if (_showEitherError) ...[
              const SizedBox(height: 6),
              const Text(
                'Nhập 1 trong 2: Email hoặc Số điện thoại',
                style: TextStyle(color: Color(0xFFFF2D2D), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 30),
            const SignupLabel(text: 'Số điện thoại'),
            const SizedBox(height: 10),
            SignupTextField(
              hint: 'Số điện thoại của bạn',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: _phoneValidator,
              onChanged: (_) {
                if (_showEitherError) {
                  setState(() => _showEitherError = false);
                }
              },
            ),
            if (_showEitherError) ...[
              const SizedBox(height: 6),
              const Text(
                'Nhập 1 trong 2: Email hoặc Số điện thoại',
                style: TextStyle(color: Color(0xFFFF2D2D), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
