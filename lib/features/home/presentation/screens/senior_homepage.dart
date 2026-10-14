import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/fall_detection/presentation/fall_detection_debug_panel.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/home/presentation/widgets/senior_home/senior_sos_sheet.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeniorHomePage extends StatefulWidget {
  const SeniorHomePage({super.key});

  @override
  State<SeniorHomePage> createState() => _SeniorHomePageState();
}

class _SeniorHomePageState extends State<SeniorHomePage> {
  _SeniorQuickContact? _quickContact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFC),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _SeniorBackground()),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 118),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 22),
                    _buildStatusPill(),
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 26),
                    _buildSosHero(context),
                    const SizedBox(height: 34),
                    _buildQuickContactCard(context),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 110,
              child: SizedBox(
                width: double.maxFinite,
                child: const FallDetectionDebugPanel(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const AppFlowBottomNav(
                current: AppNavTab.home,
                homeRouteName: AppRoutes.seniorHome,
                trackingRouteName: AppRoutes.seniorTracking,
                settingsRouteName: AppRoutes.seniorSettings,
                thirdTabRouteName: AppRoutes.seniorNotifications,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.menu_rounded,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu đang được hoàn thiện.')),
          ),
        ),
        Expanded(
          child: Text(
            'Support Family',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              color: const Color(0xFF00AEB4),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _CircleIconButton(
          icon: Icons.person_outline_rounded,
          onTap: () => Navigator.pushNamed(context, AppRoutes.seniorSettings),
        ),
      ],
    );
  }

  Widget _buildStatusPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2FBF3),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: Color(0xFF1D9C63),
            ),
            const SizedBox(width: 6),
            Text(
              'Hoạt động',
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF1C503D),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      width: double.infinity,
      child: Center(
        child: Text(
          'Bạn an toàn',
          style: GoogleFonts.lexend(
            color: const Color(0xFF17233D),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSosHero(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => _showSosSheet(context),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 162,
          height: 162,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF4773), Color(0xFFE9154A)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55FF7E9E),
                blurRadius: 36,
                spreadRadius: 4,
                offset: Offset(0, 18),
              ),
            ],
            border: Border.all(color: const Color(0xFFFF8DA8), width: 9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 42,
              ),
              const SizedBox(height: 4),
              Text(
                'SOS',
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickContactCard(BuildContext context) {
    final contact = _quickContact;
    return InkWell(
      onTap: () => _showAddQuickContactSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liên hệ nhanh',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF17233D),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (contact != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${contact.name} • ${contact.phone}',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF6A768E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'Thêm người để gọi nhanh khi cần hỗ trợ.',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF7A869A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => contact == null
                  ? _showAddQuickContactSheet(context)
                  : _startQuickCall(contact),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF00B3B8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  contact == null ? Icons.add_rounded : Icons.call_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSosSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SeniorSosSheet(
          onSafeTap: () => Navigator.pop(sheetContext),
          onEmergencyTap: () async {
            Navigator.pop(sheetContext);
            try {
              final loc =
                  AppDependencies.instance.locationTrackingService.lastLocation;
              await AppDependencies.instance.createFallNotificationUseCase(
                location: loc,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi cảnh báo khẩn cấp đến người thân!'),
                    backgroundColor: Color(0xFFFF1717),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Lỗi gửi cảnh báo SOS: $e');
            }

            if (!context.mounted) return;
            if (_quickContact == null) {
              _showAddQuickContactSheet(context);
              return;
            }
            _startQuickCall(_quickContact!);
          },
        );
      },
    );
  }

  Future<void> _showAddQuickContactSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E8EE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Thêm liên hệ nhanh',
                style: GoogleFonts.lexend(
                  color: const Color(0xFF17233D),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn muốn thêm liên hệ bằng cách nào?',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF73839B),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              _QuickAddOption(
                icon: Icons.contact_page_outlined,
                title: 'Danh bạ',
                subtitle: 'Chọn từ danh bạ điện thoại của bạn',
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final result = await Navigator.of(context)
                      .push<_SeniorQuickContact>(
                        MaterialPageRoute(
                          builder: (_) => const _SeniorContactDirectoryScreen(),
                        ),
                      );
                  _applyQuickContact(result);
                },
              ),
              const SizedBox(height: 12),
              _QuickAddOption(
                icon: Icons.dialpad_rounded,
                title: 'Số điện thoại',
                subtitle: 'Thêm số điện thoại thủ công',
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final result = await Navigator.of(context)
                      .push<_SeniorQuickContact>(
                        MaterialPageRoute(
                          builder: (_) => const _SeniorAddPhoneScreen(),
                        ),
                      );
                  _applyQuickContact(result);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF17233D),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyQuickContact(_SeniorQuickContact? contact) {
    if (contact == null || !mounted) return;
    setState(() => _quickContact = contact);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${contact.name} vào liên hệ nhanh.')),
    );
  }

  void _startQuickCall(_SeniorQuickContact contact) {
    Navigator.pushNamed(
      context,
      AppRoutes.inAppCall,
      arguments: InAppCallArgs(
        name: contact.name,
        avatarUrl: contact.avatarUrl,
        role: MemberRole.adult,
      ),
    );
  }
}

