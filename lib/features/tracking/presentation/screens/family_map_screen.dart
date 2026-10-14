// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:family_guard/features/calling/presentation/widgets/call_bottom_sheets.dart';
import 'package:family_guard/features/chat/presentation/screens/chat_models.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/location_tracking/presentation/bloc/location_tracking_bloc.dart';
import 'package:family_guard/features/location_tracking/presentation/bloc/location_tracking_event.dart';
import 'package:family_guard/features/login/domain/entities/auth_profile.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class FamilyMapScreen extends StatefulWidget {
  const FamilyMapScreen({
    super.key,
    this.homeRouteName = AppRoutes.home,
    this.trackingRouteName = AppRoutes.tracking,
    this.notificationsRouteName = AppRoutes.notifications,
    this.settingsRouteName = AppRoutes.settings,
    this.thirdTab = AppBottomMenuThirdTab.notifications,
    this.showBottomNav = true,
  });

  final String homeRouteName;
  final String trackingRouteName;
  final String notificationsRouteName;
  final String settingsRouteName;
  final AppBottomMenuThirdTab thirdTab;
  final bool showBottomNav;

  @override
  State<FamilyMapScreen> createState() => _FamilyMapScreenState();
}

class _FamilyMapScreenState extends State<FamilyMapScreen>
    with SingleTickerProviderStateMixin {
  static const LatLng _initialCenter = LatLng(16.0544, 108.2022);
  static const double _initialZoom = 15;

  final MapController _mapController = MapController();
  late final AnimationController _mapAnimationController;
  late final LocationTrackingBloc _locationBloc;

  _LatLngTween? _centerTween;
  Tween<double>? _zoomTween;
  bool _isMapReady = false;

  _MemberFilter _selectedFilter = _MemberFilter.all;
  String? _selectedMemberId;
  AuthProfile? _currentProfile;
  UserLocation? _lastSyncedOwnLocation;

  static const String _fallbackAvatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=300&auto=format&fit=crop';

  String get _chatRouteName => widget.thirdTab == AppBottomMenuThirdTab.chat
      ? widget.notificationsRouteName
      : AppRoutes.chatList;

  List<_MapMember> get _members {
    final state = _locationBloc.state;
    final members = state.familyLocations
        .map((item) => _mapMemberFromLocation(item, state.myLocation))
        .toList(growable: true);

    final selfMember = _buildSelfMember(state.myLocation);
    if (selfMember != null &&
        !members.any((member) => member.id == selfMember.id)) {
      members.insert(0, selfMember);
    }

    return members;
  }

  List<_MapMember> get _filteredMembers {
    final members = _members;
    if (_selectedFilter == _MemberFilter.all) {
      return members;
    }
    return members.where((member) => member.role == _selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    final dependencies = AppDependencies.instance;
    _locationBloc = LocationTrackingBloc(
      getMyLocationUseCase: dependencies.getMyLocationUseCase,
      getFamilyLocationsUseCase: dependencies.getFamilyLocationsUseCase,
    )..addListener(_handleLocationStateChanged);
    dependencies.locationTrackingService.addListener(
      _handleTrackingServiceChanged,
    );
    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(_handleMapAnimation);
    _loadCurrentProfile();
    _locationBloc.dispatch(const LoadMyLocationEvent());
    _locationBloc.dispatch(const StartFamilyLocationPollingEvent());
    dependencies.locationTrackingService.refreshNow();
  }

  @override
  void dispose() {
    AppDependencies.instance.locationTrackingService.removeListener(
      _handleTrackingServiceChanged,
    );
    _locationBloc
      ..removeListener(_handleLocationStateChanged)
      ..dispatch(const StopFamilyLocationPollingEvent())
      ..dispose();
    _mapAnimationController
      ..removeListener(_handleMapAnimation)
      ..dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleMembers = _filteredMembers;
    final selectedMember = _resolveSelectedMemberForUi(visibleMembers);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _MapLayer(
                    members: visibleMembers,
                    selectedMember: selectedMember,
                    mapCenter: _initialCenter,
                    mapController: _mapController,
                    onMapReady: _handleMapReady,
                    onSelectMember: (memberName) {
                      _selectMember(memberName);
                    },
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    children: [
                      _TopControls(
                        selected: _selectedFilter,
                        topPadding: widget.showBottomNav ? 14 : 72,
                        onChatTap: () =>
                            Navigator.pushNamed(context, _chatRouteName),
                        onChanged: (filter) {
                          setState(() {
                            _selectedFilter = filter;
                            _selectedMemberId = null;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) {
                              return;
                            }
                            moveToLocation(
                              _focusTargetForMembers(_filteredMembers),
                            );
                          });
                        },
                      ),
                      const Spacer(),
                      _BottomSheetAndNav(
                        showBottomNav: widget.showBottomNav,
                        homeRouteName: widget.homeRouteName,
                        trackingRouteName: widget.trackingRouteName,
                        notificationsRouteName: widget.notificationsRouteName,
                        settingsRouteName: widget.settingsRouteName,
                        thirdTab: widget.thirdTab,
                        selectedMember: selectedMember,
                        onViewDetails: selectedMember == null
                            ? null
                            : () => _openMemberDetails(selectedMember),
                        onCallTap: selectedMember == null
                            ? null
                            : () => _openCallOptions(selectedMember),
                        onChatTap: selectedMember == null
                            ? null
                            : () => _openMemberChat(selectedMember),
                      ),
                    ],
                  ),
                ),
                if (!widget.showBottomNav)
                  Positioned(
                    left: 14,
                    top: 14,
                    child: _StandaloneBackButton(
                      onTap: () => Navigator.maybePop(context),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _MapMember _resolveSelectedMember(List<_MapMember> visibleMembers) {
    if (visibleMembers.isEmpty) {
      return _members.first;
    }
    if (_selectedMemberId == null) {
      return visibleMembers.first;
    }
    for (final member in visibleMembers) {
      if (member.id == _selectedMemberId) {
        return member;
      }
    }
    return visibleMembers.first;
  }

  _MapMember? _resolveSelectedMemberForUi(List<_MapMember> visibleMembers) {
    if (visibleMembers.isEmpty || _selectedMemberId == null) {
      return null;
    }

    for (final member in visibleMembers) {
      if (member.id == _selectedMemberId) {
        return member;
      }
    }

    return null;
  }

  void _selectMember(String memberName) {
    final member = _members.firstWhere((item) => item.name == memberName);
    setState(() => _selectedMemberId = member.id);
    if (member.hasLocation) {
      moveToLocation(member.location);
    }
  }

  void _handleMapReady() {
    _isMapReady = true;
    final selectedMember = _resolveSelectedMemberForUi(_filteredMembers);
    if (selectedMember != null && selectedMember.hasLocation) {
      moveToLocation(selectedMember.location);
    }
  }

  void moveToLocation(LatLng target) {
    if (!_isMapReady) {
      return;
    }

    _mapAnimationController.stop();
    _centerTween = _LatLngTween(
      begin: _mapController.camera.center,
      end: target,
    );
    _zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: _mapController.camera.zoom < _initialZoom
          ? _initialZoom
          : _mapController.camera.zoom,
    );
    _mapAnimationController.forward(from: 0);
  }

  LatLng _focusTargetForMembers(List<_MapMember> members) {
    final locatedMembers = members
        .where((member) => member.hasLocation)
        .toList();
    if (locatedMembers.isEmpty) {
      return _initialCenter;
    }
    if (locatedMembers.length == 1) {
      return locatedMembers.first.location;
    }

    var latitude = 0.0;
    var longitude = 0.0;
    for (final member in locatedMembers) {
      latitude += member.location.latitude;
      longitude += member.location.longitude;
    }

    return LatLng(
      latitude / locatedMembers.length,
      longitude / locatedMembers.length,
    );
  }

  void _handleMapAnimation() {
    if (!_isMapReady || _centerTween == null || _zoomTween == null) {
      return;
    }

    final animationValue = Curves.easeInOutCubic.transform(
      _mapAnimationController.value,
    );

    _mapController.move(
      _centerTween!.transform(animationValue),
      _zoomTween!.transform(animationValue),
      id: 'family-member-focus',
    );
  }

  void _handleLocationStateChanged() {
    if (!mounted) {
      return;
    }

    final hasSelectedMember =
        _selectedMemberId != null &&
        _members.any((member) => member.id == _selectedMemberId);

    setState(() {
      if (!hasSelectedMember) {
        _selectedMemberId = null;
      }
    });
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final session = await AppDependencies.instance.authLocalDataSource
          .getSavedSession();
      if (!mounted) {
        return;
      }
      setState(() {
        _currentProfile = session?.profile;
      });
    } catch (_) {
      // Leave self marker unnamed rather than breaking the map.
    }
  }

  void _handleTrackingServiceChanged() {
    final service = AppDependencies.instance.locationTrackingService;
    final latestLocation = service.lastLocation;
    if (latestLocation == null) {
      return;
    }

    final hasChanged =
        _lastSyncedOwnLocation?.updatedAt != latestLocation.updatedAt ||
        _lastSyncedOwnLocation?.latitude != latestLocation.latitude ||
        _lastSyncedOwnLocation?.longitude != latestLocation.longitude;

    if (!hasChanged) {
      return;
    }

    _lastSyncedOwnLocation = latestLocation;
    _locationBloc.dispatch(const LoadMyLocationEvent());
    _locationBloc.dispatch(const LoadFamilyLocationsEvent(showLoader: false));
    if (mounted) {
      setState(() {});
    }
  }

  _MapMember _mapMemberFromLocation(
    UserLocation location,
    UserLocation? myLocation,
  ) {
    final hasLocation = location.hasLocation;
    final latLng = hasLocation
        ? LatLng(location.latitude!, location.longitude!)
        : _initialCenter;

    return _MapMember(
      id: location.uid,
      name: _displayName(location),
      role: _mapRole(location.userType, location.role),
      battery: 82,
      subtitle:
          location.formattedAddress ??
          location.coordinateLabel ??
          'Vi tri chua cap nhat',
      distanceLabel: _formatDistanceFromMe(location, myLocation),
      lastUpdatedLabel: _formatUpdatedAt(location.updatedAt),
      activityIcon: _activityIconFor(location.speed),
      markerBorderColor: _markerColorFor(location.userType, location.role),
      location: latLng,
      routeHistory: hasLocation ? <LatLng>[latLng] : const <LatLng>[],
      avatarUrl: _avatarUrlFor(location.avata),
      hasLocation: hasLocation,
    );
  }

  _MapMember? _buildSelfMember(UserLocation? location) {
    final profile = _currentProfile;
    if (profile == null || location == null) {
      return null;
    }

    return _mapMemberFromLocation(
      location.copyWith(
        uid: profile.uid,
        name: profile.name,
        role: profile.role,
        userType: profile.userType ?? _userTypeFromHomeType(profile.homeType),
        email: profile.email,
        phone: profile.phone,
        avata: profile.avata,
      ),
      location,
    );
  }

  String _displayName(UserLocation location) {
    final name = location.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final email = location.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return 'Thanh vien';
  }

  _MemberFilter _mapRole(String? userType, String? role) {
    switch (userType) {
      case 'nguoi_lon':
        return _MemberFilter.adults;
      case 'nguoi_gia':
        return _MemberFilter.seniors;
      case 'tre_em':
        return _MemberFilter.children;
    }

    if (role == 'nguoichamsoc') {
      return _MemberFilter.adults;
    }
    return _MemberFilter.children;
  }

  IconData _activityIconFor(double? speed) {
    if (speed != null && speed >= 6) {
      return Icons.drive_eta_rounded;
    }
    if (speed != null && speed >= 1.5) {
      return Icons.directions_walk;
    }
    return Icons.location_on_outlined;
  }

  String? _userTypeFromHomeType(String? homeType) {
    switch (homeType) {
      case 'adult':
        return 'nguoi_lon';
      case 'elderly':
        return 'nguoi_gia';
      case 'child':
        return 'tre_em';
    }
    return null;
  }

  Color _markerColorFor(String? userType, String? role) {
    switch (userType) {
      case 'nguoi_lon':
        return const Color(0xFF17E8E8);
      case 'nguoi_gia':
        return const Color(0xFF34D399);
      case 'tre_em':
        return const Color(0xFF60A5FA);
    }

    if (role == 'nguoichamsoc') {
      return const Color(0xFF17E8E8);
    }
    if (role == 'nguoiduocchamsoc') {
      return const Color(0xFF60A5FA);
    }
    return const Color(0xFF94A3B8);
  }

  String _avatarUrlFor(String? avatarUrl) {
    final trimmed = avatarUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _fallbackAvatarUrl;
    }
    return trimmed;
  }

  String _formatUpdatedAt(DateTime? updatedAt) {
    if (updatedAt == null) {
      return 'Chua cap nhat';
    }

    final localTime = updatedAt.toLocal();
    final difference = DateTime.now().difference(localTime);

    if (difference.inSeconds < 60) {
      return 'Vua cap nhat';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phut truoc';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} gio truoc';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} ngay truoc';
    }

    final day = localTime.day.toString().padLeft(2, '0');
    final month = localTime.month.toString().padLeft(2, '0');
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  String _formatDistanceFromMe(
    UserLocation location,
    UserLocation? myLocation,
  ) {
    if (!location.hasLocation ||
        myLocation == null ||
        !myLocation.hasLocation) {
      return 'Chua xac dinh';
    }

    final distance = const Distance().as(
      LengthUnit.Meter,
      LatLng(myLocation.latitude!, myLocation.longitude!),
      LatLng(location.latitude!, location.longitude!),
    );

    if (distance < 1000) {
      return '${distance.round()} m';
    }

    final kilometers = distance / 1000;
    final formatted = kilometers >= 10
        ? kilometers.toStringAsFixed(0)
        : kilometers.toStringAsFixed(1);
    return '$formatted km';
  }

  void _openMemberDetails(_MapMember member) {
    if (member.role == _MemberFilter.children) {
      Navigator.pushNamed(context, AppRoutes.kidManagement);
      return;
    }

    if (member.role == _MemberFilter.adults) {
      Navigator.pushNamed(
        context,
        AppRoutes.adultMemberDetail,
        arguments: _buildMemberTrackingArgs(member),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.seniorMemberDetail,
      arguments: _buildMemberTrackingArgs(member),
    );
  }

  void _openCallOptions(_MapMember member) {
    showRoleCallOptionsSheet(
      context,
      target: CallTargetArgs(
        name: member.name,
        avatarUrl: member.avatarUrl,
        role: switch (member.role) {
          _MemberFilter.children => MemberRole.child,
          _MemberFilter.adults => MemberRole.adult,
          _MemberFilter.seniors => MemberRole.senior,
          _MemberFilter.all => MemberRole.child,
        },
      ),
    );
  }

  void _openMemberChat(_MapMember member) {
    final normalizedName = member.name.toLowerCase();
    final thread = ChatThreadArgs.demoThreads.firstWhere(
      (item) => item.memberName.toLowerCase() == normalizedName,
      orElse: () => ChatThreadArgs.fallback,
    );
    Navigator.pushNamed(context, AppRoutes.chatConversation, arguments: thread);
  }

  MemberTrackingArgs _buildMemberTrackingArgs(_MapMember member) {
    final isAdult = member.role == _MemberFilter.adults;
    return MemberTrackingArgs(
      role: isAdult ? MemberRole.adult : MemberRole.senior,
      name: member.name,
      status: member.subtitle,
      avatarUrl: member.avatarUrl,
      phoneNumber: '+1 (555) 0123',
      relationship: isAdult ? 'Chồng' : 'Mẹ',
      battery: member.battery,
      connectionStatus: 'Trực tuyến',
      deviceName: 'iPhone 13',
      lastActive: '2 phút trước',
      timeLabel: '08:42 AM',
      mapCenter: member.location,
      routeHistory: member.routeHistory,
      playbackStartLabel: '08:00 AM',
      playbackEndLabel: '04:30 PM',
      totalDistanceLabel: isAdult ? '3.2 km' : '2.4 km',
      totalDurationLabel: isAdult ? '2h 15m' : '1h 40m',
      stopCount: isAdult ? 1 : 2,
      averageSpeedLabel: isAdult ? '2.8 km/h' : '1.9 km/h',
      timelineItems: isAdult
          ? const [
              TrackingTimelineItem(timeLabel: '08:00 AM', title: 'Nhà'),
              TrackingTimelineItem(timeLabel: '08:30 AM', title: 'Đến trường'),
              TrackingTimelineItem(
                timeLabel: '08:35 AM',
                title: 'Rời khỏi trường',
              ),
              TrackingTimelineItem(
                timeLabel: '12:35 PM',
                title: 'Ở văn phòng',
                highlighted: true,
              ),
              TrackingTimelineItem(timeLabel: '01:00 PM', title: 'Lái xe'),
            ]
          : const [
              TrackingTimelineItem(timeLabel: '08:00 AM', title: 'Nhà'),
              TrackingTimelineItem(
                timeLabel: '09:15 AM',
                title: 'Công viên gần nhà',
              ),
              TrackingTimelineItem(
                timeLabel: '10:00 AM',
                title: 'Quán tạp hóa',
              ),
              TrackingTimelineItem(
                timeLabel: '12:35 PM',
                title: 'Ở nhà',
                highlighted: true,
              ),
              TrackingTimelineItem(timeLabel: '01:00 PM', title: 'Nghỉ ngơi'),
            ],
    );
  }
}

