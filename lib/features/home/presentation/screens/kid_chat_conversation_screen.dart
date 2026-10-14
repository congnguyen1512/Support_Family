import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:family_guard/features/home/presentation/screens/kid_flow_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KidChatConversationScreen extends StatefulWidget {
  const KidChatConversationScreen({super.key, required this.thread});

  final KidChatThread thread;

  static KidChatThread fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is KidChatThread) {
      return args;
    }
    if (args is String) {
      return KidFlowModels.threadById(args);
    }
    return KidFlowModels.threads.first;
  }

  @override
  State<KidChatConversationScreen> createState() =>
      _KidChatConversationScreenState();
}

class _KidChatConversationScreenState extends State<KidChatConversationScreen> {
  static const _bg = Color(0xFFF7FBFF);
  static const _surface = Colors.white;
  static const _teal = Color(0xFF11B7B3);
  static const _text = Color(0xFF16304B);
  static const _muted = Color(0xFF73839B);
  static const _myBubble = Color(0xFF16B7B2);
  static const _theirBubble = Colors.white;

  late final List<KidChatMessage> _messages = List<KidChatMessage>.from(
    widget.thread.messages,
  );
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                      itemBuilder: (context, index) =>
                          _messageBubble(_messages[index]),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemCount: _messages.length,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 92,
              child: _buildComposer(context),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomMenu(
                current: AppNavTab.notifications,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.kidChatList),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F8FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: _teal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: widget.thread.person.accent,
            child: Text(
              widget.thread.person.initial,
              style: GoogleFonts.lexend(
                color: _text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.thread.name,
                  style: GoogleFonts.lexend(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.thread.subtitle,
                  style: GoogleFonts.beVietnamPro(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.inAppCall,
              arguments: widget.thread.person.callArgs,
            ),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE8FAF6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_rounded, color: _teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(KidChatMessage message) {
    final align = message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = message.isMine ? _myBubble : _theirBubble;
    final textColor = message.isMine ? Colors.white : _text;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: Radius.circular(message.isMine ? 22 : 6),
      bottomRight: Radius.circular(message.isMine ? 6 : 22),
    );

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 270),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!message.isMine)
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 4),
                child: Text(
                  message.senderName,
                  style: GoogleFonts.beVietnamPro(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.all(message.imageLabel == null ? 14 : 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: message.imageLabel == null
                  ? Text(
                      message.text,
                      style: GoogleFonts.beVietnamPro(
                        color: textColor,
                        fontSize: 15,
                        height: 1.45,
                        fontWeight: message.isMine
                            ? FontWeight.w500
                            : FontWeight.w600,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 122,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF69D7D3),
                                Color(0xFF2BB8FF),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(painter: _MiniMapPainter()),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.place_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          message.imageLabel!,
                          style: GoogleFonts.beVietnamPro(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: GoogleFonts.beVietnamPro(
                color: _muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
            spreadRadius: -14,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.kidLocation),
            icon: const Icon(Icons.location_on_outlined, color: _teal),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: 'Soạn tin nhắn...',
                hintStyle: GoogleFonts.beVietnamPro(
                  color: _muted,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.beVietnamPro(
                color: _text,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _sendMessage,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: _teal,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        KidChatMessage(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          senderName: 'Nguyễn Minh An',
          text: text,
          time: 'Bây giờ',
          isMine: true,
        ),
      );
      _controller.clear();
    });
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.18),
      Offset(size.width * 0.86, size.height * 0.34),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.82),
      Offset(size.width * 0.76, size.height * 0.24),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.08),
      Offset(size.width * 0.42, size.height * 0.92),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
