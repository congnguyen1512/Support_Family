import 'package:family_guard/features/profile_security/presentation/widgets/settings_edit_primitives.dart';
import 'package:flutter/material.dart';

class EditPersonalNameScreen extends StatelessWidget {
  const EditPersonalNameScreen({super.key, this.initialValue = 'Mẹ Xôi'});

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return SettingsEditTextScreen(
      appBarTitle: 'Thông tin cá nhân',
      title: 'Họ và Tên',
      description: 'Bạn chỉ có thể đổi tên một lần mỗi 7 ngày.',
      initialValue: initialValue,
    );
  }
}
