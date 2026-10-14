import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/features/home/domain/entities/models.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// ============================================================
/// MÀN HÌNH: Quản lí lịch nhắc (Tab 0 trong MainShellScreen)
/// Bottom nav được MainShellScreen quản lý — không cần ở đây
/// ============================================================
class ReminderManagementScreen extends StatefulWidget {
  const ReminderManagementScreen({super.key});

  @override
  State<ReminderManagementScreen> createState() =>
      _ReminderManagementScreenState();
}

class _ReminderManagementScreenState extends State<ReminderManagementScreen> {

  // === DATA ===
  List<FamilyMember> _familyMembers = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final relationships = await AppDependencies.instance.getRelationshipsUseCase();
      final confirmed = relationships.where((r) => r.processing == 'xacnhan').toList();
      if (confirmed.isNotEmpty && mounted) {
        setState(() {
          _familyMembers = confirmed.map((r) {
            final user = r.relationUser;
            return FamilyMember(
              name: user?.name ?? 'Thành viên',
              role: r.relationType.isNotEmpty ? r.relationType : 'Người thân',
              imageUrl: (user?.avata != null && user!.avata!.isNotEmpty)
                  ? user.avata!
                  : 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
              isOnline: true,
            );
          }).toList();
          _isLoadingMembers = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoadingMembers = false;
      });
    }
  }

  final List<ReminderFeature> _features = const [
    ReminderFeature(
      title: 'Nhắc nhở uống thuốc',
      icon: Icons.medication_outlined,
      iconColor: Color(0xFF8B5CF6),
      iconBgColor: Color(0xFFF3ECFF),
    ),
    ReminderFeature(
      title: 'Lịch hẹn khám bệnh',
      icon: Icons.calendar_month_outlined,
      iconColor: Color(0xFF14B8A6),
      iconBgColor: AppColors.iconBgTeal,
    ),
    ReminderFeature(
      title: 'Hoạt động thể chất',
      icon: Icons.directions_run_outlined,
      iconColor: Color(0xFFF59E0B),
      iconBgColor: AppColors.iconBgYellow,
    ),
    ReminderFeature(
      title: 'Theo dõisức khỏe',
      icon: Icons.favorite_outline,
      iconColor: Color(0xFFEC4899),
      iconBgColor: AppColors.iconBgPink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackHeaderBar(title: 'Quản lý lịch nhắc'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildFamilySection(),
                      const SizedBox(height: 24),
                      _buildFeaturesSection(),
                      const SizedBox(height: 32),
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

  /// === SECTION: Thành viên gia đình ===
  Widget _buildFamilySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.horizontalPadding(context)),
          child: Text(
            'Thành viên gia đình',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              height: 1.56,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 170,
          child: _isLoadingMembers
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.horizontalPadding(context)),
                  itemCount: _familyMembers.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index < _familyMembers.length) {
                      return _buildFamilyCard(_familyMembers[index]);
                    }
                    return _buildAddFamilyCard();
                  },
                ),
        ),
      ],
    );
  }

  /// Card thành viên gia đình
  Widget _buildFamilyCard(FamilyMember member) {
    final cardW = ResponsiveHelper.isTablet(context) ? 148.0 : 130.0;
    final avatarSz = ResponsiveHelper.sp(context, 60).clamp(48.0, 72.0);
    final nameSz = ResponsiveHelper.sp(context, 13);
    final roleSz = ResponsiveHelper.sp(context, 10);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.memberDetails);
      },
      child: Container(
        width: cardW,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderPrimary, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowPrimary,
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: avatarSz,
                  height: avatarSz,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                        spreadRadius: -1,
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(member.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Online status dot
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: member.isOnline
                          ? AppColors.success
                          : const Color(0xFFD1D5DB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              member.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: nameSz,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
            const SizedBox(height: 2),

            // Role
            Text(
              member.role,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: roleSz,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card "Thêm mới" thành viên
  Widget _buildAddFamilyCard() {
    final cardW = ResponsiveHelper.isTablet(context) ? 148.0 : 130.0;
    final addIconSz = ResponsiveHelper.sp(context, 24);
    final addLabelSz = ResponsiveHelper.sp(context, 10);
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chức năng thêm thành viên đang phát triển'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        width: cardW,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x0C00ACB2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0x4C00ACB2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0x3300ACB2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: AppColors.primary,
                size: addIconSz,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm mới',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: addLabelSz,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// === SECTION: Tính năng nhắc nhở ===
  Widget _buildFeaturesSection() {
    final hPad = ResponsiveHelper.horizontalPadding(context);
    final sectionTitleSz = ResponsiveHelper.sp(context, 18);
    final cols = ResponsiveHelper.gridColumns(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Tính năng nhắc nhở',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: sectionTitleSz,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              height: 1.56,
            ),
          ),
          const SizedBox(height: 16),

          // Adaptive columns grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              return _buildFeatureCard(_features[index], index);
            },
          ),
        ],
      ),
    );
  }
  /// Feature card — navigate based on feature type
  Widget _buildFeatureCard(ReminderFeature feature, int index) {
    final iconContainerSz = ResponsiveHelper.sp(context, 56).clamp(44.0, 68.0);
    final iconSz = ResponsiveHelper.sp(context, 28);
    final titleSz = ResponsiveHelper.sp(context, 14);
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Nhắc nhở uống thuốc → Lịch nhắc đã tạo
          Navigator.of(context).pushNamed(AppRoutes.reminderList);
        } else if (index == 3) {
          // Theo dõi sức khỏe → Báo cáo hoạt động
          Navigator.of(context).pushNamed(AppRoutes.activityReport);
        } else if (index == 1) {
          // Lịch hẹn khám bệnh
          Navigator.of(context).pushNamed(AppRoutes.medicalAppointment);
        } else if (index == 2) {
          // Hoạt động thể chất
          Navigator.of(context).pushNamed(AppRoutes.physicalActivity);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 3),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: iconContainerSz,
              height: iconContainerSz,
              decoration: BoxDecoration(
                color: feature.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature.icon,
                color: feature.iconColor,
                size: iconSz,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              feature.title,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: titleSz,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
