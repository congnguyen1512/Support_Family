import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/reminder/presentation/widgets/reminder_list_screen.dart';
import 'package:family_guard/features/medical/presentation/screens/medical_appointment_screen.dart';
import 'package:family_guard/features/physical/presentation/screens/physical_activity_screen.dart';
import 'package:family_guard/features/tracking/presentation/widgets/activity_report_screen.dart';
import 'package:flutter/material.dart';

class CheckinReminderMemberListScreen extends StatelessWidget {
  const CheckinReminderMemberListScreen({super.key});

  static const _fallbackMemberAvatarUrl =
      'https://www.figma.com/api/mcp/asset/09129163-8902-4a06-b810-2bec557a806e';

  Future<List<_MemberItem>> _loadMembers() async {
    final relationships =
        await AppDependencies.instance.getRelationshipsUseCase();
    final linked = relationships
        .where((item) => item.processing == 'xacnhan');

    return linked
        .map(_memberFromRelationship)
        .whereType<_MemberItem>()
        .toList();
  }

  static _MemberItem? _memberFromRelationship(Relationship relationship) {
    final user = relationship.relationUser;
    final role = _resolveRole(user?.birthday, user?.role);
    if (user == null) {
      return _MemberItem(
        id: relationship.relationId,
        name: 'Thành viên',
        roleLabel: 'Người thân',
        imageUrl: _fallbackMemberAvatarUrl,
        role: role,
        isOnline: false,
      );
    }

    final name = _resolveName(user.name, user.email);
    final roleLabel = _roleLabelFor(user.birthday, user.role);
    final avatarUrl = _avatarUrlFor(user.avata);

    return _MemberItem(
      id: relationship.relationId,
      name: name,
      roleLabel: roleLabel,
      imageUrl: avatarUrl,
      role: role,
      isOnline: false,
    );
  }

  static String _resolveName(String? name, String? email) {
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isNotEmpty) {
      return trimmedEmail;
    }

