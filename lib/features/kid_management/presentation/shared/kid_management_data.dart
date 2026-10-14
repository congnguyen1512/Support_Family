import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/chat/presentation/screens/chat_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/family_map_screen.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

const kidName = 'Xôi';
const kidStatus = 'Đang ở trường';
const kidAvatarUrl =
    'https://images.unsplash.com/photo-1596870230751-ebdfce98ec42?w=400&q=80';
const kidMapCenter = LatLng(16.0544, 108.2022);
const safeZoneCenter = LatLng(16.0544, 108.2022);

const kidTrackingArgs = MemberTrackingArgs(
  role: MemberRole.child,
  name: kidName,
  status: kidStatus,
  avatarUrl: kidAvatarUrl,
  phoneNumber: '+84 912 345 678',
  relationship: 'Con',
  battery: 78,
  connectionStatus: 'Được giám sát',
  deviceName: 'iPhone 15 Pro',
  lastActive: '2 phút trước',
  timeLabel: '08:42 AM',
  mapCenter: kidMapCenter,
  routeHistory: [
    LatLng(16.0561, 108.2048),
    LatLng(16.0554, 108.2040),
    LatLng(16.0549, 108.2033),
    LatLng(16.0544, 108.2028),
    LatLng(16.0544, 108.2022),
  ],
  playbackStartLabel: '07:20 AM',
  playbackEndLabel: '03:45 PM',
  totalDistanceLabel: '3 km',
  totalDurationLabel: '1h 42m',
  stopCount: 2,
  averageSpeedLabel: '2.2 km/h',
  timelineItems: [
    TrackingTimelineItem(timeLabel: '07:20 AM', title: 'Rời nhà'),
    TrackingTimelineItem(timeLabel: '07:45 AM', title: 'Đến trường'),
    TrackingTimelineItem(timeLabel: '11:15 AM', title: 'Ra sân chơi'),
    TrackingTimelineItem(
      timeLabel: '12:00 PM',
      title: 'Quay lại lớp',
      highlighted: true,
    ),
    TrackingTimelineItem(timeLabel: '03:45 PM', title: 'Chuẩn bị tan học'),
  ],
);

TextStyle kidTextStyle({
  required double size,
  required FontWeight weight,
  required Color color,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.beVietnamPro(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

void pushKidScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}

void openKidCall(BuildContext context) {
  Navigator.pushNamed(
    context,
    AppRoutes.inAppCall,
    arguments: const InAppCallArgs(
      name: kidName,
      avatarUrl: kidAvatarUrl,
      role: MemberRole.child,
    ),
  );
}

void openKidChat(BuildContext context) {
  Navigator.pushNamed(
    context,
    AppRoutes.chatConversation,
    arguments: ChatThreadArgs.fallback,
  );
}

void openChatList(BuildContext context) {
  Navigator.pushNamed(context, AppRoutes.chatList);
}

void openFamilyMap(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const FamilyMapScreen(
        homeRouteName: AppRoutes.kidHome,
        notificationsRouteName: AppRoutes.notifications,
        settingsRouteName: AppRoutes.settings,
        showBottomNav: false,
      ),
    ),
  );
}

void openRoutePlayback(BuildContext context) {
  Navigator.pushNamed(
    context,
    AppRoutes.routePlayback,
    arguments: kidTrackingArgs,
  );
}

void openSafeZone(BuildContext context) {
  Navigator.pushNamed(context, AppRoutes.safeZone);
}

void openCheckinReminder(BuildContext context) {
  Navigator.pushNamed(context, AppRoutes.checkinReminder);
}

void openNotifications(BuildContext context) {
  Navigator.pushNamed(context, AppRoutes.notifications);
}