class _SeniorContactDirectoryScreen extends StatefulWidget {
  const _SeniorContactDirectoryScreen();

  @override
  State<_SeniorContactDirectoryScreen> createState() =>
      _SeniorContactDirectoryScreenState();
}

class _SeniorContactDirectoryScreenState
    extends State<_SeniorContactDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedId = _directoryContacts.first.id;

  List<_SeniorQuickContact> get _filteredContacts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _directoryContacts;
    return _directoryContacts.where((contact) {
      return contact.name.toLowerCase().contains(query) ||
          contact.phone.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _filteredContacts;
    final selected = _directoryContacts.firstWhere(
      (contact) => contact.id == _selectedId,
      orElse: () => _directoryContacts.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Column(
          children: [
            _SheetHeader(
              title: 'Thêm từ danh bạ',
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8EDF1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF00B3B8),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Tìm kiếm từ danh bạ',
                                hintStyle: GoogleFonts.beVietnamPro(
                                  color: const Color(0xFF9BA6B2),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...contacts.map((contact) {
                      final isSelected = contact.id == _selectedId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setState(() => _selectedId = contact.id),
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE9FAF9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8DDDDD)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: NetworkImage(
                                    contact.avatarUrl,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contact.name,
                                        style: GoogleFonts.lexend(
                                          color: const Color(0xFF17233D),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        contact.phone,
                                        style: GoogleFonts.beVietnamPro(
                                          color: const Color(0xFF7A869A),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF00B3B8)
                                        : const Color(0xFFF1F7F8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF00B3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, selected),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF00B3B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Thêm',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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

class _SeniorAddPhoneScreen extends StatefulWidget {
  const _SeniorAddPhoneScreen();

  @override
  State<_SeniorAddPhoneScreen> createState() => _SeniorAddPhoneScreenState();
}

class _SeniorAddPhoneScreenState extends State<_SeniorAddPhoneScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Column(
          children: [
            _SheetHeader(
              title: 'Thêm số điện thoại',
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F7F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_rounded,
                        color: Color(0xFF00B3B8),
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const _InputLabel(text: 'Tên liên hệ'),
                    const SizedBox(height: 8),
                    _SeniorTextField(
                      controller: _nameController,
                      hintText: 'Nhập tên',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 22),
                    const _InputLabel(text: 'Phone Number'),
                    const SizedBox(height: 8),
                    _SeniorTextField(
                      controller: _phoneController,
                      hintText: '+1 (555) 000-0000',
                      prefixIcon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Người liên hệ này sẽ được thông báo trong trường hợp có cảnh báo khẩn cấp từ Support Family.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF8791A1),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF00B3B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Thêm',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ tên và số điện thoại.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _SeniorQuickContact(
        id: phone,
        name: name,
        phone: phone,
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=300&auto=format&fit=crop',
      ),
    );
  }
}

class _SeniorBackground extends StatelessWidget {
  const _SeniorBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -92,
            left: -118,
            child: Container(
              width: 232,
              height: 232,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDDF7F7).withValues(alpha: 0.95),
              ),
            ),
          ),
          Positioned(
            top: 118,
            right: -92,
            child: Container(
              width: 198,
              height: 198,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0F7F7).withValues(alpha: 0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFE9F9FA),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF00B3B8)),
      ),
    );
  }
}

class _QuickAddOption extends StatelessWidget {
  const _QuickAddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF00B3B8)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF17233D),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF7A869A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0BAC7)),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF17233D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                color: const Color(0xFF17233D),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.beVietnamPro(
          color: const Color(0xFF17233D),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SeniorTextField extends StatelessWidget {
  const _SeniorTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.beVietnamPro(
        color: const Color(0xFF17233D),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF9BA6B2), size: 20),
        hintText: hintText,
        hintStyle: GoogleFonts.beVietnamPro(
          color: const Color(0xFF9BA6B2),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00B3B8)),
        ),
      ),
    );
  }
}

class _SeniorQuickContact {
  const _SeniorQuickContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final String avatarUrl;
}

const List<_SeniorQuickContact> _directoryContacts = [
  _SeniorQuickContact(
    id: 'minh-cong',
    name: 'Minh Cong',
    phone: '+1 (555) 012-3456',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop',
  ),
  _SeniorQuickContact(
    id: 'huy-le',
    name: 'Huy Le',
    phone: '+1 (555) 987-6543',
    avatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=300&auto=format&fit=crop',
  ),
  _SeniorQuickContact(
    id: 'bao-hiep',
    name: 'Bao Hiep',
    phone: '+1 (555) 246-8135',
    avatarUrl:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300&auto=format&fit=crop',
  ),
  _SeniorQuickContact(
    id: 'kha',
    name: 'Kha',
    phone: '+1 (555) 369-1472',
    avatarUrl:
        'https://images.unsplash.com/photo-1500048993953-d23a436266cf?q=80&w=300&auto=format&fit=crop',
  ),
  _SeniorQuickContact(
    id: 'vo-huy',
    name: 'Vo Huy',
    phone: '+1 (555) 753-9514',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=300&auto=format&fit=crop',
  ),
];
