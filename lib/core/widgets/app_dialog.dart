import 'package:flutter/material.dart';
import 'package:family_guard/core/theme/app_colors.dart';

enum AppDialogType { delete, success, warning, info }

class _Preset {
  final Color titleColor;
  final Color buttonColor;

  const _Preset({
    required this.titleColor,
    required this.buttonColor,
  });
}

class AppDialog {
  AppDialog._();

  static const Map<AppDialogType, _Preset> _presets = {
    AppDialogType.delete: _Preset(
      titleColor: AppColors.error,
      buttonColor: AppColors.error,
    ),
    AppDialogType.success: _Preset(
      titleColor: Colors.green,
      buttonColor: Colors.green,
    ),
    AppDialogType.warning: _Preset(
      titleColor: Colors.orange,
      buttonColor: Colors.orange,
    ),
    AppDialogType.info: _Preset(
      titleColor: Colors.blue,
      buttonColor: Colors.blue,
    ),
  };

  static void show({
    required BuildContext context,
    required AppDialogType type,
    required String title,
    required String content,
    required String confirmText,
    required IconData icon,
    required VoidCallback onConfirm,
  }) {
    final preset = _presets[type]!;
    showDialog(
      context: context,
      builder: (BuildContext dContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: preset.titleColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dContext).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: preset.buttonColor,
              ),
              onPressed: () {
                Navigator.of(dContext).pop();
                onConfirm();
              },
              child: Text(
                confirmText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
