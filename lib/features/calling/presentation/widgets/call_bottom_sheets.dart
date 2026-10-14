import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showRoleCallOptionsSheet(
  BuildContext context, {
  required CallTargetArgs target,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (sheetContext) {
      final screenHeight = MediaQuery.of(sheetContext).size.height;
      return FractionallySizedBox(
        heightFactor: 0.78,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F4F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 50,
                offset: Offset(0, -12),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight * 0.78),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0x66BCC9C9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _CallTargetHeader(target: target),
                      const SizedBox(height: 24),
                      _CallOptionTile(
                        icon: Icons.call_outlined,
                        title: 'Gọi Thoại',
                        subtitle: 'Dùng số điện thoại',
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await showExternalAppConfirmSheet(
                            context,
                            target: target,
                            actionType: CallActionType.phone,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _CallOptionTile(
                        icon: Icons.videocam_outlined,
                        title: 'Gọi Video',
                        subtitle: 'Bắt đầu với FaceTime',
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await showExternalAppConfirmSheet(
                            context,
                            target: target,
                            actionType: CallActionType.video,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _CallOptionTile(
                        icon: Icons.phone_iphone_rounded,
                        title: 'Gọi bằng Ứng Dụng',
                        subtitle: 'Gọi ngay',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.inAppCall,
                            arguments: InAppCallArgs(
                              name: target.name,
                              avatarUrl: target.avatarUrl,
                              role: target.role,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(62),
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0x4DBCC9C9),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.beVietnamPro(
                            color: const Color(0xFF3D4949),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showExternalAppConfirmSheet(
  BuildContext context, {
  required CallTargetArgs target,
  required CallActionType actionType,
}) {
  final title = actionType == CallActionType.phone
      ? 'Mở ứng dụng điện thoại'
      : 'Mở FaceTime';
  final subtitle = actionType == CallActionType.phone
      ? 'Support Family sẽ chuyển bạn sang ứng dụng gọi thoại ngoài app để liên hệ với ${target.name}.'
      : 'Support Family sẽ chuyển bạn sang ứng dụng gọi video ngoài app để liên hệ với ${target.name}.';

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black45,
    builder: (sheetContext) {
      return FractionallySizedBox(
        heightFactor: 0.36,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F4F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0x66BCC9C9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0x1A01ADB2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      actionType == CallActionType.phone
                          ? Icons.call_made_rounded
                          : Icons.ondemand_video_rounded,
                      color: const Color(0xFF006A6A),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF191C1E),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF3D4949),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            side: const BorderSide(color: Color(0x4DBCC9C9)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text(
                            'Hủy',
                            style: GoogleFonts.beVietnamPro(
                              color: const Color(0xFF3D4949),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  actionType == CallActionType.phone
                                      ? 'Đã mô phỏng chuyển sang ứng dụng gọi thoại ngoài.'
                                      : 'Đã mô phỏng chuyển sang ứng dụng gọi video ngoài.',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            backgroundColor: const Color(0xFF01ADB2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text(
                            'Tiếp tục',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _CallTargetHeader extends StatelessWidget {
  const _CallTargetHeader({required this.target});

  final CallTargetArgs target;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFF006A6A), Color(0xFF19A7A8)],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF2F4F6),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      target.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFD8E2E2),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF64748B),
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF2F4F6),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            target.name,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF191C1E),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x3319A7A8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  target.roleLabel,
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF003536),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.33,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                target.presenceLabel,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF3D4949),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallOptionTile extends StatelessWidget {
  const _CallOptionTile({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0x1A006A6A),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF006A6A), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF191C1E),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF3D4949),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFBCC9C9),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
