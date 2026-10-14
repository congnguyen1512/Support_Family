import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/core/services/kid_reminder_notification_scheduler.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/checkin_reminder/presentation/screens/checkin_reminder_kid_reminder_screen.dart';
import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChildHomePage extends StatefulWidget {
  const ChildHomePage({super.key});

  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  late final Future<List<_ChildMission>> _missionsFuture;
  late final Future<_ChildHeroData> _heroFuture;

  static const _bg = Color(0xFFF5FBFF);
  static const _surface = Colors.white;
  static const _blue = Color(0xFF1FA5FF);
  static const _blueDark = Color(0xFF0E5F9A);
  static const _cyan = Color(0xFF12C4C0);
  static const _yellow = Color(0xFFFFC94A);
  static const _pink = Color(0xFFFF7FA5);
  static const _green = Color(0xFF27C383);
  static const _text = Color(0xFF172B4D);
  static const _muted = Color(0xFF6E7E96);
  static const _danger = Color(0xFFFF5E6A);

  static const _contactAccents = [
    Color(0xFFFFE8E0),
    Color(0xFFE3F4FF),
    Color(0xFFEAF8F1),
    Color(0xFFFFF1D6),
  ];

  static const _actions = [
    _ChildAction(
      title: 'SOS',
      subtitle: 'G\u1ECDi ngay cho gia \u0111\u00ECnh',
      icon: Icons.sos_rounded,
      color: _danger,
      isPrimary: true,
    ),
    _ChildAction(
      title: 'Chat nh\u00F3m',
      subtitle: 'N\u00F3i chuy\u1EC7n v\u1EDBi c\u1EA3 nh\u00E0',
      icon: Icons.chat_bubble_rounded,
      color: _blue,
      routeName: AppRoutes.kidChatList,
    ),
    _ChildAction(
      title: 'B\u1EA3n \u0111\u1ED3',
      subtitle: 'Xem v\u1ECB tr\u00ED h\u00F4m nay',
      icon: Icons.map_rounded,
      color: _cyan,
      routeName: AppRoutes.kidLocation,
    ),
    _ChildAction(
      title: 'Nh\u1EAFc nh\u1EDF',
      subtitle: 'Xem nh\u1EAFc nh\u1EDF t\u1EEB gia \u0111\u00ECnh',
      icon: Icons.alarm_rounded,
      color: _yellow,
      routeName: AppRoutes.checkinReminderKid,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _missionsFuture = _loadMissions();
    _heroFuture = _loadHeroData();
    _missionsFuture.then(_scheduleReminderNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _KidBackground()),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 128),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context),
                    const SizedBox(height: 20),
                    _buildTodayCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('\u0110i\u1EC1u khi\u1EC3n nhanh'),
                    const SizedBox(height: 12),
                    _buildActionsGrid(context),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      'Ng\u01B0\u1EDDi th\u00E2n c\u1EE7a b\u1EA1n',
                    ),
                    const SizedBox(height: 12),
                    _buildContacts(context),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Nhi\u1EC7m v\u1EE5 h\u00F4m nay'),
                    const SizedBox(height: 12),
                    _buildMissions(context),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomMenu(
                current: AppNavTab.home,
                homeRouteName: AppRoutes.kidHome,
                trackingRouteName: AppRoutes.kidLocation,
                settingsRouteName: AppRoutes.kidProfile,
                thirdTab: AppBottomMenuThirdTab.chat,
                thirdTabRouteName: AppRoutes.kidChatList,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return FutureBuilder<_ChildHeroData>(
      future: _heroFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _ChildHeroData.fallback();
        final locationLabel = data.locationLabel;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x141FA5FF),
                blurRadius: 26,
                offset: Offset(0, 10),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFA9E5FF), Color(0xFF5EC8FF)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x331FA5FF),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      data.initial,
                      style: GoogleFonts.lexend(
                        color: _blueDark,
                        fontSize: 30,
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
                          'Xin ch\u00E0o ${data.shortName}',
                          style: GoogleFonts.lexend(
                            color: _blueDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.fullName,
                          style: GoogleFonts.beVietnamPro(
                            color: _muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          locationLabel,
                          style: GoogleFonts.beVietnamPro(
                            color: _text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HeroRoundAction(
                    icon: Icons.chat_bubble_rounded,
                    color: _blue,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.kidChatList),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF28B0FF), Color(0xFF0E8DE2)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationLabel,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _KidMetric(
                            label: 'Pin',
                            value: '18%',
                            icon: Icons.battery_3_bar_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _KidMetric(
                            label: 'V\u00F9ng hi\u1EC7n t\u1EA1i',
                            value: data.placeLabel,
                            icon: Icons.place_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _KidMetric(
                            label: 'Gia \u0111\u00ECnh',
                            value: '${data.familyCount} online',
                            icon: Icons.groups_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.kidLocation),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFE6F6FF),
                        foregroundColor: _blueDark,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.map_rounded),
                      label: Text(
                        'Xem b\u1EA3n \u0111\u1ED3',
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showSosSheet(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFFFECEE),
                        foregroundColor: _danger,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.sos_rounded),
                      label: Text(
                        'SOS',
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayCard() {
    return FutureBuilder<List<_ChildMission>>(
      future: _missionsFuture,
      builder: (context, snapshot) {
        final missions = snapshot.data ?? const <_ChildMission>[];
        final chips = missions.take(3).map(_StatusChip.fromMission).toList();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1212C4C0),
                blurRadius: 20,
                offset: Offset(0, 8),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6FFFD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.verified_rounded, color: _cyan),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'H\u00F4m nay b\u1EA1n \u0111ang an to\u00E0n',
                          style: GoogleFonts.lexend(
                            color: _text,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          missions.isEmpty
                              ? 'Gia \u0111\u00ECnh \u0111\u00E3 nh\u1EADn \u0111\u01B0\u1EE3c v\u1ECB tr\u00ED c\u1EE7a b\u1EA1n.'
                              : 'B\u1EA1n c\u00F3 ${missions.length} nh\u1EAFc nh\u1EDF trong h\u00F4m nay.',
                          style: GoogleFonts.beVietnamPro(
                            color: _muted,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (chips.isNotEmpty)
                Wrap(spacing: 10, runSpacing: 10, children: chips),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];
        return InkWell(
          onTap: () => _handleActionTap(context, action),
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: action.isPrimary ? const Color(0xFFFFF2F4) : _surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: action.isPrimary
                    ? const Color(0xFFFFD4D9)
                    : const Color(0x141FA5FF),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x121FA5FF),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                  spreadRadius: -12,
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
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
                    style: GoogleFonts.beVietnamPro(
                      color: _muted,
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
    );
  }

  Widget _buildContacts(BuildContext context) {
    return FutureBuilder<List<_ChildContact>>(
      future: _loadContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final contacts = snapshot.data ?? const <_ChildContact>[];
        if (contacts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              'Ch\u01B0a c\u00F3 ng\u01B0\u1EDDi th\u00E2n \u0111\u00E3 x\u00E1c nh\u1EADn.',
              style: GoogleFonts.beVietnamPro(color: _muted, fontSize: 14),
            ),
          );
        }

        return Column(
          children: contacts.map((contact) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x121FA5FF),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: -12,
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
                          color: _blueDark,
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
                              color: _text,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            contact.relation,
                            style: GoogleFonts.beVietnamPro(
                              color: _muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _MiniButton(
                      icon: Icons.chat_bubble_rounded,
                      color: _blue,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.kidChatConversation,
                        arguments: contact.chatThreadId,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MiniButton(
                      icon: Icons.call_rounded,
                      color: _green,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.inAppCall,
                        arguments: contact.callArgs,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMissions(BuildContext context) {
    return FutureBuilder<List<_ChildMission>>(
      future: _missionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _MissionMessageCard(
            message:
                'Kh\u00F4ng th\u1EC3 t\u1EA3i nh\u1EAFc nh\u1EDF h\u00F4m nay.',
          );
        }

        final missions = snapshot.data ?? const <_ChildMission>[];
        if (missions.isEmpty) {
          return _MissionMessageCard(
            message:
                'H\u00F4m nay b\u1EA1n ch\u01B0a c\u00F3 nh\u1EAFc nh\u1EDF.',
          );
        }

        return Column(
          children: missions.map((mission) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _openKidReminder(context),
                borderRadius: BorderRadius.circular(24),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x121FA5FF),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                        spreadRadius: -12,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: mission.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.flag_rounded, color: mission.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mission.title,
                              style: GoogleFonts.lexend(
                                color: _text,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mission.subtitle,
                              style: GoogleFonts.beVietnamPro(
                                color: _muted,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: mission.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          mission.badge,
                          style: GoogleFonts.lexend(
                            color: mission.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  static Future<List<_ChildMission>> _loadMissions() async {
    final session = await AppDependencies.instance.authLocalDataSource
        .getSavedSession();
    final memberId = session?.userId.trim() ?? '';
    if (memberId.isEmpty) {
      return const <_ChildMission>[];
    }

    final data = await AppDependencies.instance.apiClient.get(
      ApiEndpoints.kidReminders,
      queryParameters: {'member_uid': memberId},
    );

    if (data is! List) {
      return const <_ChildMission>[];
    }

    final missions =
        data
            .map(_ChildMission.fromJson)
            .whereType<_ChildMission>()
            .where((mission) => mission.isActive)
            .toList()
          ..sort((a, b) => a.sortTime.compareTo(b.sortTime));

    return missions;
  }

  static Future<_ChildHeroData> _loadHeroData() async {
    final session = await AppDependencies.instance.authLocalDataSource
        .getSavedSession();
    final fullName = _resolveName(
      session?.profile.name,
      session?.profile.email,
    );
    final location = await AppDependencies.instance.getMyLocationUseCase();
    final contacts = await _loadContacts();

    return _ChildHeroData(
      fullName: fullName,
      shortName: _shortName(fullName),
      initial: _initialFromName(fullName),
      location: location,
      familyCount: contacts.length,
    );
  }

  static void _scheduleReminderNotifications(List<_ChildMission> missions) {
    final notifications = missions
        .map(
          (mission) => KidReminderNotification(
            id: mission.id,
            title: mission.title,
            reminderTime: mission.sortTime,
          ),
        )
        .toList();
    KidReminderNotificationScheduler.instance.scheduleToday(notifications);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lexend(
        color: _blueDark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static Future<void> _handleActionTap(
    BuildContext context,
    _ChildAction action,
  ) async {
    if (action.isPrimary) {
      _showSosSheet(context);
      return;
    }
    if (action.routeName == AppRoutes.checkinReminderKid) {
      await _openKidReminder(context);
      return;
    }
    if (action.routeName != null) {
      Navigator.pushNamed(context, action.routeName!);
    }
  }

  static Future<void> _openKidReminder(BuildContext context) async {
    final session = await AppDependencies.instance.authLocalDataSource
        .getSavedSession();
    if (!context.mounted || session == null) {
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.checkinReminderKid,
      arguments: CheckinReminderKidReminderArgs(
        memberId: session.userId,
        memberName: _resolveName(session.profile.name, session.profile.email),
        avatarUrl: session.profile.avata ?? '',
      ),
    );
  }

  static void _showSosSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: FutureBuilder<List<_ChildContact>>(
            future: _loadContacts(),
            builder: (context, snapshot) {
              final contacts = snapshot.data ?? const <_ChildContact>[];
              final callableContacts = contacts.take(2).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EDF4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'SOS kh\u1EA9n c\u1EA5p',
                    style: GoogleFonts.lexend(
                      color: _text,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'B\u1EA1n c\u00F3 th\u1EC3 g\u1ECDi ng\u01B0\u1EDDi th\u00E2n \u0111\u00E3 x\u00E1c nh\u1EADn ho\u1EB7c m\u1EDF chat gia \u0111\u00ECnh.',
                    style: GoogleFonts.beVietnamPro(
                      color: _muted,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  for (final contact in callableContacts) ...[
                    _BottomActionTile(
                      title: 'G\u1ECDi ${contact.name}',
                      subtitle: contact.relation,
                      icon: Icons.call_rounded,
                      color: _green,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.inAppCall,
                          arguments: contact.callArgs,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  _BottomActionTile(
                    title: 'M\u1EDF chat gia \u0111\u00ECnh',
                    subtitle: 'G\u1EEDi tin nh\u1EAFn cho c\u1EA3 nh\u00E0',
                    icon: Icons.chat_bubble_rounded,
                    color: _pink,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.kidChatList);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static Future<List<_ChildContact>> _loadContacts() async {
    final relationships = await AppDependencies.instance
        .getRelationshipsUseCase();
    final confirmed = relationships.where((item) {
      return item.processing.trim().toLowerCase() == 'xacnhan' &&
          item.relationId.trim().isNotEmpty;
    }).toList();

    return confirmed.asMap().entries.map((entry) {
      final index = entry.key;
      final relation = entry.value;
      final user = relation.relationUser;
      final name = _resolveName(user?.name, user?.email);

      return _ChildContact(
        name: name,
        relation: _displayRelation(relation.relationType),
        initial: _initialFromName(name),
        accent: _contactAccents[index % _contactAccents.length],
        chatThreadId: relation.relationId.trim(),
        callArgs: InAppCallArgs(
          name: name,
          avatarUrl: user?.avata ?? '',
          role: _resolveRole(user?.birthday, user?.role),
        ),
      );
    }).toList();
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

    return 'Ng\u01B0\u1EDDi th\u00E2n';
  }

  static String _initialFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'N';
    }
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  static String _shortName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return name;
    }
    return parts.last;
  }

  static String _displayRelation(String relation) {
    final trimmed = relation.trim();
    if (trimmed.isEmpty) {
      return 'Ng\u01B0\u1EDDi th\u00E2n';
    }

    final normalized = trimmed.toLowerCase();
    switch (normalized) {
      case 'cha':
      case 'bo':
      case 'b\u1ED1':
        return 'B\u1ED1';
      case 'me':
      case 'm\u1EB9':
        return 'M\u1EB9';
      case 'ong':
      case '\u00F4ng':
        return '\u00D4ng';
      case 'ba':
      case 'b\u00E0':
        return 'B\u00E0';
      case 'con':
        return 'Con';
      case 'vo':
      case 'v\u1EE3':
        return 'V\u1EE3';
      case 'chong':
      case 'ch\u1ED3ng':
        return 'Ch\u1ED3ng';
      case 'anh':
        return 'Anh';
      case 'chi':
      case 'ch\u1ECB':
        return 'Ch\u1ECB';
      case 'em':
        return 'Em';
      case 'chau':
      case 'ch\u00E1u':
        return 'Ch\u00E1u';
    }

    if (trimmed.contains('_')) {
      return _displayRelation(trimmed.split('_').last);
    }

    return trimmed;
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

    switch ((rawRole ?? '').trim().toLowerCase()) {
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
    final trimmed = birthday?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final birthDate = DateTime.tryParse(trimmed);
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
}

class _MissionMessageCard extends StatelessWidget {
  const _MissionMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ChildHomePageState._surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x121FA5FF),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Text(
        message,
        style: GoogleFonts.beVietnamPro(
          color: _ChildHomePageState._muted,
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }
}

class _KidBackground extends StatelessWidget {
  const _KidBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD8F4FF).withValues(alpha: 0.9),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -70,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9FFF7).withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroRoundAction extends StatelessWidget {
  const _HeroRoundAction({
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
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _KidMetric extends StatelessWidget {
  const _KidMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.color,
  });

  factory _StatusChip.fromMission(_ChildMission mission) {
    return _StatusChip(
      icon: Icons.schedule_rounded,
      label: '${mission.title} ${mission.sortTime}',
      bgColor: mission.color.withValues(alpha: 0.12),
      color: mission.color,
    );
  }

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.lexend(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
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

class _BottomActionTile extends StatelessWidget {
  const _BottomActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      color: _ChildHomePageState._text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.beVietnamPro(
                      color: _ChildHomePageState._muted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ChildAction {
  const _ChildAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.routeName,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? routeName;
  final bool isPrimary;
}

class _ChildHeroData {
  const _ChildHeroData({
    required this.fullName,
    required this.shortName,
    required this.initial,
    required this.location,
    required this.familyCount,
  });

  final String fullName;
  final String shortName;
  final String initial;
  final UserLocation? location;
  final int familyCount;

  String get locationLabel =>
      location?.formattedAddress ??
      location?.coordinateLabel ??
      'Ch\u01B0a c\u00F3 v\u1ECB tr\u00ED hi\u1EC7n t\u1EA1i';

  String get placeLabel {
    final place = location?.placeName?.trim();
    if (place != null && place.isNotEmpty) {
      return place;
    }
    final district = location?.district?.trim();
    if (district != null && district.isNotEmpty) {
      return district;
    }
    return location?.hasLocation == true
        ? 'Hi\u1EC7n t\u1EA1i'
        : 'Ch\u01B0a c\u00F3';
  }

  factory _ChildHeroData.fallback() {
    return const _ChildHeroData(
      fullName: 'B\u1EA1n',
      shortName: 'b\u1EA1n',
      initial: 'B',
      location: null,
      familyCount: 0,
    );
  }
}

class _ChildMission {
  const _ChildMission({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
    required this.isActive,
    required this.sortTime,
  });

  final int id;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  final bool isActive;
  final String sortTime;

  static _ChildMission? fromJson(dynamic json) {
    if (json is! Map) {
      return null;
    }

    final map = json.cast<String, dynamic>();
    final id = _intFromJson(map['id']);
    final title = (map['title'] ?? '').toString().trim();
    if (id == null || title.isEmpty) {
      return null;
    }

    final reminderTime = (map['reminder_time'] ?? '').toString().trim();
    final isActive = map['is_active'] != false;
    final color = _colorForReminder(title, reminderTime);

    return _ChildMission(
      id: id,
      title: title,
      subtitle: reminderTime.isEmpty
          ? 'Gia \u0111\u00ECnh \u0111\u00E3 \u0111\u1EB7t nh\u1EAFc nh\u1EDF cho b\u1EA1n'
          : 'Nh\u1EAFc l\u00FAc $reminderTime',
      badge: isActive ? 'S\u1EAFp t\u1EDBi' : 'T\u1EA1m t\u1EAFt',
      color: color,
      isActive: isActive,
      sortTime: reminderTime,
    );
  }

  static int? _intFromJson(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static Color _colorForReminder(String title, String reminderTime) {
    final normalized = '$title $reminderTime'.toLowerCase();
    if (normalized.contains('v\u1EC1 nh\u00E0') ||
        normalized.contains('quan tr\u1ECDng')) {
      return _ChildHomePageState._danger;
    }
    if (normalized.contains('pin') ||
        normalized.contains('s\u1EA1c') ||
        normalized.contains('sac')) {
      return _ChildHomePageState._yellow;
    }
    return _ChildHomePageState._blue;
  }
}

class _ChildContact {
  const _ChildContact({
    required this.name,
    required this.relation,
    required this.initial,
    required this.accent,
    required this.chatThreadId,
    required this.callArgs,
  });

  final String name;
  final String relation;
  final String initial;
  final Color accent;
  final String chatThreadId;
  final InAppCallArgs callArgs;
}
