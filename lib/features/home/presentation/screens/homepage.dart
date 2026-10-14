import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_route_observer.dart';
import 'package:family_guard/core/session/current_user_view_data.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:family_guard/features/kid_management/presentation/screens/kid_device_control_screen.dart';
import 'package:family_guard/features/login/domain/entities/auth_session.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _backgroundColor = Color(0xFFF0F8F7);
  static const _primaryColor = Color(0xFF00ACB2);
  static const _secondaryColor = Color(0xFF87E4DB);
  static const _headerAvatarUrl =
      'https://www.figma.com/api/mcp/asset/2f585926-b307-4889-9fd8-50f79d086344';
  static const _fallbackMemberAvatarUrl =
      'https://www.figma.com/api/mcp/asset/09129163-8902-4a06-b810-2bec557a806e';

  static final List<_QuickActionData> _quickActions = [
    _QuickActionData(
      title: 'Thành viên',
      subtitle: 'Quản lí thành viên',
      icon: Icons.home_rounded,
      iconColor: const Color(0xFF0EA5A8),
      glowColor: const Color(0x3387E4DB),
      onTapRouteName: AppRoutes.memberList,
    ),
    _QuickActionData(
      title: 'Tâm trạng',
      subtitle: 'Nhật ký hôm nay',
      icon: Icons.sentiment_satisfied_alt_rounded,
      iconColor: const Color(0xFFF97316),
      glowColor: const Color(0x33FED7AA),
      onTapRouteName: AppRoutes.emotionJournal,
    ),
    _QuickActionData(
      title: 'An toàn',
      subtitle: 'Thiết lập vùng',
      icon: Icons.shield_rounded,
      iconColor: const Color(0xFFD946EF),
      glowColor: const Color(0x33F5D0FE),
      onTapRouteName: AppRoutes.safeZone,
    ),
    _QuickActionData(
      title: 'Lịch nhắc',
      subtitle: 'Nhắc nhở hằng ngày',
      icon: Icons.alarm_rounded,
      iconColor: const Color(0xFF3B82F6),
      glowColor: const Color(0x33BFDBFE),
      onTapRouteName: AppRoutes.checkinReminder,
    ),
    _QuickActionData(
      title: 'Camera',
      subtitle: 'Giám sát phát hiện',
      icon: Icons.videocam_rounded,
      iconColor: const Color(0xFF10B981),
      glowColor: const Color(0x33A7F3D0),
      onTap: _showCameraComingSoon,
    ),
    _QuickActionData(
      title: 'Nhịp tim',
      subtitle: 'Theo dõi chỉ số tim',
      icon: Icons.monitor_heart_rounded,
      iconColor: const Color(0xFFEF4444),
      glowColor: const Color(0x33FECACA),
      onTapRouteName: AppRoutes.emotionPulse,
    ),
    _QuickActionData(
      title: 'Quản Lí Ứng Dụng',
      subtitle: 'Thời gian, khu vực,...',
      icon: Icons.tune_rounded,
      iconColor: const Color(0xFF475569),
      glowColor: const Color(0x33CBD5E1),
      builder: _buildKidDeviceControlScreen,
    ),
    _QuickActionData(
      title: 'Tin nhắn',
      subtitle: 'Trò chuyện',
      icon: Icons.message_rounded,
      iconColor: const Color(0xFF6366F1),
      glowColor: const Color(0x33C7D2FE),
      onTapRouteName: AppRoutes.chatList,
    ),
  ];

  static Widget _buildKidDeviceControlScreen() =>
      const KidDeviceControlScreen();

  static void _showCameraComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Chức năng camera đang được phát triển.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                const Positioned.fill(child: _TopDecoration()),
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 132),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const _Header(),
                        const SizedBox(height: 26),
                        _buildMembersSection(),
                        const SizedBox(height: 22),
                        Text(
                          'Tiện ích',
                          style: GoogleFonts.publicSans(
                            color: _primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 28 / 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _QuickActionsGrid(actions: _quickActions),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AppBottomMenu(current: AppNavTab.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return FutureBuilder<_MembersPayload>(
      future: _loadMembersPayload(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 244,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const _MemberCardsEmpty(
            message: 'Không thể tải danh sách thành viên.',
          );
        }

        final payload = snapshot.data ?? _MembersPayload.empty();
        final members = _mapMemberCards(
          payload.relationships,
          payload.locations,
          payload.currentUserBirthday,
          payload.currentUserAge,
        );
        if (members.isEmpty) {
          return const _MemberCardsEmpty(
            message: 'Chưa có thành viên đã liên kết.',
          );
        }

        return _MemberCardsSection(members: members);
      },
    );
  }

  Future<_MembersPayload> _loadMembersPayload() async {
    final results = await Future.wait([
      AppDependencies.instance.getRelationshipsUseCase(),
      AppDependencies.instance.getFamilyLocationsUseCase(),
      AppDependencies.instance.getSavedSessionUseCase(),
    ]);

    final session = results[2] as AuthSession?;
    final currentUser = CurrentUserViewData.fromSession(session);
    final currentUserBirthday = _parseDate(session?.profile.birthday);

    return _MembersPayload(
      relationships: (results[0] as List<Relationship>?) ?? const [],
      locations: (results[1] as List<UserLocation>?) ?? const [],
      currentUserBirthday: currentUserBirthday,
      currentUserAge: currentUser.age,
    );
  }

  static List<_MemberCardData> _mapMemberCards(
    List<Relationship> relationships,
    List<UserLocation> locations,
    DateTime? currentUserBirthday,
    int? currentUserAge,
  ) {
    final filtered = relationships
        .where((item) => item.processing == 'xacnhan')
        .toList();
    final locationMap = {
      for (final item in locations) item.uid: item,
    };

    final members = filtered
        .map(
          (relationship) => _memberCardFromRelationship(
            relationship,
            locationMap[relationship.relationId],
            currentUserBirthday,
            currentUserAge,
          ),
        )
        .toList();
    members.sort((a, b) {
      final roleOrder = _rolePriority(a.role).compareTo(_rolePriority(b.role));
      if (roleOrder != 0) {
        return roleOrder;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return members;
  }

  static int _rolePriority(MemberRole role) {
    switch (role) {
      case MemberRole.senior:
        return 0;
      case MemberRole.child:
        return 1;
      case MemberRole.adult:
        return 2;
    }
  }

  static _MemberCardData _memberCardFromRelationship(
    Relationship relationship,
    UserLocation? location,
    DateTime? currentUserBirthday,
    int? currentUserAge,
  ) {
    final user = relationship.relationUser;
    final relationBirthday = _parseDate(user?.birthday);
    final relationLabel = _relationLabelFor(
      relationship.relationType,
      relationBirthday,
      currentUserBirthday,
      _calculateAge(user?.birthday),
      currentUserAge,
    );
    final fullName = _resolveName(user?.name, user?.email);
    final shortName = _lastNamePart(fullName);
    final name = relationLabel == null ? shortName : '$shortName ($relationLabel)';
    final role = _resolveRole(user?.birthday, user?.role);
    final avatarUrl = _avatarUrlFor(user?.avata);
    final address = location?.addressOrCoordinates ??
        _resolveAddress(user?.address, user?.phone, user?.email);
    final status = _resolveStatus(relationship.processing);
    final lastActive = _resolveLastActive(relationship.createdAt);
    final routeName = _routeForRole(role);
    final trackingArgs = _trackingArgsFor(
      role: role,
      name: name,
      status: status,
      avatarUrl: avatarUrl,
      phoneNumber: user?.phone ?? '',
      relationship: relationLabel ?? relationship.relationType,
      lastActive: lastActive,
    );

    return _MemberCardData(
      name: name,
      role: role,
      status: status,
      battery: '—',
      location: address,
      avatarUrl: avatarUrl,
      currentLocation: location,
      statusDotColor: const Color(0xFF22C55E),
      statusTextColor: const Color(0xFF008A8E),
      accentColor: _accentColorFor(role),
      batteryIcon: Icons.battery_unknown_rounded,
      locationIcon: Icons.location_on_rounded,
      locationIconColor: const Color(0xFF008A8E),
      locationIconBackground: const Color(0x4D87E4DB),
      routeName: routeName,
      trackingArgs: trackingArgs,
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

  static String _lastNamePart(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Thành viên';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.last : trimmed;
  }

  static String? _relationLabelFor(
    String raw,
    DateTime? relationBirthday,
    DateTime? currentUserBirthday,
    int? relationAge,
    int? currentUserAge,
  ) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final rawLower = normalized.toLowerCase().replaceAll('-', '_');
    final parts = rawLower
        .split('_')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    final parentKey = parts.firstWhere(
      _isParentKey,
      orElse: () => '',
    );
    final childKey = parts.firstWhere(
      _isChildKey,
      orElse: () => '',
    );

    if (parentKey.isNotEmpty && childKey.isNotEmpty) {
      final parentLabel = _parentLabelForKey(parentKey) ?? 'Người thân';
      final childLabel = _childLabelForKey(childKey) ?? 'Con';

      if (relationBirthday != null && currentUserBirthday != null) {
        if (relationBirthday.isBefore(currentUserBirthday)) {
          return parentLabel;
        }
        return childLabel;
      }

      if (relationAge != null && currentUserAge != null) {
        if (relationAge > currentUserAge) {
          return parentLabel;
        }
        return childLabel;
      }

      return parentLabel;
    }

    final key = _normalizeRelationKey(normalized);

    var label = _relationLabelFromKey(key) ?? _relationLabelFromKey(normalized);
    label ??= _titleCaseRelation(normalized);

    if ((key == 'anh' || key == 'chi' || key == 'em') &&
        relationAge != null &&
        currentUserAge != null) {
      if (relationAge > currentUserAge) {
        return key == 'em' ? 'Anh/Chị' : label;
      }
      if (relationAge < currentUserAge) {
        return key == 'em' ? 'Em' : 'Em';
      }
    }

    return label;
  }

  static bool _isParentKey(String value) {
    switch (value) {
      case 'me':
      case 'mẹ':
      case 'cha':
      case 'bo':
      case 'bố':
      case 'ba':
      case 'ong':
      case 'ông':
      case 'ba_noi':
      case 'ba_ngoai':
      case 'bà':
        return true;
      default:
        return false;
    }
  }

  static bool _isChildKey(String value) {
    switch (value) {
      case 'con':
      case 'chau':
      case 'cháu':
        return true;
      default:
        return false;
    }
  }

  static String _normalizeRelationKey(String value) {
    final lower = value.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    final compact = lower.replaceAll('__', '_');

    if (compact.contains('ba_noi')) {
      return 'ba_noi';
    }
    if (compact.contains('ba_ngoai')) {
      return 'ba_ngoai';
    }

    return compact.contains('_') ? compact.split('_').first : compact;
  }

  static String? _relationLabelFromKey(String key) {
    switch (key.trim().toLowerCase()) {
      case 'me':
      case 'mẹ':
        return 'Mẹ';
      case 'cha':
        return 'Cha';
      case 'bo':
      case 'bố':
        return 'Bố';
      case 'ba':
        return 'Ba';
      case 'ong':
      case 'ông':
        return 'Ông';
      case 'ba_noi':
      case 'ba_ngoai':
      case 'bà':
        return 'Bà';
      case 'vo':
      case 'vợ':
        return 'Vợ';
      case 'chong':
      case 'chồng':
        return 'Chồng';
      case 'anh':
        return 'Anh';
      case 'chi':
      case 'chị':
        return 'Chị';
      case 'em':
        return 'Em';
      case 'con':
        return 'Con';
      case 'chau':
      case 'cháu':
        return 'Cháu';
      default:
        return null;
    }
  }

  static String? _parentLabelForKey(String key) {
    switch (key.trim().toLowerCase()) {
      case 'me':
      case 'mẹ':
        return 'Mẹ';
      case 'cha':
        return 'Cha';
      case 'bo':
      case 'bố':
        return 'Bố';
      case 'ba':
        return 'Ba';
      case 'ong':
      case 'ông':
        return 'Ông';
      case 'ba_noi':
      case 'ba_ngoai':
      case 'bà':
        return 'Bà';
      default:
        return null;
    }
  }

  static String? _childLabelForKey(String key) {
    switch (key.trim().toLowerCase()) {
      case 'con':
        return 'Con';
      case 'chau':
      case 'cháu':
        return 'Cháu';
      default:
        return null;
    }
  }

  static String _titleCaseRelation(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Người thân';
    }

    final words = trimmed.split(RegExp(r'[_\s]+'));
    final titled = words
        .where((word) => word.isNotEmpty)
        .map((word) {
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .toList();
    return titled.join(' ');
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

  static MemberRole _resolveRole(String? birthday, String? rawRole) {
    final age = _calculateAge(birthday);
    if (age != null) {
      if (age < 16) {
        return MemberRole.child;
      }
      if (age >= 60) {
        return MemberRole.senior;
      }
    }

    switch ((rawRole ?? '').toLowerCase()) {
      case 'treem':
      case 'child':
        return MemberRole.child;
      case 'nguoigia':
      case 'elderly':
      case 'senior':
        return MemberRole.senior;
      default:
        return MemberRole.adult;
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

  static String _avatarUrlFor(String? avatarUrl) {
    final trimmed = avatarUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _fallbackMemberAvatarUrl;
    }
    return trimmed;
  }

  static Color _accentColorFor(MemberRole role) {
    switch (role) {
      case MemberRole.senior:
        return const Color(0xFF0F766E);
      case MemberRole.child:
        return const Color(0xFF2563EB);
      case MemberRole.adult:
        return _primaryColor;
    }
  }

  static String _routeForRole(MemberRole role) {
    switch (role) {
      case MemberRole.child:
        return AppRoutes.kidManagement;
      case MemberRole.senior:
        return AppRoutes.seniorMemberDetail;
      case MemberRole.adult:
        return AppRoutes.adultMemberDetail;
    }
  }

  static MemberTrackingArgs? _trackingArgsFor({
    required MemberRole role,
    required String name,
    required String status,
    required String avatarUrl,
    required String phoneNumber,
    required String relationship,
    required String lastActive,
  }) {
    if (role == MemberRole.child) {
      return null;
    }

    final fallback = role == MemberRole.senior
        ? const MemberTrackingArgs.seniorFallback()
        : const MemberTrackingArgs.adultFallback();

    return MemberTrackingArgs(
      role: role,
      name: name,
      status: status,
      avatarUrl: avatarUrl,
      phoneNumber: phoneNumber,
      relationship: relationship,
      battery: 0,
      connectionStatus: status,
      deviceName: fallback.deviceName,
      lastActive: lastActive,
      timeLabel: fallback.timeLabel,
      mapCenter: fallback.mapCenter,
      routeHistory: fallback.routeHistory,
      playbackStartLabel: fallback.playbackStartLabel,
      playbackEndLabel: fallback.playbackEndLabel,
      totalDistanceLabel: fallback.totalDistanceLabel,
      totalDurationLabel: fallback.totalDurationLabel,
      stopCount: fallback.stopCount,
      averageSpeedLabel: fallback.averageSpeedLabel,
      timelineItems: fallback.timelineItems,
    );
  }
}

class _TopDecoration extends StatelessWidget {
  const _TopDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -96,
            right: -170,
            child: Container(
              width: 342,
              height: 337,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D4DA).withValues(alpha: 0.88),
              ),
            ),
          ),
          Positioned(
            top: -78,
            right: -120,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF009EA7).withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> with RouteAware {
  late Future<AuthSession?> _sessionFuture;
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _sessionFuture = AppDependencies.instance.getSavedSessionUseCase();
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
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _sessionFuture = AppDependencies.instance.getSavedSessionUseCase();
    });
  }

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return 'Ch\u00E0o bu\u1ED5i s\u00E1ng';
    }
    if (hour < 18) {
      return 'Ch\u00E0o bu\u1ED5i chi\u1EC1u';
    }
    return 'Ch\u00E0o bu\u1ED5i t\u1ED1i';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSession?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        final user = CurrentUserViewData.fromSession(snapshot.data);
        final avatarUrl = user.avatarUrl.isNotEmpty
            ? user.avatarUrl
            : HomePage._headerAvatarUrl;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greetingFor(DateTime.now())},\n${user.shortName}',
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF00ACB2),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 32 / 24,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE5E7EB),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF4B5563),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MemberCardsSection extends StatelessWidget {
  const _MemberCardsSection({required this.members});

  final List<_MemberCardData> members;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 244,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final member = members[index];
          return _MemberCard(data: member, faded: index != 0);
        },
      ),
    );
  }
}

