import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';

class KidPerson {
  const KidPerson({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.accent,
    required this.initial,
    required this.callArgs,
  });

  final String name;
  final String role;
  final String avatarUrl;
  final Color accent;
  final String initial;
  final InAppCallArgs callArgs;
}

class KidChatMessage {
  const KidChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.time,
    required this.isMine,
    this.imageLabel,
  });

  final String id;
  final String senderName;
  final String text;
  final String time;
  final bool isMine;
  final String? imageLabel;
}

class KidChatThread {
  const KidChatThread({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
    required this.isOnline,
    required this.person,
    required this.messages,
  });

  final String id;
  final String name;
  final String subtitle;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  final bool isOnline;
  final KidPerson person;
  final List<KidChatMessage> messages;
}

class KidFlowModels {
  const KidFlowModels._();

  static const meLan = KidPerson(
    name: 'Mẹ Lan',
    role: 'Mẹ',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
    accent: Color(0xFFFFE8E0),
    initial: 'L',
    callArgs: InAppCallArgs(
      name: 'Trần Thị Lan',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
      role: MemberRole.adult,
    ),
  );

  static const baMinh = KidPerson(
    name: 'Bố',
    role: 'Ba',
    avatarUrl:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=400&auto=format&fit=crop',
    accent: Color(0xFFE5F4FF),
    initial: 'M',
    callArgs: InAppCallArgs(
      name: 'Nguyễn Văn Minh',
      avatarUrl:
          'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=400&auto=format&fit=crop',
      role: MemberRole.adult,
    ),
  );

  static const baNoi = KidPerson(
    name: 'Bà nội',
    role: 'Bà',
    avatarUrl:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=400&auto=format&fit=crop',
    accent: Color(0xFFEAF8F1),
    initial: 'H',
    callArgs: InAppCallArgs(
      name: 'Lê Thị Hoa',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=400&auto=format&fit=crop',
      role: MemberRole.senior,
    ),
  );

  static const familyGroup = KidPerson(
    name: 'Gia đình',
    role: 'Nhóm',
    avatarUrl: '',
    accent: Color(0xFFE7FAF9),
    initial: 'G',
    callArgs: InAppCallArgs(
      name: 'Trần Thị Lan',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
      role: MemberRole.adult,
    ),
  );

  static const threads = <KidChatThread>[
    KidChatThread(
      id: 'family-group',
      name: 'Gia đình',
      subtitle: 'Ba, Mẹ, Bà nội',
      lastMessage: 'Mẹ: Về đến nhà nhớ nhắn nhé con',
      lastTime: '16:42',
      unreadCount: 2,
      isOnline: true,
      person: familyGroup,
      messages: [
        KidChatMessage(
          id: 'm1',
          senderName: 'Mẹ Lan',
          text: 'Con về chưa',
          time: '16:32',
          isMine: false,
        ),
        KidChatMessage(
          id: 'm2',
          senderName: 'Nguyễn Minh An',
          text: 'Dạ con đang học thêm',
          time: '16:34',
          isMine: true,
        ),
        KidChatMessage(
          id: 'm3',
          senderName: 'Bố',
          text: 'Về nhớ báo cho ba nhé',
          time: '16:36',
          isMine: false,
        ),
        KidChatMessage(
          id: 'm4',
          senderName: 'Nguyễn Minh An',
          text: 'Ok con',
          time: '16:37',
          isMine: true,
        ),
        KidChatMessage(
          id: 'm5',
          senderName: 'Nguyễn Minh An',
          text: '',
          imageLabel: 'Bản đồ vị trí hiện tại',
          time: '16:40',
          isMine: true,
        ),
      ],
    ),
    KidChatThread(
      id: 'ba-minh',
      name: 'Bố',
      subtitle: 'Đang hoạt động',
      lastMessage: 'Bố: Con cố nhé',
      lastTime: '15:22',
      unreadCount: 0,
      isOnline: true,
      person: baMinh,
      messages: [
        KidChatMessage(
          id: 'b1',
          senderName: 'Bố',
          text: 'Tan học ba đón nhé',
          time: '15:18',
          isMine: false,
        ),
        KidChatMessage(
          id: 'b2',
          senderName: 'Nguyễn Minh An',
          text: 'Dạ ba',
          time: '15:20',
          isMine: true,
        ),
      ],
    ),
    KidChatThread(
      id: 'me-lan',
      name: 'Mẹ',
      subtitle: 'Đang di chuyển',
      lastMessage: 'Mẹ: Nhớ kiểm tra pin nhé',
      lastTime: '17:05',
      unreadCount: 1,
      isOnline: true,
      person: meLan,
      messages: [
        KidChatMessage(
          id: 'l1',
          senderName: 'Mẹ Lan',
          text: 'Pin con còn ít đó',
          time: '17:05',
          isMine: false,
        ),
      ],
    ),
    KidChatThread(
      id: 'ba-noi',
      name: 'Bà nội',
      subtitle: 'Ở nhà',
      lastMessage: 'Bà nội: Tối về ăn canh nhé',
      lastTime: '12:08',
      unreadCount: 0,
      isOnline: true,
      person: baNoi,
      messages: [
        KidChatMessage(
          id: 'n1',
          senderName: 'Bà nội',
          text: 'Tối về sớm nhé cháu',
          time: '12:08',
          isMine: false,
        ),
      ],
    ),
  ];

  static KidChatThread threadById(String id) {
    return threads.firstWhere(
      (thread) => thread.id == id,
      orElse: () => threads.first,
    );
  }
}
