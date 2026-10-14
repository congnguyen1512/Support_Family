import 'package:family_guard/features/member_management/domain/entities/search_user.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/chat/presentation/screens/chat_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:latlong2/latlong.dart';

enum AddMemberEntryMode { phone, email }

class AddMemberFlowArgs {
  const AddMemberFlowArgs({
    this.initialMode = AddMemberEntryMode.phone,
    this.prefilledValue = '',
    this.member,
  });

  factory AddMemberFlowArgs.edit(MemberManagementMember member) {
    return AddMemberFlowArgs(
      initialMode: AddMemberEntryMode.phone,
      prefilledValue: member.phoneNumber,
      member: member,
    );
  }

  final AddMemberEntryMode initialMode;
  final String prefilledValue;
  final MemberManagementMember? member;

  bool get isEditing => member != null;
}

class MemberSelectionArgs {
  const MemberSelectionArgs({
    this.query = '',
    this.mode = AddMemberEntryMode.phone,
  });

  final String query;
  final AddMemberEntryMode mode;
}

class MemberManagementMember {
  const MemberManagementMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.role,
    required this.status,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.avatarUrl,
    required this.batteryPercent,
    required this.deviceName,
    required this.lastActive,
    this.relationshipId,
    this.invitationPending = false,
  });

  final String id;
  final String name;
  final String relation;
  final MemberRole role;
  final String status;
  final String address;
  final String phoneNumber;
  final String email;
  final String avatarUrl;
  final int batteryPercent;
  final String deviceName;
  final String lastActive;
  final int? relationshipId;
  final bool invitationPending;

  factory MemberManagementMember.fromSearchUser(
    SearchUser user, {
    required AddMemberEntryMode mode,
  }) {
    return MemberManagementMember(
      id: user.uid,
      name: user.name.isNotEmpty ? user.name : user.email,
      relation: 'Người thân',
      role: user.role == 'nguoiduocchamsoc' ? MemberRole.child : MemberRole.adult,
      status: mode == AddMemberEntryMode.phone ? user.phone ?? '' : user.email,
      address: user.phone?.isNotEmpty == true
          ? user.phone!
          : (user.email.isNotEmpty ? user.email : 'Chưa cập nhật'),
      phoneNumber: user.phone ?? '',
      email: user.email,
      avatarUrl: user.avata ?? '',
      batteryPercent: 0,
      deviceName: 'Chưa cập nhật',
      lastActive: 'Chưa cập nhật',
    );
  }

  String get roleChipLabel {
    switch (role) {
      case MemberRole.child:
        return 'TRẺ EM';
      case MemberRole.adult:
        return 'NGƯỜI LỚN';
      case MemberRole.senior:
        return 'NGƯỜI GIÀ';
    }
  }

  String get connectionLabel => invitationPending ? 'Đã gửi lời mời' : 'Đã kết nối';

  String get presenceLabel => invitationPending ? 'Chờ xác nhận' : 'Trực tuyến';

  InAppCallArgs get inAppCallArgs => InAppCallArgs(
    name: name,
    avatarUrl: avatarUrl,
    role: role,
  );

  ChatThreadArgs get chatThreadArgs => ChatThreadArgs(
    id: id,
    memberName: name,
    avatarUrl: avatarUrl,
    role: role,
    presenceLabel: presenceLabel,
    previewText: invitationPending
        ? 'Đã gửi lời mời tham gia gia đình'
        : 'Đã chia sẻ vị trí với bạn',
    lastActivityLabel: invitationPending ? 'Đang chờ' : '10:42 AM',
    section: ChatThreadSection.today,
    hasUnread: !invitationPending,
    isOnline: !invitationPending,
    messages: [
      ChatMessage.incoming(
        text: invitationPending
            ? 'Mình vừa gửi lời mời tham gia Support Family.'
            : 'Con vẫn ổn, đang ở đúng lịch trình nhé.',
        timeLabel: '08:30 AM',
      ),
      ChatMessage.outgoing(
        text: invitationPending
            ? 'Khi nào nhận được thì xác nhận giúp mình nhé.'
            : 'Có gì cập nhật thì nhắn cho mình luôn nhé.',
        timeLabel: '08:32 AM',
      ),
      ChatMessage.system(
        text: invitationPending
            ? '$name đang chờ xác nhận lời mời'
            : '$name đang ở trong vùng an toàn',
      ),
      ChatMessage.location(
        timeLabel: '10:45 AM',
        text: 'Chia sẻ vị trí',
      ),
    ],
  );

  MemberTrackingArgs get trackingArgs {
    switch (role) {
      case MemberRole.child:
        return MemberTrackingArgs(
          role: role,
          name: name,
          status: status,
          avatarUrl: avatarUrl,
          phoneNumber: phoneNumber,
          relationship: relation,
          battery: batteryPercent,
          connectionStatus: presenceLabel,
          deviceName: deviceName,
          lastActive: lastActive,
          timeLabel: '08:20 AM',
          mapCenter: const LatLng(16.0602, 108.2141),
          routeHistory: const [
            LatLng(16.0614, 108.2164),
            LatLng(16.0610, 108.2157),
            LatLng(16.0607, 108.2151),
            LatLng(16.0604, 108.2146),
            LatLng(16.0602, 108.2141),
          ],
          playbackStartLabel: '07:00 AM',
          playbackEndLabel: '04:00 PM',
          totalDistanceLabel: '5.1 km',
          totalDurationLabel: '45m',
          stopCount: 3,
          averageSpeedLabel: '6.2 km/h',
          timelineItems: const [
            TrackingTimelineItem(timeLabel: '07:00 AM', title: 'Rời nhà'),
            TrackingTimelineItem(timeLabel: '07:30 AM', title: 'Đến trường'),
            TrackingTimelineItem(
              timeLabel: '08:20 AM',
              title: 'Đang ở lớp học',
              highlighted: true,
            ),
          ],
        );
      case MemberRole.adult:
        return MemberTrackingArgs(
          role: role,
          name: name,
          status: status,
          avatarUrl: avatarUrl,
          phoneNumber: phoneNumber,
          relationship: relation,
          battery: batteryPercent,
          connectionStatus: presenceLabel,
          deviceName: deviceName,
          lastActive: lastActive,
          timeLabel: '08:42 AM',
          mapCenter: const LatLng(16.0560, 108.2040),
          routeHistory: const [
            LatLng(16.0581, 108.2062),
            LatLng(16.0574, 108.2056),
            LatLng(16.0569, 108.2050),
            LatLng(16.0564, 108.2044),
            LatLng(16.0560, 108.2040),
          ],
          playbackStartLabel: '08:00 AM',
          playbackEndLabel: '04:30 PM',
          totalDistanceLabel: '3.2 km',
          totalDurationLabel: '2h 15m',
          stopCount: 1,
          averageSpeedLabel: '2.8 km/h',
          timelineItems: const [
            TrackingTimelineItem(timeLabel: '08:00 AM', title: 'Rời nhà'),
            TrackingTimelineItem(timeLabel: '08:45 AM', title: 'Đến công viên'),
            TrackingTimelineItem(
              timeLabel: '09:30 AM',
              title: 'Đang đi dạo',
              highlighted: true,
            ),
          ],
        );
      case MemberRole.senior:
        return MemberTrackingArgs(
          role: role,
          name: name,
          status: status,
          avatarUrl: avatarUrl,
          phoneNumber: phoneNumber,
          relationship: relation,
          battery: batteryPercent,
          connectionStatus: presenceLabel,
          deviceName: deviceName,
          lastActive: lastActive,
          timeLabel: '08:42 AM',
          mapCenter: const LatLng(16.0529, 108.2058),
          routeHistory: const [
            LatLng(16.0518, 108.2074),
            LatLng(16.0521, 108.2069),
            LatLng(16.0524, 108.2064),
            LatLng(16.0527, 108.2060),
            LatLng(16.0529, 108.2058),
          ],
          playbackStartLabel: '08:00 AM',
          playbackEndLabel: '04:30 PM',
          totalDistanceLabel: '2.4 km',
          totalDurationLabel: '1h 40m',
          stopCount: 2,
          averageSpeedLabel: '1.9 km/h',
          timelineItems: const [
            TrackingTimelineItem(timeLabel: '08:00 AM', title: 'Nhà'),
            TrackingTimelineItem(timeLabel: '09:15 AM', title: 'Công viên gần nhà'),
            TrackingTimelineItem(
              timeLabel: '12:35 PM',
              title: 'Đang ở nhà',
              highlighted: true,
            ),
          ],
        );
    }
  }
}

