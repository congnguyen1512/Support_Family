import 'package:family_guard/features/profile_security/presentation/widgets/settings_edit_primitives.dart';
import 'package:flutter/material.dart';

class EditEmergencyContactPhoneScreen extends StatelessWidget {
  const EditEmergencyContactPhoneScreen({
    super.key,
    this.initialValue = '0123 456 789',
  });

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return SettingsEditTextScreen(
      appBarTitle: 'Liên hệ khẩn cấp',
      title: 'Điện thoại',
      description: 'Nhập số điện thoại của liên hệ này.',
      initialValue: initialValue,
      keyboardType: TextInputType.phone,
    );
  }
}
