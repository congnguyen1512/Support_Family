import 'package:family_guard/features/kid_management/presentation/shared/kid_management_data.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:flutter/material.dart';

class KidDashboardHeader extends StatelessWidget {
  const KidDashboardHeader({
    super.key,
    required this.onBack,
    required this.onChatTap,
  });

  final VoidCallback onBack;
  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            splashRadius: 20,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF01ADB2),
            ),
          ),
          Expanded(
            child: Text(
              kidName,
              textAlign: TextAlign.center,
              style: kidTextStyle(
                size: 18,
                weight: FontWeight.w700,
                color: const Color(0xFF171D1D),
                height: 28 / 18,
              ),
            ),
          ),
          IconButton(
            onPressed: onChatTap,
            splashRadius: 20,
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 24,
              color: Color(0xFF171D1D),
            ),
          ),
        ],
      ),
    );
  }
}

class KidProfileHeroSection extends StatelessWidget {
  const KidProfileHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 128,
                height: 128,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    kidAvatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFD7E5E5),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.battery_charging_full_rounded,
                    size: 16,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            kidName,
            style: kidTextStyle(
              size: 24,
              weight: FontWeight.w700,
              color: const Color(0xFF171D1D),
              height: 32 / 24,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x1A17E8E8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_walk_rounded,
                  size: 14,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 6),
                Text(
                  kidStatus,
                  style: kidTextStyle(
                    size: 14,
                    weight: FontWeight.w700,
                    color: const Color(0xFF16A34A),
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KidQuickActionButton extends StatelessWidget {
  const KidQuickActionButton({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.shadowColor,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final Color backgroundColor;
  final IconData icon;
  final Color shadowColor;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: 24, color: iconColor),
      ),
    );
  }
}

class KidHubCard extends StatelessWidget {
  const KidHubCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kidTextStyle(
                  size: 18,
                  weight: FontWeight.w700,
                  color: const Color(0xFF171D1D),
                  height: 22.5 / 18,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: kidTextStyle(
                    size: 12,
                    weight: FontWeight.w400,
                    color: const Color(0xFF3C4949),
                    height: 16 / 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KidDetailScaffold extends StatelessWidget {
  const KidDetailScaffold({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 14, 24, 24),
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KidDetailHeader(title: title),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KidDetailHeader extends StatelessWidget {
  const _KidDetailHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBackHeaderBar(
      title: title,
      onBack: () => Navigator.maybePop(context),
      padding: EdgeInsets.zero,
      trailing: const SizedBox(width: 24),
      trailingAreaWidth: 24,
    );
  }
}

class KidSectionHeading extends StatelessWidget {
  const KidSectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: kidTextStyle(
        size: 20,
        weight: FontWeight.w700,
        color: const Color(0xFF171D1D),
        height: 28 / 20,
      ),
    );
  }
}

class KidSurfaceCard extends StatelessWidget {
  const KidSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 32,
    this.backgroundColor = Colors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F191C1E),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class KidMapMarker extends StatelessWidget {
  const KidMapMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 51,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          kidAvatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFD8E2E2),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class KidSafeZoneTile extends StatelessWidget {
  const KidSafeZoneTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFBDEBEC),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF406B6D)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: kidTextStyle(
                        size: 16,
                        weight: FontWeight.w700,
                        color: const Color(0xFF171D1D),
                        height: 24 / 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: kidTextStyle(
                        size: 14,
                        weight: FontWeight.w400,
                        color: const Color(0xFF3C4949),
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFBBC9C9)),
            ],
          ),
        ),
      ),
    );
  }
}

class KidAlertListTile extends StatelessWidget {
  const KidAlertListTile({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
  });