class _MapLayer extends StatelessWidget {
  const _MapLayer({
    required this.members,
    required this.selectedMember,
    required this.mapCenter,
    required this.mapController,
    required this.onMapReady,
    required this.onSelectMember,
  });

  final List<_MapMember> members;
  final _MapMember? selectedMember;
  final LatLng mapCenter;
  final MapController mapController;
  final VoidCallback onMapReady;
  final ValueChanged<String> onSelectMember;

  @override
  Widget build(BuildContext context) {
    final membersWithLocation = members
        .where((member) => member.hasLocation)
        .toList(growable: false);

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: _FamilyMapScreenState._initialZoom,
              minZoom: 3,
              maxZoom: 18,
              onMapReady: onMapReady,
              onTap: (_, point) {},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.familyguard.app',
              ),
              if (selectedMember != null &&
                  selectedMember!.hasLocation &&
                  selectedMember!.routeHistory.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: selectedMember!.routeHistory,
                      color: const Color(0xFF01ADB2),
                      strokeWidth: 4,
                      borderColor: Colors.white.withValues(alpha: 0.85),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: membersWithLocation
                    .map(
                      (member) => Marker(
                        point: member.location,
                        width: 112,
                        height: 110,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => onSelectMember(member.name),
                          child: _MemberMarker(
                            name: member.name,
                            avatarUrl: member.avatarUrl,
                            borderColor: member.markerBorderColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        Positioned(
          right: 14,
          bottom: selectedMember != null ? 286 : 112,
          child: Column(
            children: [
              _MapActionButton(icon: Icons.gps_fixed, onTap: () {}),
              const SizedBox(height: 10),
              _MapActionButton(icon: Icons.layers_outlined, onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

enum _MemberFilter { all, children, adults, seniors }

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.selected,
    required this.onChanged,
    required this.onChatTap,
    this.topPadding = 14,
  });

  final _MemberFilter selected;
  final ValueChanged<_MemberFilter> onChanged;
  final VoidCallback onChatTap;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, topPadding, 14, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Tất cả',
                    selected: selected == _MemberFilter.all,
                    onTap: () => onChanged(_MemberFilter.all),
                  ),
                  _FilterPill(
                    label: 'Trẻ em',
                    selected: selected == _MemberFilter.children,
                    onTap: () => onChanged(_MemberFilter.children),
                  ),
                  _FilterPill(
                    label: 'Ng.Lớn',
                    selected: selected == _MemberFilter.adults,
                    onTap: () => onChanged(_MemberFilter.adults),
                  ),
                  _FilterPill(
                    label: 'Ng.Già',
                    selected: selected == _MemberFilter.seniors,
                    onTap: () => onChanged(_MemberFilter.seniors),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onChatTap,
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 21,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF04D1D4) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: selected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberMarker extends StatelessWidget {
  const _MemberMarker({
    required this.name,
    required this.avatarUrl,
    required this.borderColor,
  });

  final String name;
  final String avatarUrl;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 28,
            top: 27,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
                image: DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 84,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF475569)),
      ),
    );
  }
}

class _MapMember {
  const _MapMember({
    required this.id,
    required this.name,
    required this.role,
    required this.battery,
    required this.subtitle,
    required this.distanceLabel,
    required this.activityIcon,
    required this.markerBorderColor,
    required this.location,
    required this.routeHistory,
    required this.avatarUrl,
    required this.lastUpdatedLabel,
    required this.hasLocation,
  });

