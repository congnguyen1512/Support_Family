import 'package:family_guard/features/chat/data/chat_remote_data_source.dart';
import 'package:family_guard/features/chat/presentation/screens/chat_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';

class ChatService {
  ChatService({required ChatRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ChatRemoteDataSource _remoteDataSource;

  Future<List<ChatThreadArgs>> getThreads() async {
    final data = await _remoteDataSource.getThreads();
    final now = DateTime.now();

    return data.map((item) {
      final latestAt = DateTime.tryParse(item['latest_at']?.toString() ?? '');
      final sameDay =
          latestAt != null &&
          latestAt.year == now.year &&
          latestAt.month == now.month &&
          latestAt.day == now.day;

      return ChatThreadArgs(
        id: item['peer_uid']?.toString() ?? '',
        memberName: item['peer_name']?.toString() ?? 'Thành viên gia đình',
        avatarUrl: item['peer_avatar']?.toString() ?? '',
        role: _toRole(item['peer_role']?.toString()),
        presenceLabel: 'Trực tuyến',
        previewText: item['latest_message']?.toString() ?? '',
        lastActivityLabel: _toHm(latestAt),
        section: sameDay ? ChatThreadSection.today : ChatThreadSection.yesterday,
        messages: const [],
        hasUnread: item['has_unread'] == true,
        isOnline: true,
        lastMessageAt: latestAt,
        hasStartedConversation:
            (item['latest_message']?.toString().trim().isNotEmpty ?? false),
      );
    }).toList();
  }

  Future<List<ChatMessage>> getMessages({
    required String myUid,
    required String peerUid,
  }) async {
    final data = await _remoteDataSource.getMessages(peerUid);
    return data.map((item) {
      final senderUid = item['sender_uid']?.toString() ?? '';
      final text = item['content']?.toString() ?? '';
      final createdAt = DateTime.tryParse(item['created_at']?.toString() ?? '');
      if (senderUid == myUid) {
        return ChatMessage.outgoing(text: text, timeLabel: _toAmPm(createdAt));
      }
      return ChatMessage.incoming(text: text, timeLabel: _toAmPm(createdAt));
    }).toList();
  }

  Future<void> sendMessage({
    required String peerUid,
    required String content,
  }) async {
    await _remoteDataSource.sendMessage(peerUid, content);
  }

  Future<void> updatePresence(String? activePeerUid) {
    return _remoteDataSource.updatePresence(activePeerUid);
  }

  MemberRole _toRole(String? value) {
    switch ((value ?? '').toLowerCase()) {
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

  String _toHm(DateTime? value) {
    if (value == null) return '';
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  String _toAmPm(DateTime? value) {
    if (value == null) return '';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
