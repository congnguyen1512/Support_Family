import 'package:family_guard/features/profile_security/presentation/widgets/settings_edit_primitives.dart';
import 'package:flutter/material.dart';

class EditEmergencyContactNameScreen extends StatelessWidget {
  const EditEmergencyContactNameScreen({
    super.key,
    this.initialValue = 'Bố Xôi',
  });

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return SettingsEditTextScreen(
      appBarTitle: 'Liên hệ khẩn cấp',
      title: 'Họ và Tên',
      description: 'Nhập họ tên của liên hệ khẩn cấp.',
      initialValue: initialValue,
    );
  }
}
