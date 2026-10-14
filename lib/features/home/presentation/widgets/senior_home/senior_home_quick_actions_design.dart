import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_home_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeniorHomeQuickActionsDesign extends StatelessWidget {
  const SeniorHomeQuickActionsDesign({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  final List<SeniorQuickAction> actions;
  final ValueChanged<SeniorQuickAction> onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ti\u1EC7n \u00EDch nhanh',
          style: GoogleFonts.lexend(
            color: SeniorHomePalette.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () => onActionTap(action),
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                decoration: BoxDecoration(
                  color: action.isPrimary
                      ? const Color(0xFFFFF2F2)
                      : SeniorHomePalette.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: action.isPrimary
                        ? const Color(0xFFFFD7D7)
                        : const Color(0x1400ACB2),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: SeniorHomePalette.cardShadow,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: action.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(action.icon, color: action.color, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        action.title,
                        style: GoogleFonts.lexend(
                          color: SeniorHomePalette.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.subtitle,
                        style: GoogleFonts.beVietnamPro(
                          color: SeniorHomePalette.muted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
