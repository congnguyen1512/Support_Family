import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:family_guard/features/chat/presentation/screens/chat_models.dart';
import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    super.key,
    this.showBottomNav = false,
    this.showBackButton = true,
    this.homeRouteName = AppRoutes.home,
    this.trackingRouteName = AppRoutes.tracking,
    this.thirdTabRouteName = AppRoutes.chatList,
    this.settingsRouteName = AppRoutes.settings,
  });

  final bool showBottomNav;
  final bool showBackButton;
  final String homeRouteName;
  final String trackingRouteName;
  final String thirdTabRouteName;
  final String settingsRouteName;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  static const _background = Color(0xFFF0F8F7);
  bool _loading = true;
  String _query = '';
  List<ChatThreadArgs> _threads = const [];

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  List<ChatThreadArgs> get _filtered {
    if (_query.trim().isEmpty) return _threads;
    final keyword = _query.trim().toLowerCase();
    return _threads.where((thread) {
      return thread.memberName.toLowerCase().contains(keyword) ||
          thread.previewText.toLowerCase().contains(keyword);
    }).toList();
  }

  Future<void> _loadThreads() async {
    setState(() => _loading = true);
    List<ChatThreadArgs> threads = const [];
    List<Relationship> relationships = const [];
    String myUid = '';

    try {
      threads = await AppDependencies.instance.chatService.getThreads();
    } catch (_) {}

    try {
      final all = await AppDependencies.instance.getRelationshipsUseCase();
      relationships = all.where((item) {
        final status = item.processing.trim().toLowerCase();
        return status == 'xacnhan';
      }).toList();
    } catch (_) {}

    try {
      final session = await AppDependencies.instance.getSavedSessionUseCase();
      myUid = session?.userId ?? '';
    } catch (_) {}

    // Fallback: nếu backend threads chưa trả latest message đúng, tự build từ lịch sử chat
    // để đảm bảo cuộc hội thoại đã có tin nhắn không bị hiện "Bắt đầu trò chuyện mới".
    if (threads.isEmpty && relationships.isNotEmpty && myUid.isNotEmpty) {
      final recovered = <ChatThreadArgs>[];
      for (final relation in relationships) {
        final peerUid = relation.relationId.trim();
        if (peerUid.isEmpty) {
          continue;
        }
        try {
          final messages = await AppDependencies.instance.chatService
              .getMessages(myUid: myUid, peerUid: peerUid);
          final last = messages.isNotEmpty ? messages.last : null;
          final text = (last?.text ?? '').trim();
          recovered.add(
            ChatThreadArgs(
              id: peerUid,
              memberName: (relation.relationUser?.name ?? '').trim().isNotEmpty
                  ? relation.relationUser!.name.trim()
                  : 'Thành viên gia đình',
              avatarUrl: relation.relationUser?.avata ?? '',
              role: _toRole(relation.relationUser?.role),
              presenceLabel: '',
              previewText: text.isNotEmpty ? text : 'Bắt đầu trò chuyện mới',
              lastActivityLabel: last?.timeLabel ?? '',
              section: ChatThreadSection.today,
              messages: const [],
              hasStartedConversation: text.isNotEmpty,
              lastMessageAt: DateTime.now(),
            ),
          );
        } catch (_) {
          recovered.add(
            ChatThreadArgs(
              id: peerUid,
              memberName: (relation.relationUser?.name ?? '').trim().isNotEmpty
                  ? relation.relationUser!.name.trim()
                  : 'Thành viên gia đình',
              avatarUrl: relation.relationUser?.avata ?? '',
              role: _toRole(relation.relationUser?.role),
              presenceLabel: '',
              previewText: 'Bắt đầu trò chuyện mới',
              lastActivityLabel: '',
              section: ChatThreadSection.today,
              messages: const [],
              hasStartedConversation: false,
              lastMessageAt: null,
            ),
          );
        }
      }
      threads = recovered;
    }

    if (!mounted) return;
    try {
      setState(() {
        _threads = _mergeThreadsWithLinkedMembers(threads, relationships);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ChatThreadArgs> _mergeThreadsWithLinkedMembers(
    List<ChatThreadArgs> threads,
    List<Relationship> relationships,
  ) {
    final byPeer = <String, ChatThreadArgs>{};
    for (final thread in threads) {
      byPeer[thread.id] = thread;
    }

    for (final relation in relationships) {
      final peerUid = relation.relationId.trim();
      if (peerUid.isEmpty || byPeer.containsKey(peerUid)) {
        continue;
      }

      final name = (relation.relationUser?.name ?? '').trim();
      byPeer[peerUid] = ChatThreadArgs(
        id: peerUid,
        memberName: name.isEmpty ? 'Thành viên gia đình' : name,
        avatarUrl: relation.relationUser?.avata ?? '',
        role: _toRole(relation.relationUser?.role),
        presenceLabel: '',
        previewText: 'Bắt đầu trò chuyện mới',
        lastActivityLabel: '',
        section: ChatThreadSection.today,
        messages: const [],
        hasStartedConversation: false,
        lastMessageAt: null,
      );
    }

    final merged = byPeer.values.toList();
    merged.sort((a, b) {
      if (a.hasStartedConversation != b.hasStartedConversation) {
        return a.hasStartedConversation ? -1 : 1;
      }
      if (!a.hasStartedConversation && !b.hasStartedConversation) {
        return a.memberName.toLowerCase().compareTo(b.memberName.toLowerCase());
      }
      final aMillis = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
      final bMillis = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
      return bMillis.compareTo(aMillis);
    });

    return merged;
  }

  MemberRole _toRole(String? rawRole) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppBackHeaderBar(
                  title: 'Tin nhắn',
                  showLeading: widget.showBackButton,
                  onBack: widget.showBackButton
                      ? () => Navigator.maybePop(context)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF4B5563),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Center(
                            // 👈 giúp căn giữa đẹp
                            child: TextField(
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              decoration: const InputDecoration(
                                hintText: 'Tìm kiếm',

                                // ❌ remove toàn bộ border
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,

                                // 🔥 quan trọng để không bị nền đè
                                filled: false,
                                fillColor: Colors.transparent,

                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: 1,
                              textAlignVertical: TextAlignVertical.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadThreads,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _filtered.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 160),
                              Center(
                                child: Text(
                                  'Chưa có thành viên liên kết để trò chuyện',
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              widget.showBottomNav ? 96 : 16,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final thread = _filtered[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ThreadCard(
                                  thread: thread,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.chatConversation,
                                    arguments: thread,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
            if (widget.showBottomNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppFlowBottomNav(
                  current: AppNavTab.notifications,
                  homeRouteName: widget.homeRouteName,
                  trackingRouteName: widget.trackingRouteName,
                  settingsRouteName: widget.settingsRouteName,
                  thirdTab: AppBottomMenuThirdTab.chat,
                  thirdTabRouteName: widget.thirdTabRouteName,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread, required this.onTap});

  final ChatThreadArgs thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x1F19A7A8)),
                ),
                child: ClipOval(
                  child: thread.avatarUrl.trim().isNotEmpty
                      ? Image.network(
                          thread.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF64748B),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF64748B),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.memberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thread.hasStartedConversation
                          ? thread.previewText
                          : 'Bắt đầu trò chuyện mới',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              if (thread.hasUnread)
                const Icon(
                  Icons.brightness_1,
                  size: 10,
                  color: Color(0xFF19A7A8),
                )
              else if (thread.lastActivityLabel.trim().isNotEmpty)
                Text(
                  thread.lastActivityLabel,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