const List<MemberManagementMember> memberManagementMembers = [
  MemberManagementMember(
    id: 'senior-ba-noi',
    name: 'Bà Nội',
    relation: 'Mẹ',
    role: MemberRole.senior,
    status: 'Đang ở nhà',
    address: '123 Nguyễn Hữu Thọ',
    phoneNumber: '+84 909 100 001',
    email: 'ba.noi@familyguard.vn',
    avatarUrl:
        'https://images.unsplash.com/photo-1544717297-fa95b6ee9643?w=300&q=80',
    batteryPercent: 82,
    deviceName: 'iPhone 13',
    lastActive: '2 phút trước',
  ),
  MemberManagementMember(
    id: 'adult-bo-xoi',
    name: 'Lê Văn Huy',
    relation: 'Chồng',
    role: MemberRole.adult,
    status: 'Đang đi dạo',
    address: 'Công viên Tao Đàn',
    phoneNumber: '+84 909 200 002',
    email: 'example@family.com',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
    batteryPercent: 24,
    deviceName: 'iPhone 15 Pro',
    lastActive: '3 phút trước',
  ),
  MemberManagementMember(
    id: 'child-xoi',
    name: 'Xôi',
    relation: 'Con',
    role: MemberRole.child,
    status: 'Đang ở trường',
    address: 'Trường Tiểu Học',
    phoneNumber: '+84 909 300 003',
    email: 'xoi@familyguard.vn',
    avatarUrl:
        'https://images.unsplash.com/photo-1588075592446-265fd1e6e76f?w=300&q=80',
    batteryPercent: 84,
    deviceName: 'Galaxy Watch Kids',
    lastActive: 'Vừa xong',
  ),
  MemberManagementMember(
    id: 'child-suri',
    name: 'Suri',
    relation: 'Con',
    role: MemberRole.child,
    status: 'Chờ xác nhận',
    address: 'Chưa kết nối',
    phoneNumber: '+84 909 400 004',
    email: 'suri@familyguard.vn',
    avatarUrl:
        'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=300&q=80',
    batteryPercent: 0,
    deviceName: 'Chưa có thiết bị',
    lastActive: 'Chưa hoạt động',
    invitationPending: true,
  ),
];

