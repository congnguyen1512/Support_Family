import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';

enum ChatThreadSection { today, yesterday }

enum ChatMessageType { incomingText, outgoingText, systemNotice, locationCard }

class ChatMessage {
  const ChatMessage.incoming({required this.text, required this.timeLabel})
    : type = ChatMessageType.incomingText,
      isOutgoingLocation = false;

  const ChatMessage.outgoing({required this.text, required this.timeLabel})
    : type = ChatMessageType.outgoingText,
      isOutgoingLocation = false;

  const ChatMessage.system({required this.text})
    : type = ChatMessageType.systemNotice,
      timeLabel = '',
      isOutgoingLocation = false;

  const ChatMessage.location({
    required this.timeLabel,
    this.text = 'Chia sẻ vị trí',
    this.isOutgoingLocation = false,
  }) : type = ChatMessageType.locationCard;

  final ChatMessageType type;
  final String text;
  final String timeLabel;
  final bool isOutgoingLocation;
}

class ChatThreadArgs {
  const ChatThreadArgs({
    required this.id,
    required this.memberName,
    required this.avatarUrl,
    required this.role,
    required this.presenceLabel,
    required this.previewText,
    required this.lastActivityLabel,
    required this.section,
    required this.messages,
    this.hasUnread = false,
    this.isOnline = true,
    this.lastMessageAt,
    this.hasStartedConversation = true,
  });

  final String id;
  final String memberName;
  final String avatarUrl;
  final MemberRole role;
  final String presenceLabel;
  final String previewText;
  final String lastActivityLabel;
  final ChatThreadSection section;
  final List<ChatMessage> messages;
  final bool hasUnread;
  final bool isOnline;
  final DateTime? lastMessageAt;
  final bool hasStartedConversation;

  String get roleLabel {
    switch (role) {
      case MemberRole.child:
        return 'TRẺ EM';
      case MemberRole.adult:
        return 'NGƯỜI LỚN';
      case MemberRole.senior:
        return 'NGƯỜI GIÀ';
    }
  }

  static const ChatThreadArgs fallback = ChatThreadArgs(
    id: 'child-xoi',
    memberName: 'Xôi',
    avatarUrl:
        'https://images.unsplash.com/photo-1621452773781-0f992fd1f5cb?q=80&w=300&auto=format&fit=crop',
    role: MemberRole.child,
    presenceLabel: 'Trực tuyến',
    previewText: 'Đã chia sẻ vị trí với bạn',
    lastActivityLabel: '10:42 AM',
    section: ChatThreadSection.today,
    hasUnread: true,
    messages: [
      ChatMessage.incoming(text: 'Con đang về', timeLabel: '08:30 AM'),
      ChatMessage.outgoing(text: 'ok', timeLabel: '08:32 AM'),
      ChatMessage.system(text: 'Xôi đã rời khỏi khu vực an toàn'),
      ChatMessage.incoming(
        text: 'Con đang lên xe buýt trường',
        timeLabel: '10:40 AM',
      ),
      ChatMessage.outgoing(
        text: 'Đến nhà gọi cho mẹ nhé',
        timeLabel: '10:41 AM',
      ),
      ChatMessage.incoming(text: 'Dạ!', timeLabel: '10:42 AM'),
      ChatMessage.location(timeLabel: '10:45 AM', text: 'Chia sẻ vị trí'),
    ],
  );

  static const List<ChatThreadArgs> demoThreads = [
    fallback,
    ChatThreadArgs(
      id: 'senior-ba-noi',
      memberName: 'Bà Nội',
      avatarUrl:
          'https://images.unsplash.com/photo-1581579438747-1dc8d17bbce4?q=80&w=300&auto=format&fit=crop',
      role: MemberRole.senior,
      presenceLabel: 'Trực tuyến',
      previewText: 'Gọi cho mẹ nhé con',
      lastActivityLabel: 'Hôm qua',
      section: ChatThreadSection.yesterday,
      messages: [
        ChatMessage.incoming(
          text: 'Mẹ vừa uống thuốc xong rồi.',
          timeLabel: '08:10 AM',
        ),
        ChatMessage.outgoing(
          text: 'Chiều con qua thăm mẹ nhé',
          timeLabel: '08:14 AM',
        ),
        ChatMessage.system(text: 'Bà Nội đang ở trong khu vực an toàn'),
        ChatMessage.incoming(text: 'Gọi cho mẹ nhé con', timeLabel: '08:30 AM'),
      ],
    ),
    ChatThreadArgs(
      id: 'adult-bo-xoi',
      memberName: 'Bố Xôi',
      avatarUrl:
          'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=300&auto=format&fit=crop',
      role: MemberRole.adult,
      presenceLabel: 'Trực tuyến',
      previewText: 'Để anh đi mua cho nhé',
      lastActivityLabel: 'Hôm qua',
      section: ChatThreadSection.yesterday,
      messages: [
        ChatMessage.incoming(
          text: 'Anh đang ghé siêu thị gần nhà.',
          timeLabel: '05:20 PM',
        ),
        ChatMessage.outgoing(
          text: 'Anh mua thêm sữa cho Xôi nhé',
          timeLabel: '05:21 PM',
        ),
        ChatMessage.system(text: 'Bố Xôi đang di chuyển về nhà'),
        ChatMessage.incoming(
          text: 'Để anh đi mua cho nhé',
          timeLabel: '05:24 PM',
        ),
      ],
    ),
  ];
}
