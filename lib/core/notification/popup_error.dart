import 'package:family_guard/core/constants/app_colors.dart';
import 'package:family_guard/core/theme/app_text_styles.dart';
import 'package:family_guard/core/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';

Future<void> showPopupError(
  BuildContext context, {
  required String message,
  String title = 'Co loi xay ra',
  String actionLabel = 'Dong',
  VoidCallback? onActionPressed,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return PopupError(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      );
    },
  );
}

class PopupError extends StatelessWidget {
  const PopupError({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel = 'Dong',
    this.onActionPressed,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.label().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.borderDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    splashRadius: 18,
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.body().copyWith(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(
                label: actionLabel,
                onPressed: () {
                  Navigator.of(context).pop();
                  onActionPressed?.call();
                },
                height: 46,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
