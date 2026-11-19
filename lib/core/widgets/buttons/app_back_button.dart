import 'package:flutter/material.dart';

/// A standardized, premium back button for the Support Family application.
/// Provides a consistent circular shape, subtle shadow, clean border,
/// and smooth touch ripple feedback across all screens.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.size = 40.0,
    this.iconSize = 18.0,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFF1E293B),
    this.borderColor = const Color(0xFFE2E8F0),
    this.hasShadow = true,
    this.tooltip = 'Quay lại',
  });

  /// Custom tap callback. If null, defaults to [Navigator.maybePop].
  final VoidCallback? onPressed;

  /// Outer diameter of the circular button. Defaults to 40.
  final double size;

  /// Icon size. Defaults to 18.
  final double iconSize;

  /// Background color of the button. Defaults to white.
  final Color backgroundColor;

  /// Color of the back arrow icon. Defaults to dark slate [0xFF1E293B].
  final Color iconColor;

  /// Border outline color. If null, no border is rendered. Defaults to [0xFFE2E8F0].
  final Color? borderColor;

  /// Whether to show a subtle soft elevation shadow. Defaults to true.
  final bool hasShadow;

  /// Tooltip message for accessibility.
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(size / 2),
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: borderColor != null
                  ? Border.all(color: borderColor!, width: 1)
                  : null,
              boxShadow: hasShadow
                  ? const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 1.5),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