    return 'Thành viên';
  }

  static String _avatarUrlFor(String? avatarUrl) {
    final trimmed = avatarUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _fallbackMemberAvatarUrl;
    }
    return trimmed;
  }

  static String _roleLabelFor(String? birthday, String? rawRole) {
    final role = _resolveRole(birthday, rawRole);
    switch (role) {
      case _MemberRole.child:
        return 'Trẻ em';
      case _MemberRole.senior:
        return 'Người cao tuổi';
      case _MemberRole.adult:
        return 'Người chăm sóc';
    }
  }

  static _MemberRole _resolveRole(String? birthday, String? rawRole) {
    final age = _calculateAge(birthday);
    if (age != null) {
      if (age < 16) {
        return _MemberRole.child;
      }
      if (age >= 60) {
        return _MemberRole.senior;
      }
    }

    switch ((rawRole ?? '').toLowerCase()) {
      case 'treem':
      case 'child':
        return _MemberRole.child;
      case 'nguoigia':
      case 'elderly':
      case 'senior':
        return _MemberRole.senior;
      default:
        return _MemberRole.adult;
    }
  }

  static int? _calculateAge(String? birthday) {
    final birthDate = _parseDate(birthday);
    if (birthDate == null) {
      return null;
    }

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static DateTime? _parseDate(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    final direct = DateTime.tryParse(trimmed);
    if (direct != null) {
      return direct;
    }

    if (RegExp(r'^\d{4}$').hasMatch(trimmed)) {
      final year = int.tryParse(trimmed);
      return year == null ? null : DateTime(year, 1, 1);
    }

    final normalized = trimmed.replaceAll('.', '-').replaceAll('/', '-');
    final parts = normalized.split('-').where((part) => part.isNotEmpty).toList();
    if (parts.length != 3) {
      return null;
    }

    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    final third = int.tryParse(parts[2]);
    if (first == null || second == null || third == null) {
      return null;
    }

    if (parts[0].length == 4) {
      return DateTime(first, second, third);
    }

    return DateTime(third, second, first);
  }

  void _showFeaturePicker(BuildContext context, _MemberItem member) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReminderFeatureSheet(
        memberName: member.name,
        onFeatureSelected: (feature) {
          Navigator.of(context).pop();
          switch (feature) {
            case _ReminderFeature.medicine:
              Navigator.of(context).pushNamed(
                AppRoutes.reminderList,
                arguments: ReminderListArgs(
                  memberId: member.id,
                  memberName: member.name,
                  avatarUrl: member.imageUrl,
                  roleLabel: member.roleLabel,
                ),
              );
              break;
            case _ReminderFeature.appointment:
              Navigator.of(context).pushNamed(
                AppRoutes.medicalAppointment,
                arguments: MedicalAppointmentArgs(
                  memberId: member.id,
                  memberName: member.name,
                  avatarUrl: member.imageUrl,
                ),
              );
              break;
            case _ReminderFeature.activity:
              Navigator.of(context).pushNamed(
                AppRoutes.physicalActivity,
                arguments: PhysicalActivityArgs(
                  memberId: member.id,
                  memberName: member.name,
                  avatarUrl: member.imageUrl,
                ),
              );
              break;
            case _ReminderFeature.health:
              Navigator.of(context).pushNamed(
                AppRoutes.activityReport,
                arguments: ActivityReportArgs(
                  memberId: member.id,
                  memberName: member.name,
                  avatarUrl: member.imageUrl,
                ),
              );
              break;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.kPrimaryLight, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.horizontalPadding(context),
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF00ACB2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Danh sách thành viên',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: ResponsiveHelper.sp(context, 20),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF006D5B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<_MemberItem>>(
                  future: _loadMembers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Không thể tải danh sách thành viên.',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      );
                    }

                    final members = snapshot.data ?? const <_MemberItem>[];
                    if (members.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có thành viên đã liên kết.',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.horizontalPadding(context),
                        vertical: 8,
                      ),
                      itemCount: members.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return GestureDetector(
                          onTap: () => _showFeaturePicker(context, member),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 3),
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage:
                                          NetworkImage(member.imageUrl),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: member.isOnline
                                              ? const Color(0xFF22C55E)
                                              : const Color(0xFFD1D5DB),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name,
                                        style: const TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0C1D1A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        member.roleLabel,
                                        style: const TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF00ACB2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFFB0B0B0),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MemberRole { child, adult, senior }

class _MemberItem {
  const _MemberItem({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.imageUrl,
    required this.role,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String roleLabel;
  final String imageUrl;
  final _MemberRole role;
  final bool isOnline;
}

enum _ReminderFeature { medicine, appointment, activity, health }

class _ReminderFeatureSheet extends StatelessWidget {
  const _ReminderFeatureSheet({
    required this.memberName,
    required this.onFeatureSelected,
  });

  final String memberName;
  final ValueChanged<_ReminderFeature> onFeatureSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE2E8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Chọn tính năng cho $memberName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00ACB2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    label: 'Nhắc nhở\nuống thuốc',
                    icon: Icons.medication_outlined,
                    bgColor: const Color(0xFFEDE7F6),
                    iconColor: const Color(0xFF7E57C2),
                    onTap: () =>
                        onFeatureSelected(_ReminderFeature.medicine),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeatureCard(
                    label: 'Lịch hẹn\nkhám bệnh',
                    icon: Icons.calendar_month_outlined,
                    bgColor: const Color(0xFFE8F8F7),
                    iconColor: const Color(0xFF00ACB2),
                    onTap: () =>
                        onFeatureSelected(_ReminderFeature.appointment),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    label: 'Hoạt động\nthể chất',
                    icon: Icons.directions_run_rounded,
                    bgColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFFA000),
                    onTap: () =>
                        onFeatureSelected(_ReminderFeature.activity),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeatureCard(
                    label: 'Theo dõi\nsức khỏe',
                    icon: Icons.favorite_outline_rounded,
                    bgColor: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFE91E63),
                    onTap: () => onFeatureSelected(_ReminderFeature.health),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Hủy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF2F6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