  final IconData icon;
  final Color iconBackground;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kidTextStyle(
                    size: 14,
                    weight: FontWeight.w700,
                    color: const Color(0xFF171D1D),
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: kidTextStyle(
                    size: 12,
                    weight: FontWeight.w400,
                    color: subtitleColor,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KidUsageCategoryRow extends StatelessWidget {
  const KidUsageCategoryRow({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.progress,
    required this.progressColor,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;
  final double progress;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: kidTextStyle(
                  size: 14,
                  weight: FontWeight.w700,
                  color: const Color(0xFF171D1D),
                  height: 20 / 14,
                ),
              ),
            ),
            Text(
              value,
              style: kidTextStyle(
                size: 14,
                weight: FontWeight.w700,
                color: const Color(0xFF171D1D),
                height: 20 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        KidProgressLine(
          progress: progress,
          backgroundColor: const Color(0xFFEFF5F4),
          foregroundColor: progressColor,
          height: 6,
        ),
      ],
    );
  }
}

class KidLimitPill extends StatelessWidget {
  const KidLimitPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5F4),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 18,
            color: Color(0xFF406B6D),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: kidTextStyle(
                size: 14,
                weight: FontWeight.w500,
                color: const Color(0xFF171D1D),
                height: 20 / 14,
              ),
            ),
          ),
          Text(
            value,
            style: kidTextStyle(
              size: 14,
              weight: FontWeight.w400,
              color: const Color(0xFF3C4949),
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}

class KidAutomationRuleTile extends StatelessWidget {
  const KidAutomationRuleTile({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabledOpacity = 1,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double enabledOpacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabledOpacity,
      child: KidSurfaceCard(
        padding: const EdgeInsets.all(24),
        radius: 24,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kidTextStyle(
                      size: 16,
                      weight: FontWeight.w600,
                      color: const Color(0xFF171D1D),
                      height: 24 / 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: kidTextStyle(
                      size: 12,
                      weight: FontWeight.w500,
                      color: const Color(0xFF3C4949),
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            KidHubSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class KidSuggestionCard extends StatelessWidget {
  const KidSuggestionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          height: 160,
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const Spacer(),
              Text(
                title,
                style: kidTextStyle(
                  size: 16,
                  weight: FontWeight.w700,
                  color: const Color(0xFF171D1D),
                  height: 20 / 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KidDeviceToggleRow extends StatelessWidget {
  const KidDeviceToggleRow({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF171D1D)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: kidTextStyle(
                  size: 16,
                  weight: FontWeight.w600,
                  color: const Color(0xFF171D1D),
                  height: 24 / 16,
                ),
              ),
              Text(
                subtitle,
                style: kidTextStyle(
                  size: 12,
                  weight: FontWeight.w400,
                  color: const Color(0xFF3C4949),
                  height: 16 / 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        KidHubSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class KidInfoGridCard extends StatelessWidget {
  const KidInfoGridCard({
    super.key,
    required this.leading,
    required this.label,
    required this.value,
  });

  final Widget leading;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return KidSurfaceCard(
      padding: const EdgeInsets.all(20),
      radius: 32,
      child: SizedBox(
        height: 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const Spacer(),
            Text(
              label,
              style: kidTextStyle(
                size: 12,
                weight: FontWeight.w500,
                color: const Color(0xFF3C4949),
                height: 16 / 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: kidTextStyle(
                size: 16,
                weight: FontWeight.w700,
                color: const Color(0xFF171D1D),
                height: 24 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KidFilledPillButton extends StatelessWidget {
  const KidFilledPillButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.trailingIcon,
    this.fullWidth = false,
    this.verticalPadding = 12,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final IconData? trailingIcon;
  final bool fullWidth;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(48),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(48),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: verticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: kidTextStyle(
                  size: 14,
                  weight: FontWeight.w700,
                  color: foregroundColor,
                  height: 20 / 14,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: 16, color: foregroundColor),
              ],
            ],
          ),
        ),
      ),
    );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class KidProgressLine extends StatelessWidget {
  const KidProgressLine({
    super.key,
    required this.progress,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.height,
  });

  final double progress;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: foregroundColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class KidHubSwitch extends StatelessWidget {
  const KidHubSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF01ADB2) : const Color(0xFFDEE4E3),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: value
                  ? Border.all(color: Colors.white)
                  : Border.all(color: const Color(0xFFD1D5DB)),
            ),
          ),
        ),
      ),
    );
  }
}
