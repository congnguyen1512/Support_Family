import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// ============================================================
/// SAFE ZONE ALERT SETTINGS SCREEN - Cài đặt cảnh báo vùng an toàn
/// Được dịch và sửa lỗi từ Figma Dev Mode export (class CITCNhBO)
///
/// Lỗi Figma đã sửa:
/// - `Expanded` trong `Stack` → loại bỏ, dùng CustomPainter cho avatar
/// - `BoxShadow(...)BoxShadow(...)` thiếu dấu `,` → thêm dấu `,`
/// - `children: [,]` rỗng → thêm `Icon(...)` thực tế
/// - `child: Stack()` rỗng → loại bỏ, thay bằng Icon
/// - `class CITCNhBO` xung đột tên → đổi thành SafeZoneAlertSettingsScreen
/// - `NetworkImage("https://placehold.co/44x44")` → dùng CustomPainter avatar
/// - `spacing:` property không hợp lệ trong Column/Row (chỉ Flutter 3.7+)
/// ============================================================

class SafeZoneAlertSettingsScreen extends StatefulWidget {
  const SafeZoneAlertSettingsScreen({super.key});

  @override
  State<SafeZoneAlertSettingsScreen> createState() =>
      _SafeZoneAlertSettingsScreenState();
}

class _SafeZoneAlertSettingsScreenState
    extends State<SafeZoneAlertSettingsScreen> {
  // ── Trạng thái toggle cảnh báo ───────────────────────────────────
  bool _leaveZoneEnabled = true;  // Khi rời vùng - bật
  bool _enterZoneEnabled = false; // Khi vào vùng - tắt

  // ── Hình thức thông báo ──────────────────────────────────────────
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  bool _callEnabled = false;

  // ── Độ khẩn cấp ─────────────────────────────────────────────────
  // 0 = Ngay lập tức, 1 = Sau 5 phút
  int _urgencyLevel = 0;

  // ── Danh sách người nhận ─────────────────────────────────────────
  final List<_AlertRecipient> _recipients = [
    _AlertRecipient(name: 'Bà Lan', role: 'Người thân chính', initials: 'BL', color: const Color(0xFF00ACB2)),
    _AlertRecipient(name: 'Ông Hùng', role: 'Người bảo hộ', initials: 'ÔH', color: const Color(0xFF3B82F6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Nội dung cuộn ──────────────────────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 160),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.42, 0.16),
                  end: Alignment(1.42, 0.84),
                  colors: [AppColors.background, AppColors.kPrimaryLight],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── AppBar ────────────────────────────────────────
                  _buildAppBar(context),

                  const SizedBox(height: 8),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.horizontalPadding(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Card: Khi rời vùng ──────────────────────
                        _buildLeaveZoneCard(),

                        const SizedBox(height: 16),

                        // ── Card: Khi vào vùng (dimmed) ─────────────
                        _buildEnterZoneCard(),

                        const SizedBox(height: 24),

                        // ── Section: Người nhận cảnh báo ────────────
                        _buildRecipientsSection(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom action bar cố định ──────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AppBackHeaderBar(
        title: 'Cài đặt cảnh báo',
        onBack: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  // ── Card: Khi rời vùng (active) ───────────────────────────────────
  Widget _buildLeaveZoneCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x3300ACB2)),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x1400ACB2),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle header
          _buildAlertHeader(
            icon: Icons.logout_rounded,
            iconBgColor: const Color(0xFFFEF9C3),
            iconColor: const Color(0xFFD97706),
            title: 'Khi rời vùng',
            isEnabled: _leaveZoneEnabled,
            onToggle: (v) => setState(() => _leaveZoneEnabled = v),
          ),

          // Nội dung cài đặt (chỉ hiện khi enabled)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _leaveZoneEnabled
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF8FAFC), thickness: 1),
                const SizedBox(height: 16),

                // Hình thức thông báo
                _buildSectionLabel('HÌNH THỨC THÔNG BÁO'),
                const SizedBox(height: 12),
                _buildCheckOption(
                  label: 'Thông báo Push',
                  value: _pushEnabled,
                  onChanged: (v) => setState(() => _pushEnabled = v!),
                ),
                const SizedBox(height: 4),
                _buildCheckOption(
                  label: 'Gửi SMS',
                  value: _smsEnabled,
                  onChanged: (v) => setState(() => _smsEnabled = v!),
                ),
                const SizedBox(height: 4),
                _buildCheckOption(
                  label: 'Gọi điện',
                  value: _callEnabled,
                  onChanged: (v) => setState(() => _callEnabled = v!),
                ),

                const SizedBox(height: 20),

                // Độ khẩn cấp
                _buildSectionLabel('ĐỘ KHẨN CẤP'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRadioOption(
                      label: 'Ngay lập tức',
                      value: 0,
                      groupValue: _urgencyLevel,
                      onChanged: (v) => setState(() => _urgencyLevel = v!),
                    ),
                    const SizedBox(width: 20),
                    _buildRadioOption(
                      label: 'Sau 5 phút',
                      value: 1,
                      groupValue: _urgencyLevel,
                      onChanged: (v) => setState(() => _urgencyLevel = v!),
                    ),
                  ],
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── Card: Khi vào vùng (dimmed/inactive) ─────────────────────────
  Widget _buildEnterZoneCard() {
    return Opacity(
      opacity: _enterZoneEnabled ? 1.0 : 0.80,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: _enterZoneEnabled
              ? Colors.white
              : Colors.white.withValues(alpha: 0.60),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x1900ACB2)),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _buildAlertHeader(
          icon: Icons.login_rounded,
          iconBgColor: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF3B82F6),
          title: 'Khi vào vùng',
          isEnabled: _enterZoneEnabled,
          onToggle: (v) => setState(() => _enterZoneEnabled = v),
        ),
      ),
    );
  }

  // ── Shared: Alert header với toggle ──────────────────────────────
  Widget _buildAlertHeader({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF004D40),
                fontSize: ResponsiveHelper.sp(context, 18),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
          ],
        ),
        // Toggle switch
        GestureDetector(
          onTap: () => onToggle(!isEnabled),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 24,
            decoration: BoxDecoration(
              color: isEnabled
                  ? const Color(0xFF00ACB2)
                  : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment:
                  isEnabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Label section tiêu đề nhỏ ────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Color(0xFF004D40),
        fontSize: ResponsiveHelper.sp(context, 14),
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.70,
      ),
    );
  }

  // ── Checkbox option ───────────────────────────────────────────────
  Widget _buildCheckOption({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            // Custom checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: ShapeDecoration(
                color: value ? const Color(0xFF00ACB2) : Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: value
                        ? const Color(0xFF00ACB2)
                        : const Color(0x4C00ACB2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: ResponsiveHelper.sp(context, 16),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Radio option ─────────────────────────────────────────────────
  Widget _buildRadioOption({
    required String label,
    required int value,
    required int groupValue,
    required ValueChanged<int?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: ShapeDecoration(
              color: isSelected ? const Color(0xFF00ACB2) : Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: isSelected
                      ? const Color(0xFF00ACB2)
                      : const Color(0x4C00ACB2),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: ResponsiveHelper.sp(context, 14),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section: Người nhận cảnh báo ─────────────────────────────────
  Widget _buildRecipientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề section
        Text(
          'Người thân',
          style: TextStyle(
            color: Color(0xFF004D40),
            fontSize: ResponsiveHelper.sp(context, 18),
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),

        const SizedBox(height: 16),

        // Card danh sách người nhận
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x1900ACB2)),
              borderRadius: BorderRadius.circular(20),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x1400ACB2),
                blurRadius: 20,
                offset: Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Danh sách người nhận
              ..._recipients.map((recipient) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _buildRecipientRow(recipient),
                  )),

              const SizedBox(height: 8),

              // Nút thêm người nhận
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng thêm người nhận sẽ được cập nhật'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00ACB2),
                  side: const BorderSide(width: 2, color: Color(0x4C00ACB2)),
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('Thêm người nhận'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Row người nhận ────────────────────────────────────────────────
  Widget _buildRecipientRow(_AlertRecipient recipient) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          // Avatar (dùng CustomPainter thay NetworkImage)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: const Color(0x3300ACB2)),
            ),
            child: ClipOval(
              child: CustomPaint(
                painter: _AvatarPainter(
                  initials: recipient.initials,
                  color: recipient.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tên + vai trò
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.name,
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: ResponsiveHelper.sp(context, 16),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
                Text(
                  recipient.role,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: ResponsiveHelper.sp(context, 12),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),

          // Nút check (đã chọn = teal)
          Container(
            width: 26,
            height: 26,
            decoration: const ShapeDecoration(
              color: Color(0xFF00ACB2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9999)),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        border: const Border(
          top: BorderSide(width: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Link "Xem trước thông báo"
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notificationPreview),
            child: Text(
              'Xem trước thông báo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00ACB2),
                fontSize: ResponsiveHelper.sp(context, 14),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                height: 1.43,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF00ACB2),
              ),
            ),
          ),

          // Nút "Lưu cài đặt"
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            child: const Text('Lưu cài đặt'),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────
class _AlertRecipient {
  final String name;
  final String role;
  final String initials;
  final Color color;
  const _AlertRecipient({
    required this.name,
    required this.role,
    required this.initials,
    required this.color,
  });
}

// ── CustomPainter vẽ avatar với initials ──────────────────────────────
class _AvatarPainter extends CustomPainter {
  final String initials;
  final Color color;

  const _AvatarPainter({required this.initials, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Background circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      Paint()..color = color.withValues(alpha: 0.15),
    );

    // Text initials
    final tp = TextPainter(
      text: TextSpan(
        text: initials,
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2,
        (size.height - tp.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) =>
      old.initials != initials || old.color != color;
}


