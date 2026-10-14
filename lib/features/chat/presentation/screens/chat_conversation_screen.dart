import 'dart:async';

import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/features/chat/presentation/screens/chat_models.dart';
import 'package:flutter/material.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key, required this.thread});

  final ChatThreadArgs thread;

  static ChatThreadArgs fromRoute(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is ChatThreadArgs) {
      return routeArgs;
    }
    if (routeArgs is String && routeArgs.trim().isNotEmpty) {
      return ChatThreadArgs(
        id: routeArgs.trim(),
        memberName: 'Thành viên gia đình',
        avatarUrl: '',
        role: ChatThreadArgs.fallback.role,
        presenceLabel: 'Trực tuyến',
        previewText: '',
        lastActivityLabel: '',
        section: ChatThreadSection.today,
        messages: const [],
        hasStartedConversation: false,
      );
    }
    return ChatThreadArgs.fallback;
  }

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen>
    with WidgetsBindingObserver {
  static const _background = Color(0xFFF0F8F7);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  bool _sending = false;
  List<ChatMessage> _messages = const [];
  Timer? _pollTimer;
  int _messageFingerprint = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterChatPresence();
    _loadMessages(initial: true);
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _leaveChatPresence();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_pollTimer == null || !_pollTimer!.isActive) {
        _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
          _loadMessages();
        });
      }
      _enterChatPresence();
      _loadMessages();
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pollTimer?.cancel();
      _leaveChatPresence();
    }
  }

  Future<void> _enterChatPresence() {
    return AppDependencies.instance.chatService.updatePresence(
      widget.thread.id,
    );
  }

  Future<void> _leaveChatPresence() {
    return AppDependencies.instance.chatService.updatePresence(null);
  }

  Future<void> _loadMessages({bool initial = false}) async {
    try {
      final session = await AppDependencies.instance.getSavedSessionUseCase();
      final myUid = session?.userId ?? '';
      final data = await AppDependencies.instance.chatService.getMessages(
        myUid: myUid,
        peerUid: widget.thread.id,
      );
      if (!mounted) return;

      final nextFingerprint =
          data.length ^ (data.isNotEmpty ? data.last.text.hashCode : 0);
      final hasNew = nextFingerprint != _messageFingerprint;
      _messageFingerprint = nextFingerprint;

      setState(() => _messages = data);
      if (initial || hasNew) {
        _scrollToBottom();
      }
    } catch (_) {
      if (!mounted) return;
      if (initial) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tải được nội dung trò chuyện')),
        );
      }
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await AppDependencies.instance.chatService.sendMessage(
        peerUid: widget.thread.id,
        content: text,
      );
      _controller.clear();
      await _loadMessages();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không gửi được tin nhắn')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            AppBackHeaderBar(
              title: widget.thread.memberName,
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final outgoing =
                            message.type == ChatMessageType.outgoingText;
                        return Align(
                          alignment: outgoing
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.72,
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: outgoing
                                  ? const Color(0xFF0FA39A)
                                  : const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(outgoing ? 16 : 4),
                                bottomRight: Radius.circular(outgoing ? 4 : 16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: outgoing
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  message.timeLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: outgoing
                                        ? Colors.white70
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Soạn tin nhắn...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          maxLines: 1,
                          cursorColor: Color(0xFF0FA39A),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _sending ? null : _send,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Color(0xFF3D4949),
                              size: 30,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
