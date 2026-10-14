import 'package:latlong2/latlong.dart';

enum MemberRole { child, adult, senior }

class TrackingTimelineItem {
  const TrackingTimelineItem({
    required this.timeLabel,
    required this.title,
    this.highlighted = false,
  });

  final String timeLabel;
  final String title;
  final bool highlighted;
}

class MemberTrackingArgs {
  const MemberTrackingArgs({
    required this.role,
    required this.name,
    required this.status,
    required this.avatarUrl,
    required this.phoneNumber,
    required this.relationship,
    required this.battery,
    required this.connectionStatus,
    required this.deviceName,
    required this.lastActive,
    required this.timeLabel,
    required this.mapCenter,
    required this.routeHistory,
    required this.playbackStartLabel,
    required this.playbackEndLabel,
    required this.totalDistanceLabel,
    required this.totalDurationLabel,
    required this.stopCount,
    required this.averageSpeedLabel,
    required this.timelineItems,
  });

  const MemberTrackingArgs.adultFallback()
    : role = MemberRole.adult,
      name = 'Bố Xôi',
      status = 'Đang lái xe',
      avatarUrl =
          'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=300&auto=format&fit=crop',
      phoneNumber = '+1 (555) 0123',
      relationship = 'Chồng',
      battery = 82,
      connectionStatus = 'Trực tuyến',
      deviceName = 'iPhone 13',
      lastActive = '2 phút trước',
      timeLabel = '08:42 AM',
      mapCenter = const LatLng(16.0560, 108.2040),
      routeHistory = const [
        LatLng(16.0581, 108.2062),
        LatLng(16.0574, 108.2056),
        LatLng(16.0569, 108.2050),
        LatLng(16.0564, 108.2044),
        LatLng(16.0560, 108.2040),
      ],
      playbackStartLabel = '08:00 AM',
      playbackEndLabel = '04:30 PM',
      totalDistanceLabel = '3.2 km',
      totalDurationLabel = '2h 15m',
      stopCount = 1,
      averageSpeedLabel = '2.8 km/h',
      timelineItems = const [
        TrackingTimelineItem(timeLabel: '08:00 AM', title: 'Nhà'),
        TrackingTimelineItem(timeLabel: '08:30 AM', title: 'Đến trường'),
        TrackingTimelineItem(timeLabel: '08:35 AM', title: 'Rời khỏi trường'),
        TrackingTimelineItem(
          timeLabel: '12:35 PM',
          title: 'Ở văn phòng',
          highlighted: true,
        ),
        TrackingTimelineItem(timeLabel: '01:00 PM', title: 'Lái xe'),
      ];

  const MemberTrackingArgs.seniorFallback()
    : role = MemberRole.senior,
      name = 'Bà Nội',
      status = 'Đang ở nhà',
      avatarUrl =
          'https://images.unsplash.com/photo-1581579438747-1dc8d17bbce4?q=80&w=300&auto=format&fit=crop',
      phoneNumber = '+1 (555) 0123',
      relationship = 'Mẹ',
      battery = 82,
      connectionStatus = 'Trực tuyến',
      deviceName = 'iPhone 13',
      lastActive = '2 phút trước',
      timeLabel = '08:42 AM',
      mapCenter = const LatLng(16.0529, 108.2058),
      routeHistory = const [
        LatLng(16.0518, 108.2074),
        LatLng(16.0521, 108.2069),
        LatLng(16.0524, 108.2064),
        LatLng(16.0527, 108.2060),
        LatLng(16.0529, 108.2058),
      ],
      playbackStartLabel = '08:00 AM',
      playbackEndLabel = '04:30 PM',
      totalDistanceLabel = '2.4 km',
      totalDurationLabel = '1h 40m',
      stopCount = 2,
      averageSpeedLabel = '1.9 km/h',
      timelineItems = const [
        TrackingTimelineItem(timeLabel: '08:00 AM', title: 'Nhà'),
        TrackingTimelineItem(timeLabel: '09:15 AM', title: 'Công viên gần nhà'),
        TrackingTimelineItem(timeLabel: '10:00 AM', title: 'Quán tạp hóa'),
        TrackingTimelineItem(
          timeLabel: '12:35 PM',
          title: 'Ở nhà',
          highlighted: true,
        ),
        TrackingTimelineItem(timeLabel: '01:00 PM', title: 'Nghỉ ngơi'),
      ];

  final MemberRole role;
  final String name;
  final String status;
  final String avatarUrl;
  final String phoneNumber;
  final String relationship;
  final int battery;
  final String connectionStatus;
  final String deviceName;
  final String lastActive;
  final String timeLabel;
  final LatLng mapCenter;
  final List<LatLng> routeHistory;
  final String playbackStartLabel;
  final String playbackEndLabel;
  final String totalDistanceLabel;
  final String totalDurationLabel;
  final int stopCount;
  final String averageSpeedLabel;
  final List<TrackingTimelineItem> timelineItems;

  String get roleLabel {
    switch (role) {
      case MemberRole.child:
        return 'Trẻ em';
      case MemberRole.adult:
        return 'Người lớn';
      case MemberRole.senior:
        return 'Người già';
    }
  }

  String get connectionLabel => connectionStatus;
}
