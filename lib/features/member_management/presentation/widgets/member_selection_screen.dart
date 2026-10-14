import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/features/member_management/presentation/models/member_management_demo_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberSelectionScreen extends StatefulWidget {
  const MemberSelectionScreen({
    super.key,
    this.args = const MemberSelectionArgs(),
  });

  final MemberSelectionArgs args;

  @override
  State<MemberSelectionScreen> createState() => _MemberSelectionScreenState();
}

class _MemberSelectionScreenState extends State<MemberSelectionScreen> {
  int selectedIndex = 0;

  List<MemberManagementMember> get _members =>
      filterMemberManagementMembers(
        widget.args.query,
        mode: widget.args.mode,
      );

  @override
  Widget build(BuildContext context) {
    final members = _members;
    final safeSelectedIndex = selectedIndex >= members.length
        ? 0
        : selectedIndex;
    final selectedMember = members[safeSelectedIndex];
    final queryLabel = widget.args.query.trim();
    final description = queryLabel.isEmpty
        ? 'Vui lòng chọn thành viên bạn muốn thao tác.'
        : 'Kết quả phù hợp với "${widget.args.query}". Chọn một thành viên để tiếp tục.';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(onClose: () => Navigator.maybePop(context)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: GoogleFonts.beVietnamPro(
                            color: const Color(0xFF64748B),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 20 / 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          itemCount: members.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 16,
                                childAspectRatio: 179 / 184,
                              ),
                          itemBuilder: (context, index) {
                            final member = members[index];
                            return _MemberCard(
                              member: member,
                              isSelected: index == selectedIndex,
                              onTap: () =>
                                  setState(() => selectedIndex = index),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00F5F8F8),
                      Color(0xF2F5F8F8),
                      Color(0xFFF5F8F8),
                    ],
                    stops: [0, 0.5, 1],
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.memberDetails,
                      arguments: selectedMember,
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF00ADB2),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Xác nhận',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 28 / 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) {
    return AppBackHeaderBar(
      title: 'Chọn thành viên',
      onBack: onClose,
      titleFontSize: 24,
      leadingSize: 32,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  final MemberManagementMember member;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = member.invitationPending
        ? const Color(0xFF94A3B8)
        : const Color(0xFF22C55E);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00ADB2)
                    : const Color(0xFF87E4DB),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0x4D00ACB1)
                      : const Color(0x0D000000),
                  blurRadius: isSelected ? 15 : 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0x3300ADB2)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            member.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: const Color(0xFFE2E8F0),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    member.name,
                    style: GoogleFonts.publicSans(
                      color: const Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          member.presenceLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.beVietnamPro(
                            color: member.invitationPending
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 18,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF00ADB2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Icon(Icons.check, size: 11, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