  final String id;
  final String name;
  final _MemberFilter role;
  final int battery;
  final String subtitle;
  final String distanceLabel;
  final IconData activityIcon;
  final Color markerBorderColor;
  final LatLng location;
  final List<LatLng> routeHistory;
  final String avatarUrl;
  final String lastUpdatedLabel;
  final bool hasLocation;
}

class _BottomSheetAndNav extends StatelessWidget {
  const _BottomSheetAndNav({
    required this.showBottomNav,
    required this.homeRouteName,
    required this.trackingRouteName,
    required this.notificationsRouteName,
    required this.settingsRouteName,
    required this.thirdTab,
    required this.selectedMember,
    required this.onViewDetails,
    required this.onCallTap,
    required this.onChatTap,
  });

  final bool showBottomNav;
  final String homeRouteName;
  final String trackingRouteName;
  final String notificationsRouteName;
  final String settingsRouteName;
  final AppBottomMenuThirdTab thirdTab;
  final _MapMember? selectedMember;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCallTap;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x2600ADB2),
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedMember != null)
            _BottomSheetContent(
              selectedMember: selectedMember!,
              onViewDetails: onViewDetails!,
              onCallTap: onCallTap!,
              onChatTap: onChatTap!,
            ),
          if (showBottomNav)
            Container(
              width: double.infinity,
              color: selectedMember != null
                  ? const Color(0xFFF0F8F7)
                  : Colors.transparent,
              child: AppFlowBottomNav(
                current: AppNavTab.tracking,
                homeRouteName: homeRouteName,
                trackingRouteName: trackingRouteName,
                settingsRouteName: settingsRouteName,
                thirdTab: thirdTab,
                thirdTabRouteName: notificationsRouteName,
              ),
            ),
          if (!showBottomNav) const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _StandaloneBackButton extends StatelessWidget {
  const _StandaloneBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({
    required this.selectedMember,
    required this.onViewDetails,
    required this.onCallTap,
    required this.onChatTap,
  });

  final _MapMember selectedMember;
  final VoidCallback onViewDetails;
  final VoidCallback onCallTap;
  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _selectedAvatar(
                  selectedMember.avatarUrl,
                  selectedMember.activityIcon,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedMember.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _twoLineSubtitle(selectedMember.subtitle),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.battery_charging_full,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${selectedMember.battery}%',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF334155),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: onViewDetails,
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  backgroundColor: const Color(0xFF01ADB2),
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  textStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('Xem chi tiết'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _circleIconButton(
                            Icons.call_outlined,
                            onTap: onCallTap,
                          ),
                          const SizedBox(width: 8),
                          _circleIconButton(
                            Icons.chat_bubble_outline,
                            onTap: onChatTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatChip(
                    title: 'Lần cuối cập nhật',
                    value: selectedMember.lastUpdatedLabel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatChip(
                    title: 'Khoảng cách',
                    value: selectedMember.distanceLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _twoLineSubtitle(String subtitle) {
    if (subtitle.length <= 23) {
      return subtitle;
    }
    final splitAt = subtitle.lastIndexOf(' ', 23);
    if (splitAt <= 0 || splitAt >= subtitle.length - 1) {
      return subtitle;
    }
    return '${subtitle.substring(0, splitAt)}\n${subtitle.substring(splitAt + 1)}';
  }

  Widget _selectedAvatar(String avatarUrl, IconData activityIcon) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF17E8E8),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.network(avatarUrl, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: -3,
          bottom: -3,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(activityIcon, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF475569)),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      color: Colors.white.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3300ADB2),
                blurRadius: 30,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _NavItem(icon: Icons.groups_outlined),
              _NavItem(icon: Icons.map, selected: true),
              _NavItem(icon: Icons.notifications_none),
              _NavItem(icon: Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, this.selected = false});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF00ACB1) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x6600ADB2),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 24,
        color: selected ? const Color(0xFF002244) : const Color(0xFF9CA3AF),
      ),
    );
  }
}

class _LatLngTween extends Tween<LatLng> {
  _LatLngTween({required super.begin, required super.end});

  @override
  LatLng lerp(double t) {
    final begin = this.begin!;
    final end = this.end!;

    return LatLng(
      begin.latitude + (end.latitude - begin.latitude) * t,
      begin.longitude + (end.longitude - begin.longitude) * t,
    );
  }
}