class _MemberCardsEmpty extends StatelessWidget {
  const _MemberCardsEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 244,
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.publicSans(
            color: const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.data, required this.faded});

  final _MemberCardData data;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.82 : 1,
      child: Container(
        width: 331.5,
        decoration: BoxDecoration(
          color: faded ? Colors.white : const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: faded ? Border.all(color: const Color(0xFFF3F4F6)) : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x2600ADB2),
              blurRadius: 40,
              spreadRadius: -10,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(child: _MapBackground(location: data.currentLocation)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.70),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x26000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      data.avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: const Color(0xFFE5E7EB),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.person_rounded,
                                                color: Color(0xFF6B7280),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -1,
                                  bottom: -1,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: data.statusDotColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x6687E4DB),
                                          blurRadius: 0,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.name,
                                  style: GoogleFonts.publicSans(
                                    color: data.accentColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 28 / 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.82),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: data.statusDotColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        data.status,
                                        style: GoogleFonts.publicSans(
                                          color: data.statusTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 20 / 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.70),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                data.batteryIcon,
                                size: 18,
                                color: data.accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data.battery,
                                style: GoogleFonts.publicSans(
                                  color: const Color(0xFF4B5563),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 20 / 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () {
                        if (data.trackingArgs == null) {
                          Navigator.pushNamed(context, data.routeName);
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          data.routeName,
                          arguments: data.trackingArgs,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: data.locationIconBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                data.locationIcon,
                                color: data.locationIconColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Vị trí hiện tại',
                                    style: GoogleFonts.publicSans(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 16 / 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    data.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.publicSans(
                                      color: const Color(0xFF111827),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 20 / 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 165 / 188,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return _QuickActionCard(data: item);
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () {
        final onTap = data.onTap;
        if (onTap != null) {
          onTap(context);
          return;
        }
        if (data.onTapRouteName != null) {
          Navigator.pushNamed(context, data.onTapRouteName!);
          return;
        }
        final builder = data.builder;
        if (builder != null) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => builder()));
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: HomePage._secondaryColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: HomePage._secondaryColor),
                boxShadow: [
                  BoxShadow(
                    color: data.glowColor,
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(data.icon, color: data.iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.publicSans(
                      color: const Color(0xFF1F2937),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 22 / 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.publicSans(
                      color: const Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 15 / 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCardData {
  const _MemberCardData({
    required this.name,
    required this.role,
    required this.status,
    required this.battery,
    required this.location,
    required this.avatarUrl,
    required this.currentLocation,
    required this.statusDotColor,
    required this.statusTextColor,
    required this.accentColor,
    required this.batteryIcon,
    required this.locationIcon,
    required this.locationIconColor,
    required this.locationIconBackground,
    required this.routeName,
    required this.trackingArgs,
  });

  final String name;
  final MemberRole role;
  final String status;
  final String battery;
  final String location;
  final String avatarUrl;
  final UserLocation? currentLocation;
  final Color statusDotColor;
  final Color statusTextColor;
  final Color accentColor;
  final IconData batteryIcon;
  final IconData locationIcon;
  final Color locationIconColor;
  final Color locationIconBackground;
  final String routeName;
  final MemberTrackingArgs? trackingArgs;
}

class _MembersPayload {
  const _MembersPayload({
    required this.relationships,
    required this.locations,
    required this.currentUserBirthday,
    required this.currentUserAge,
  });

  final List<Relationship> relationships;
  final List<UserLocation> locations;
  final DateTime? currentUserBirthday;
  final int? currentUserAge;

  factory _MembersPayload.empty() => const _MembersPayload(
        relationships: <Relationship>[],
        locations: <UserLocation>[],
        currentUserBirthday: null,
        currentUserAge: null,
      );
}

class _MapBackground extends StatelessWidget {
  const _MapBackground({required this.location});

  final UserLocation? location;

  @override
  Widget build(BuildContext context) {
    final hasLocation = location?.hasLocation == true;
    if (!hasLocation) {
      return Container(color: const Color(0xFFF4F8F7));
    }

    final center = LatLng(location!.latitude!, location!.longitude!);
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
          userAgentPackageName: 'family_guard',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00ACB2).withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3322C55E),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    this.onTap,
    this.onTapRouteName,
    this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final void Function(BuildContext context)? onTap;
  final String? onTapRouteName;
  final Widget Function()? builder;
}


