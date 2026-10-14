import 'package:family_guard/features/profile_security/presentation/widgets/settings_edit_primitives.dart';
import 'package:flutter/material.dart';

class EditPersonalEmailScreen extends StatelessWidget {
  const EditPersonalEmailScreen({
    super.key,
    this.initialValue = 'alex.johnson@email.com',
  });

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return SettingsEditTextScreen(
      appBarTitle: 'Thông tin cá nhân',
      title: 'Email',
      description: 'Nhập địa chỉ email của bạn để nhận thông báo.',
      initialValue: initialValue,
      keyboardType: TextInputType.emailAddress,
    );
  }
}
