import 'package:family_guard/features/profile_security/presentation/widgets/settings_edit_primitives.dart';
import 'package:flutter/material.dart';

class ChangePasswordDetailScreen extends StatefulWidget {
  const ChangePasswordDetailScreen({super.key});

  @override
  State<ChangePasswordDetailScreen> createState() =>
      _ChangePasswordDetailScreenState();
}

class _ChangePasswordDetailScreenState
    extends State<ChangePasswordDetailScreen> {
  final TextEditingController _currentController = TextEditingController(
    text: 'current-password',
  );
  final TextEditingController _newController = TextEditingController(
    text: 'new-password',
  );
  final TextEditingController _confirmController = TextEditingController(
    text: 'new-password',
  );

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsEditScaffold(
      appBarTitle: 'Mật khẩu & Bảo mật',
      title: 'Thay đổi mật khẩu',
      description:
          'Mật khẩu phải chứa ít nhất 8 kí tự và phải bao gồm kí tự đặc biệt.',
      onCancel: () => Navigator.of(context).pop(),
      onSave: () => Navigator.of(context).pop(true),
      children: [
        SettingsSurfaceCard(
          borderRadius: 20,
          child: Column(
            children: [
              SettingsPasswordFieldRow(
                label: 'Hiện tại',
                controller: _currentController,
              ),
              const Divider(height: 1, thickness: 1, color: kSettingsDivider),
              SettingsPasswordFieldRow(
                label: 'Mới',
                controller: _newController,
              ),
              const Divider(height: 1, thickness: 1, color: kSettingsDivider),
              SettingsPasswordFieldRow(
                label: 'Xác nhận',
                controller: _confirmController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
