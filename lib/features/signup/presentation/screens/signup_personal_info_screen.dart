import 'package:flutter/material.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_fields.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_form_data.dart';
import 'package:family_guard/features/signup/presentation/widgets/signup_step_scaffold.dart';

class SignupPersonalInfoScreen extends StatefulWidget {
  const SignupPersonalInfoScreen({super.key, this.initialData = const SignupFormData()});

  final SignupFormData initialData;

  @override
  State<SignupPersonalInfoScreen> createState() => _SignupPersonalInfoScreenState();
}

class _SignupPersonalInfoScreenState extends State<SignupPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _addressController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData.fullName);
    _birthDateController = TextEditingController(text: widget.initialData.age);
    _addressController = TextEditingController(text: widget.initialData.address);
    _selectedGender = widget.initialData.gender.isEmpty ? null : widget.initialData.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $label';
    }
    return null;
  }

  String? _birthDateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng chọn ngày sinh';
    }
    return null;
  }

  String? _genderValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng chọn giới tính';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _birthDateController.text = _formatDate(picked);
    });
  }

  void _goNext() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final data = widget.initialData.copyWith(
      fullName: _nameController.text.trim(),
      age: _birthDateController.text.trim(),
      gender: _selectedGender ?? '',
      address: _addressController.text.trim(),
    );

    Navigator.pushNamed(context, AppRoutes.signupAccount, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return SignupStepScaffold(
      title: 'Thông tin cá nhân',
      subtitle: 'Hãy bắt đầu với những bước cơ bản để thiết lập hồ sơ Support Family của bạn.',
      stepIndex: 0,
      buttonText: 'Tiếp theo',
      onPrimaryPressed: _goNext,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SignupLabel(text: 'Họ và tên'),
            const SizedBox(height: 10),
            SignupTextField(
              hint: 'Nhập họ và tên',
              controller: _nameController,
              validator: (value) => _requiredValidator(value, 'họ và tên'),
            ),
            const SizedBox(height: 22),
            const SignupLabel(text: 'Ngày sinh'),
            const SizedBox(height: 10),
            SignupTextField(
              hint: 'Chọn ngày sinh',
              controller: _birthDateController,
              readOnly: true,
              onTap: _pickBirthDate,
              validator: _birthDateValidator,
              trailing: const Icon(Icons.calendar_today_outlined, color: Color(0xFF07A9B0), size: 20),
            ),
            const SizedBox(height: 22),
            const SignupLabel(text: 'Giới tính'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FBFC),
                hintText: 'Chọn giới tính',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFB2E9EE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF07A9B0)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFFF2D2D)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFFF2D2D)),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                DropdownMenuItem(value: 'Khác', child: Text('Khác')),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
              validator: _genderValidator,
            ),
            const SizedBox(height: 22),
            const SignupLabel(text: 'Địa chỉ'),
            const SizedBox(height: 10),
            SignupTextField(
              hint: 'Địa chỉ của bạn',
              controller: _addressController,
              validator: (value) => _requiredValidator(value, 'địa chỉ'),
            ),
          ],
        ),
      ),
    );
  }
}
