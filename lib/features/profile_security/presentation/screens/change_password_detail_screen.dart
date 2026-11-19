import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/theme/app_colors.dart';
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
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty) {
      _showError('Vui lòng nhập mật khẩu hiện tại');
      return;
    }

    if (newPass.length < 8) {
      _showError('Mật khẩu mới phải có ít nhất 8 ký tự');
      return;
    }

    if (newPass != confirm) {
      _showError('Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AppDependencies.instance.apiClient.post(
        '/auth/change-password',
        body: {
          'currentPassword': current,
          'newPassword': newPass,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Đổi mật khẩu thành công!'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showError('Đổi mật khẩu thất bại: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SettingsEditScaffold(
          appBarTitle: 'Mật khẩu & Bảo mật',
          title: 'Thay đổi mật khẩu',
          description:
              'Mật khẩu phải chứa ít nhất 8 kí tự và nên bao gồm cả chữ hoa, chữ thường và số.',
          onCancel: () => Navigator.of(context).pop(),
          onSave: _isLoading ? () {} : _handleSave,
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
        ),
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
