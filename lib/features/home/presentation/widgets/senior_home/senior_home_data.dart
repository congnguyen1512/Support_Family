import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';

class SeniorHomePalette {
  const SeniorHomePalette._();

  static const background = Color(0xFFF1FBFA);
  static const surface = Colors.white;
  static const primary = Color(0xFF06A8AE);
  static const primaryDark = Color(0xFF0B6E73);
  static const primarySoft = Color(0xFFDDF8F5);
  static const text = Color(0xFF102325);
  static const muted = Color(0xFF6C8588);
  static const danger = Color(0xFFE85C63);
  static const warning = Color(0xFFF4A53A);
  static const success = Color(0xFF23B273);
  static const cardShadow = Color(0x1400ACB2);
}

class SeniorHomeProfile {
  const SeniorHomeProfile({
    required this.name,
    required this.nickname,
    required this.status,
    required this.address,
    required this.lastUpdated,
    required this.battery,
    required this.heartRate,
    required this.steps,
  });

  final String name;
  final String nickname;
  final String status;
  final String address;
  final String lastUpdated;
  final String battery;
  final String heartRate;
  final String steps;
}

class SeniorHomeStat {
  const SeniorHomeStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.background,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color background;
}

class SeniorQuickAction {
  const SeniorQuickAction({
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

class SeniorFamilyContact {
  const SeniorFamilyContact({
    required this.name,
    required this.relation,
    required this.initial,
    required this.accent,
    required this.callArgs,
  });

  final String name;
  final String relation;
  final String initial;
  final Color accent;
  final InAppCallArgs callArgs;
}

class SeniorScheduleItem {
  const SeniorScheduleItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.icon,
    required this.iconColor,
    required this.accent,
    required this.routeName,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final IconData icon;
  final Color iconColor;
  final Color accent;
  final String routeName;
}

class SeniorHomeMockData {
  const SeniorHomeMockData._();

  static const profile = SeniorHomeProfile(
    name: 'L\u00EA Th\u1ECB Hoa',
    nickname: 'B\u00E0 n\u1ED9i',
    status: '\u0110ang an to\u00E0n t\u1EA1i nh\u00E0',
    address: 'Riverside Residence, Qu\u1EADn 7',
    lastUpdated: 'C\u1EADp nh\u1EADt 1 ph\u00FAt tr\u01B0\u1EDBc',
    battery: '76%',
    heartRate: '72 bpm',
    steps: '3.460 b\u01B0\u1EDBc',
  );

  static const stats = [
    SeniorHomeStat(
      title: 'An to\u00E0n',
      value: '\u1ED4n \u0111\u1ECBnh',
      icon: Icons.verified_user_rounded,
      iconColor: SeniorHomePalette.success,
      background: Color(0xFFE9F8F0),
    ),
    SeniorHomeStat(
      title: 'U\u1ED1ng thu\u1ED1c',
      value: '19:00',
      icon: Icons.medication_rounded,
      iconColor: SeniorHomePalette.warning,
      background: Color(0xFFFFF4E8),
    ),
    SeniorHomeStat(
      title: 'Li\u00EAn l\u1EA1c',
      value: '3 ng\u01B0\u1EDDi',
      icon: Icons.call_rounded,
      iconColor: SeniorHomePalette.primary,
      background: Color(0xFFE9F8F7),
    ),
    SeniorHomeStat(
      title: 'Ngo\u00E0i tr\u1EDDi',
      value: '15 ph\u00FAt',
      icon: Icons.wb_sunny_rounded,
      iconColor: Color(0xFFF28B30),
      background: Color(0xFFFFF5E8),
    ),
  ];

  static const quickActions = [
    SeniorQuickAction(
      title: 'SOS kh\u1EA9n',
      subtitle: 'B\u00E1o ngay cho gia \u0111\u00ECnh',
      icon: Icons.sos_rounded,
      color: SeniorHomePalette.danger,
      isPrimary: true,
    ),
    SeniorQuickAction(
      title: 'G\u1ECDi ng\u01B0\u1EDDi th\u00E2n',
      subtitle: 'M\u1EDF li\u00EAn h\u1EC7 nhanh',
      icon: Icons.call_rounded,
      color: SeniorHomePalette.primary,
      routeName: AppRoutes.priorityContacts,
    ),
    SeniorQuickAction(
      title: 'Nh\u1EAFc nh\u1EDF',
      subtitle: 'Thu\u1ED1c v\u00E0 l\u1ECBch h\u1EB9n',
      icon: Icons.alarm_rounded,
      color: SeniorHomePalette.warning,
      routeName: AppRoutes.reminderManagement,
    ),
    SeniorQuickAction(
      title: 'V\u00F9ng an to\u00E0n',
      subtitle: 'Ki\u1EC3m tra khu v\u1EF1c',
      icon: Icons.shield_rounded,
      color: Color(0xFF5B7CFA),
      routeName: AppRoutes.safeZone,
    ),
    SeniorQuickAction(
      title: 'Kh\u00E1m b\u1EC7nh',
      subtitle: 'L\u1ECBch kh\u00E1m g\u1EA7n nh\u1EA5t',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF8D5CF6),
      routeName: AppRoutes.medicalAppointment,
    ),
    SeniorQuickAction(
      title: 'Tin nh\u1EAFn',
      subtitle: 'N\u00F3i chuy\u1EC7n v\u1EDBi con ch\u00E1u',
      icon: Icons.chat_bubble_rounded,
      color: Color(0xFF2E9BFF),
      routeName: AppRoutes.chatList,
    ),
  ];

  static const familyContacts = [
    SeniorFamilyContact(
      name: 'Ba Minh',
      relation: 'Con trai',
      initial: 'M',
      accent: Color(0xFFE4F7F4),
      callArgs: InAppCallArgs(
        name: 'Nguy\u1EC5n V\u0103n Minh',
        avatarUrl:
            'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=400&auto=format&fit=crop',
        role: MemberRole.adult,
      ),
    ),
    SeniorFamilyContact(
      name: 'M\u1EB9 Lan',
      relation: 'Con d\u00E2u',
      initial: 'L',
      accent: Color(0xFFFFE9E0),
      callArgs: InAppCallArgs(
        name: 'Tr\u1EA7n Th\u1ECB Lan',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
        role: MemberRole.adult,
      ),
    ),
    SeniorFamilyContact(
      name: 'An',
      relation: 'Ch\u00E1u n\u1ED9i',
      initial: 'A',
      accent: Color(0xFFE7F0FF),
      callArgs: InAppCallArgs(
        name: 'Nguy\u1EC5n Minh An',
        avatarUrl:
            'https://images.unsplash.com/photo-1628157588553-5eeea00af15c?q=80&w=400&auto=format&fit=crop',
        role: MemberRole.child,
      ),
    ),
  ];

  static const schedule = [
    SeniorScheduleItem(
      title: 'Thu\u1ED1c huy\u1EBFt \u00E1p',
      subtitle: 'U\u1ED1ng sau b\u1EEFa t\u1ED1i',
      timeLabel: '19:00',
      icon: Icons.medication_rounded,
      iconColor: SeniorHomePalette.warning,
      accent: Color(0xFFFFF1E6),
      routeName: AppRoutes.reminderManagement,
    ),
    SeniorScheduleItem(
      title: '\u0110i b\u1ED9 nh\u1EB9',
      subtitle: '15 ph\u00FAt quanh h\u00E0nh lang',
      timeLabel: '17:30',
      icon: Icons.directions_walk_rounded,
      iconColor: SeniorHomePalette.success,
      accent: Color(0xFFE8F8F2),
      routeName: AppRoutes.physicalActivity,
    ),
    SeniorScheduleItem(
      title: '\u0110o huy\u1EBFt \u00E1p',
      subtitle: 'Ki\u1EC3m tra l\u1EA1i tr\u01B0\u1EDBc khi ng\u1EE7',
      timeLabel: '21:00',
      icon: Icons.favorite_rounded,
      iconColor: SeniorHomePalette.danger,
      accent: Color(0xFFFFE8EC),
      routeName: AppRoutes.medicalAppointment,
    ),
  ];
}
