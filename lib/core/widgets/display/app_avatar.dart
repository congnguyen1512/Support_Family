import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.initials,
    this.icon,
    this.size = 44,
    this.backgroundColor = const Color(0xFFE2E8F0),
    this.textColor = const Color(0xFF334155),
    this.textStyle,
    this.onTap,
    this.border,
  });

  final String? imageUrl;
  final String? assetPath;
  final String? initials;
  final IconData? icon;
  final double size;
  final Color backgroundColor;
  final Color textColor;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );

    if (onTap == null) {
      return avatar;
    }

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    }

    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    if (initials != null && initials!.trim().isNotEmpty) {
      return Center(
        child: Text(
          initials!.trim().toUpperCase(),
          style: textStyle ??
              TextStyle(
                color: textColor,
                fontSize: size * 0.34,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
    }

    return Icon(
      icon ?? Icons.person_rounded,
      color: textColor,
      size: size * 0.54,
    );
  }
}
