import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_route_observer.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/presentation/cubit/member_management_cubit.dart';
import 'package:family_guard/features/member_management/presentation/models/member_management_demo_data.dart';
import 'package:family_guard/features/member_management/presentation/widgets/member_detail_figma_screen.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThanhVienScreen extends StatefulWidget {
  const ThanhVienScreen({super.key});

  @override
  State<ThanhVienScreen> createState() => _ThanhVienScreenState();
}

class _ThanhVienScreenState extends State<ThanhVienScreen> with RouteAware {
  late final MemberManagementCubit _cubit;
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _cubit = MemberManagementCubit(
      getRelationshipsUseCase: AppDependencies.instance.getRelationshipsUseCase,
      searchUsersUseCase: AppDependencies.instance.searchUsersUseCase,
      inviteRelationshipUseCase:
          AppDependencies.instance.inviteRelationshipUseCase,
      updateRelationshipUseCase:
          AppDependencies.instance.updateRelationshipUseCase,
      deleteRelationshipUseCase:
          AppDependencies.instance.deleteRelationshipUseCase,
      realtimeClient: AppDependencies.instance.realtimeClient,
    )..loadMemberList();
    _cubit.startRealtime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _route) {
      if (_route is PageRoute) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _cubit.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _cubit.loadMemberList(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cubit,
      builder: (context, _) {
        final state = _cubit.state;
        final members = state.relationships
            .where((item) => item.processing != 'huy')
            .map(_MemberItem.fromRelationship)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF0F8F7),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _TopAppBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 13, 24, 24),
                    children: [
                      _SearchField(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.memberSelection,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Thành viên gia đình',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 20,
                          height: 28 / 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (state.isLoadingMembers)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.errorMessage != null)
                        _InlineMessageCard(
                          message: state.errorMessage!,
                          backgroundColor: const Color(0xFFFFF1F2),
                          foregroundColor: const Color(0xFF9F1239),
                        )
                      else if (members.isEmpty)
                        const _InlineMessageCard(
                          message: 'Chưa có thành viên nào trong gia đình.',
                        )
                      else
                        ...members.expand(
                          (member) => [
                            _MemberCard(
                              member: member,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => MemberDetailFigmaScreen(
                                      member: member.member,
                                    ),
                                  ),
                                );
                                if (!mounted) {
                                  return;
                                }
                                await _cubit.loadMemberList();
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBackHeaderBar(
      title: 'Danh sách thành viên',
      titleFontSize: 20,
      trailing: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.addMember),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2DBCC2),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ),
      trailingAreaWidth: 52,
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE3E9E9),
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
              const SizedBox(width: 10),
              Text(
                'Tìm kiếm thành viên',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.onTap});

  final _MemberItem member;
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(avatarUrl: member.member.avatarUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final nameStyle = GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF171D1D),
                              height: 28 / 18,
                            );
                            final displayName = _resolveMemberTitle(
                              fullName: member.member.name,
                              relation: member.member.relation,
                              maxWidth: constraints.maxWidth,
                              textStyle: nameStyle,
                              textDirection: Directionality.of(context),
                            );

                            return Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: nameStyle,
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _resolveStatusIcon(member.member.status),
                              size: 14,
                              color: const Color(0xFF3C4949),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                member.member.status,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3C4949),
                                  height: 20 / 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.battery_full,
                            size: 15,
                            color: Color(0xFF3C4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${member.member.batteryPercent}%',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3C4949),
                              height: 16 / 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFB8C5C5),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEFF5F4)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Color(0xFF3C4949),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            member.member.address,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF3C4949),
                              height: 16 / 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Vùng An Toàn',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF047857),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _resolveStatusIcon(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('truong')) {
      return Icons.school_outlined;
    }
    if (lower.contains('nha')) {
      return Icons.home_outlined;
    }
    if (lower.contains('dao')) {
      return Icons.park_outlined;
    }
    return Icons.work_outline;
  }

  String _resolveMemberTitle({
    required String fullName,
    required String relation,
    required double maxWidth,
    required TextStyle textStyle,
    required TextDirection textDirection,
  }) {
    final relationLabel = _displayRelation(relation);
    final fullLabel = '$fullName ($relationLabel)';
    if (_fitsInOneLine(
      text: fullLabel,
      maxWidth: maxWidth,
      textStyle: textStyle,
      textDirection: textDirection,
    )) {
      return fullLabel;
    }

    final shortLabel = '${_extractGivenName(fullName)} ($relationLabel)';
    return shortLabel;
  }

  bool _fitsInOneLine({
    required String text,
    required double maxWidth,
    required TextStyle textStyle,
    required TextDirection textDirection,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: textDirection,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);

    return !textPainter.didExceedMaxLines;
  }

  String _extractGivenName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return fullName;
    }

    return parts.last;
  }

  String _displayRelation(String relation) {
    final trimmed = relation.trim();
    if (!trimmed.contains('_')) {
      return trimmed;
    }

    final parts = trimmed
        .split('_')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return trimmed;
    }

    return _normalizeRelationToken(parts.last);
  }

  String _normalizeRelationToken(String token) {
    switch (token.toLowerCase()) {
      case 'cha':
        return 'Cha';
      case 'bo':
        return 'Bố';
      case 'me':
        return 'Mẹ';
      case 'con':
        return 'Con';
      case 'ong':
        return 'Ông';
      case 'ba':
        return 'Bà';
      case 'vo':
        return 'Vợ';
      case 'chong':
        return 'Chồng';
      case 'anh':
        return 'Anh';
      case 'chi':
        return 'Chị';
      case 'em':
        return 'Em';
      case 'chau':
        return 'Cháu';
      default:
        if (token.isEmpty) {
          return 'Người thân';
        }
        return '${token[0].toUpperCase()}${token.substring(1)}';
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFEFF5F4), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE2E8F0),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  size: 24,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF01ADB2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberItem {
  const _MemberItem({required this.member});

  final MemberManagementMember member;

  factory _MemberItem.fromRelationship(Relationship relationship) {
    final user = relationship.relationUser;
    final relation = relationship.relationType.trim().isEmpty
        ? 'Người thân'
        : relationship.relationType;

    return _MemberItem(
      member: MemberManagementMember(
        id: relationship.relationId,
        name: _resolveName(user?.name, user?.email),
        relation: relation,
        role: _resolveRole(user?.birthday),
        status: _resolveStatus(relationship.processing),
        address: _resolveAddress(user?.address, user?.phone, user?.email),
        phoneNumber: user?.phone ?? '',
        email: user?.email ?? '',
        avatarUrl: user?.avata ?? '',
        batteryPercent: 0,
        deviceName: 'Chưa cập nhật',
        lastActive: _resolveLastActive(relationship.createdAt),
        relationshipId: relationship.id,
        invitationPending: relationship.processing == 'chuachapnhan',
      ),
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

  static String _resolveAddress(String? address, String? phone, String? email) {
    final trimmedAddress = address?.trim() ?? '';
    if (trimmedAddress.isNotEmpty) {
      return trimmedAddress;
    }

    final trimmedPhone = phone?.trim() ?? '';
    if (trimmedPhone.isNotEmpty) {
      return trimmedPhone;
    }

    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isNotEmpty) {
      return trimmedEmail;
    }

    return 'Chưa cập nhật';
  }

  static MemberRole _resolveRole(String? birthday) {
    final age = _calculateAge(birthday);
    if (age != null) {
      if (age < 16) {
        return MemberRole.child;
      }
      if (age >= 60) {
        return MemberRole.senior;
      }
    }
    return MemberRole.adult;
  }

  static int? _calculateAge(String? birthday) {
    if (birthday == null || birthday.trim().isEmpty) {
      return null;
    }

    final birthDate = DateTime.tryParse(birthday);
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

  static String _resolveStatus(String processing) {
    switch (processing) {
      case 'chuachapnhan':
        return 'Chờ xác nhận';
      case 'xacnhan':
        return 'Đã kết nối';
      case 'huy':
        return 'Đã hủy';
      default:
        return 'Chưa cập nhật';
    }
  }

  static String _resolveLastActive(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Chưa cập nhật';
    }

    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    }
    return '${difference.inDays} ngày trước';
  }
}

class _InlineMessageCard extends StatelessWidget {
  const _InlineMessageCard({
    required this.message,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color(0xFF475569),
  });

  final String message;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: foregroundColor,
        ),
      ),
    );
  }
}
