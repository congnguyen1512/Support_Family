import 'package:family_guard/features/profile_security/presentation/widgets/settings_edit_primitives.dart';
import 'package:flutter/material.dart';

class EditPersonalRoleScreen extends StatelessWidget {
  const EditPersonalRoleScreen({
    super.key,
    this.initialValue = 'Người chăm sóc',
  });

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return SettingsChoiceScreen(
      appBarTitle: 'Thông tin cá nhân',
      title: 'Vai trò',
      description: 'Nhập vai trò hiện tại của bạn.',
      options: const ['Người chăm sóc', 'Người được chăm sóc'],
      initialSelected: initialValue,
    );
  }
}
