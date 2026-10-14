import 'package:family_guard/features/profile_security/presentation/widgets/settings_edit_primitives.dart';
import 'package:flutter/material.dart';

class EditPersonalPhoneScreen extends StatelessWidget {
  const EditPersonalPhoneScreen({
    super.key,
    this.initialValue = '0123 456 789',
  });

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return SettingsEditTextScreen(
      appBarTitle: 'Thông tin cá nhân',
      title: 'Điện thoại',
      description: 'Nhập số điện thoại của bạn.',
      initialValue: initialValue,
      keyboardType: TextInputType.phone,
    );
  }
}
