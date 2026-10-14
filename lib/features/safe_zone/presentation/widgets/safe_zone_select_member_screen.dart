import 'package:flutter/material.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// ============================================================
/// SELECT MEMBER SCREEN - Chọn thành viên (Safe Zone)
/// Được dịch và sửa lỗi từ Figma Dev Mode export
/// ============================================================
class SafeZoneSelectMemberScreen extends StatelessWidget {
  const SafeZoneSelectMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackHeaderBar(title: 'Chọn thành viên'),
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [AppColors.kPrimaryLight, AppColors.background],
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0x1900ACB2)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Danh sách thành viên ────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 96,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Build member cards from service
                      Builder(
                        builder: (ctx) {
                          final members = SafeZoneProvider.of(ctx).members;
                          return Column(
                            children: [
                              for (int i = 0; i < members.length; i++) ...[
                                _MemberSelectCard(
                                  memberId: members[i].id,
                                  name: members[i].name,
                                  badgeLabel: members[i].ageGroup,
                                  badgeColor: members[i].badgeColor,
                                  badgeBorderColor: members[i].badgeBorderColor,
                                  badgeTextColor: members[i].badgeTextColor,
                                  zoneCount: '${members[i].zoneCount} vùng an toàn',
                                  avatarUrl: '',
                                  isOnline: members[i].isOnline,
                                ),
                                if (i < members.length - 1)
                                  const SizedBox(height: 16),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nút "Thêm thành viên mới"
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tính năng thêm thành viên mới sẽ được cập nhật'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00ACB2),
                          side: const BorderSide(width: 2, color: Color(0x4C00ACB2)),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                        label: const Text('Thêm thành viên mới'),
                      ),
                    ],
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

// ── Widget thẻ chọn thành viên ─────────────────────────────────────
class _MemberSelectCard extends StatelessWidget {
  const _MemberSelectCard({
    required this.memberId,
    required this.name,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBorderColor,
    required this.badgeTextColor,
    required this.zoneCount,
    required this.avatarUrl,
    required this.isOnline,
  });

  final String memberId;
  final String name;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBorderColor;
  final Color badgeTextColor;
  final String zoneCount;
  final String avatarUrl;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.safeZoneAdd,
        arguments: memberId,
      ),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x1900ACB2)),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar + dot trạng thái online
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE5E7EB),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF22C55E),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Thông tin thành viên
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF0C1D1A),
                    fontSize: 18,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.30,
                  ),
                ),
                const SizedBox(height: 4),
                // Badge nhóm tuổi / vai trò
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: ShapeDecoration(
                    color: badgeColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: badgeBorderColor),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                      letterSpacing: 0.50,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Số vùng an toàn
                Text(
                  zoneCount,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),

          // Nút mũi tên chọn
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF00ACB2),
            size: 24,
          ),
        ],
      ),
    ),
    );
  }
}


