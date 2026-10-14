import 'package:family_guard/features/profile_security/presentation/widgets/settings_edit_primitives.dart';
import 'package:flutter/material.dart';

class EditEmergencyContactRelationshipScreen extends StatelessWidget {
  const EditEmergencyContactRelationshipScreen({
    super.key,
    this.initialValue = 'Chồng',
  });

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return SettingsChoiceScreen(
      appBarTitle: 'Liên hệ khẩn cấp',
      title: 'Vai trò',
      description: 'Nhập quan hệ của bạn với liên hệ này.',
      options: const ['Chồng', 'Vợ', 'Cha/Mẹ', 'Con', 'Anh/Chị', 'Thêm...'],
      initialSelected: initialValue,
    );
  }
}