MemberManagementMember memberManagementMemberById(String id) {
  for (final member in memberManagementMembers) {
    if (member.id == id) {
      return member;
    }
  }
  return memberManagementMembers.first;
}

List<MemberManagementMember> filterMemberManagementMembers(
  String query, {
  AddMemberEntryMode mode = AddMemberEntryMode.phone,
  bool exact = false,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return memberManagementMembers;
  }

  final normalizedPhoneQuery = _normalizePhoneForSearch(query);

  final matches = memberManagementMembers.where((member) {
    if (mode == AddMemberEntryMode.email) {
      final memberEmail = member.email.toLowerCase();
      if (exact) {
        return memberEmail == normalizedQuery;
      }
      return memberEmail.contains(normalizedQuery) ||
          member.name.toLowerCase().contains(normalizedQuery) ||
          member.relation.toLowerCase().contains(normalizedQuery);
    }

    final memberPhone = _normalizePhoneForSearch(member.phoneNumber);
    if (exact) {
      return memberPhone == normalizedPhoneQuery;
    }

    return memberPhone.contains(normalizedPhoneQuery) ||
        member.name.toLowerCase().contains(normalizedQuery) ||
        member.relation.toLowerCase().contains(normalizedQuery);
  }).toList();

  if (exact) {
    return matches;
  }

  return matches.isEmpty ? memberManagementMembers : matches;
}

String _normalizePhoneForSearch(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('84') && digits.length == 11) {
    return '0${digits.substring(2)}';
  }
  return digits;
}
