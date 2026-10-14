import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_home_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeniorHomeFamilyDesign extends StatelessWidget {
  const SeniorHomeFamilyDesign({
    super.key,
    required this.contacts,
    required this.onCallTap,
    required this.onMessageTap,
  });

  final List<SeniorFamilyContact> contacts;
  final ValueChanged<SeniorFamilyContact> onCallTap;
  final VoidCallback onMessageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ng\u01B0\u1EDDi th\u00E2n li\u00EAn h\u1EC7 nhanh',
          style: GoogleFonts.lexend(
            color: SeniorHomePalette.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...contacts.map(
          (contact) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SeniorHomePalette.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: SeniorHomePalette.cardShadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: contact.accent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      contact.initial,
                      style: GoogleFonts.lexend(
                        color: SeniorHomePalette.primaryDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: GoogleFonts.lexend(
                            color: SeniorHomePalette.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          contact.relation,
                          style: GoogleFonts.beVietnamPro(
                            color: SeniorHomePalette.muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MiniActionButton(
                    icon: Icons.chat_bubble_rounded,
                    color: SeniorHomePalette.primary,
                    onTap: onMessageTap,
                  ),
                  const SizedBox(width: 8),
                  _MiniActionButton(
                    icon: Icons.call_rounded,
                    color: SeniorHomePalette.warning,
                    onTap: () => onCallTap(contact),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
