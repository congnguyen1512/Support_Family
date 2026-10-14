import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_bottom_menu.dart';
import 'package:family_guard/features/home/presentation/screens/kid_flow_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KidChatListScreen extends StatelessWidget {
  const KidChatListScreen({super.key});

  static const _bg = Color(0xFFF7FBFF);
  static const _surface = Colors.white;
  static const _teal = Color(0xFF11B7B3);
  static const _text = Color(0xFF16304B);
  static const _muted = Color(0xFF73839B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 126),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Hôm nay'),
                    const SizedBox(height: 12),
                    ...KidFlowModels.threads
                        .take(3)
                        .map(
                          (thread) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _threadTile(context, thread),
                          ),
                        ),
                    const SizedBox(height: 8),
                    _buildSectionLabel('Hôm qua'),
                    const SizedBox(height: 12),
                    _threadTile(context, KidFlowModels.threads.last),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 104,
              child: FloatingActionButton(
                heroTag: 'kid_chat_add',
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                onPressed: () => _showQuickActions(context),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
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

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Center(
        child: Text(
          'Tin nhắn',
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            color: _text,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Text(
            'Tìm kiếm tin nhắn',
            style: GoogleFonts.beVietnamPro(color: _muted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.beVietnamPro(
        color: _muted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _threadTile(BuildContext context, KidChatThread thread) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.kidChatConversation,
        arguments: thread.id,
      ),
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -14,
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: thread.person.accent,
                  child: Text(
                    thread.person.initial,
                    style: GoogleFonts.lexend(
                      color: _text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (thread.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF32D084),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          thread.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(
                            color: _text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (thread.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FAF6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${thread.unreadCount} mới',
                            style: GoogleFonts.lexend(
                              color: _teal,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.beVietnamPro(
                      color: _muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  thread.lastTime,
                  style: GoogleFonts.beVietnamPro(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB3C0CF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EDF4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Bắt đầu nhanh',
                style: GoogleFonts.lexend(
                  color: _text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _quickActionTile(
                context,
                title: 'Nhắn cho gia đình',
                subtitle: 'Mở chat nhóm ngay',
                icon: Icons.group_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.kidChatConversation,
                    arguments: KidFlowModels.threads.first.id,
                  );
                },
              ),
              const SizedBox(height: 12),
              _quickActionTile(
                context,
                title: 'Gửi vị trí hiện tại',
                subtitle: 'Mở bản đồ và xác nhận vị trí',
                icon: Icons.location_on_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.kidLocation);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4FBFA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FAF6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.beVietnamPro(
                      color: _muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _teal),
          ],
        ),
      ),
    );
  }
}
