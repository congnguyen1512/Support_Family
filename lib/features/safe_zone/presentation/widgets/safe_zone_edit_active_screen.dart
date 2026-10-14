import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_dialog.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';



class SafeZoneEditActiveScreen extends StatefulWidget {
  const SafeZoneEditActiveScreen({super.key});

  @override
  State<SafeZoneEditActiveScreen> createState() =>
      _SafeZoneEditActiveScreenState();
}

class _SafeZoneEditActiveScreenState extends State<SafeZoneEditActiveScreen> {

  final List<GlobalKey<_SwipeableCardState>> _cardKeys = [];

  List<SafeZone> get _zones => SafeZoneProvider.of(context).zones;
  int get _activeCount => _zones.where((z) => z.isActive).length;
  SafeZoneMember? get _primaryMember {
    final members = SafeZoneProvider.of(context).members;
    if (members.isEmpty) return null;
    final recipientIds = _zones.expand((zone) => zone.recipientIds).toSet();
    for (final member in members) {
      if (recipientIds.contains(member.id)) return member;
    }
    return members.first;
  }

  String get _displayName => _primaryMember?.name ?? 'Thành viên gia đình';

  String get _avatarLetter {
    final name = _displayName.trim();
    if (name.isEmpty) return 'G';
    return name.substring(0, 1).toUpperCase();
  }

  void _onEdit(int index) {
    if (index < _cardKeys.length) _cardKeys[index].currentState?.close();
    Navigator.of(context).pushNamed(AppRoutes.safeZoneEdit, arguments: _zones[index].id);
  }

  void _onDelete(int index) {
    if (index < _cardKeys.length) _cardKeys[index].currentState?.close();
    _showDeleteDialog(index);
  }

  void _showDeleteDialog(int index) {
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xóa vùng an toàn',
      content: 'Bạn có chắc muốn xóa "${_zones[index].name}" không?',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () {
        SafeZoneProvider.read(context).removeZone(_zones[index].id);
        Navigator.pop(context); // edit screen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: const AppBackHeaderBar(
        title: 'Vùng an toàn',
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 0,
                left: 16,
                right: 16,
                bottom: 56 + 32 + 16 + bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildProfileCard(),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Vùng an toàn đang hoạt động',
                            style: TextStyle(
                              color: const Color(0xFF0C1D1A),
                              fontSize: ResponsiveHelper.sp(context, 18),
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                              height: 1.56,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.swipe_left_rounded, size: 14, color: Color(0xFF00ACB2)),
                              const SizedBox(width: 4),
                              Text(
                                'Vuốt để sửa/xóa',
                                style: TextStyle(
                                  color: const Color(0xFF00ACB2),
                                  fontSize: ResponsiveHelper.sp(context, 11),
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  ...List.generate(_zones.length, (i) {
                    while (_cardKeys.length <= i) {
                      _cardKeys.add(GlobalKey<_SwipeableCardState>());
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: i < _zones.length - 1 ? 16 : 0),
                      child: _SwipeableCard(
                        key: _cardKeys[i],
                        onEdit: () => _onEdit(i),
                        onDelete: () => _onDelete(i),
                        child: _buildZoneCardContent(i),
                      ),
                    );
                  }),
                ],
              ),
              ),
            

            Positioned(
              right: 16,
              bottom: 32 + bottomPadding,
              child: _buildFAB(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x4CE6F4F2)),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: const Color(0x3300ACB2)),
                  ),
                  child: ClipOval(
                    child: CustomPaint(painter: _ProfileAvatarPainter(_avatarLetter)),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ACB2),
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: TextStyle(
                    color: const Color(0xFF0C1D1A),
                    fontSize: ResponsiveHelper.sp(context, 20),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.40,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded, color: Color(0xFF45A191), size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$_activeCount vùng an toàn đang bật',
                        style: TextStyle(
                          color: const Color(0xFF45A191),
                          fontSize: ResponsiveHelper.sp(context, 14),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.safeZoneConfig),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Color(0xFF00ACB2),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Nội dung zone card - responsive, không overflow ────────────────
  Widget _buildZoneCardContent(int index) {
    final zone = _zones[index];
    final radiusLabel = zone.radius >= 1000
        ? '${(zone.radius / 1000).toStringAsFixed(zone.radius % 1000 == 0 ? 0 : 1)}KM'
        : '${zone.radius.round()}M';
    return Padding(
      // Padding ngoài thay Container để không bị ép chiều cao
      padding: const EdgeInsets.all(12),
      child: Row(
        // mainAxisSize.max + crossAxisAlignment.center
        // → tự co ngang theo màn, căn giữa dọc không cần fixed height
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Map thumbnail: kích thước cố định 80×80 là hợp lý (ảnh bản đồ)
          _buildMapThumbnail(zone),

          const SizedBox(width: 16),

          // Tên + bán kính + địa chỉ — Expanded để chiếm phần còn lại
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,  // không ép chiều cao
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng tên + radius badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        zone.name,
                        style: TextStyle(
                          color: const Color(0xFF0C1D1A),
                          fontSize: ResponsiveHelper.sp(context, 16),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge bán kính: intrinsic size, không overflow
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryLight,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        radiusLabel,
                        style: TextStyle(
                          color: const Color(0xFF00ACB2),
                          fontSize: ResponsiveHelper.sp(context, 10),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  zone.address,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: ResponsiveHelper.sp(context, 14),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Toggle — Center để căn giữa không cần Padding thêm left:8
          Center(
            child: GestureDetector(
              onTap: () {
                SafeZoneProvider.read(context).toggleZone(zone.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 28,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: zone.isActive
                      ? const Color(0xFF00ACB2)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: zone.isActive
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Map thumbnail 80×80 ───────────────────────────────────────────
  Widget _buildMapThumbnail(SafeZone zone) {
    final center = LatLng(zone.latitude, zone.longitude);
    return Container(
      width: 80,
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IgnorePointer(
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.figma_app',
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: center,
                  radius: 20,
                  color: const Color(0x3300ACB2),
                  borderColor: const Color(0xFF00ACB2),
                  borderStrokeWidth: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ── fix BoxShadow thiếu `,` ────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.safeZoneConfig),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFF00ACB2),
          shape: BoxShape.circle,
          boxShadow: [
            // fix: thiếu `,` giữa 2 BoxShadow
            BoxShadow(
              color: Color(0x6600ACB2),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x6600ACB2),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        // fix: `children: [,]` rỗng → Icon thực tế
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// SWIPEABLE CARD WIDGET
// Thay thế: Container(width:518) + Positioned(left:160) Figma tuyệt đối
// bằng GestureDetector + AnimatedContainer để swipe-left reveal SỬA/XÓA
// ══════════════════════════════════════════════════════════════════════
class _SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SwipeableCard({
    required this.child,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  State<_SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<_SwipeableCard>
    with SingleTickerProviderStateMixin {
  /// Chiều rộng panel action = 2 × 80px, khớp Figma left:160
  static const double _actionWidth = 160.0;

  /// Offset hiện tại khi đang kéo tay (chỉ dùng khi KHÔNG animate)
  double _dragOffset = 0;
  bool _isOpen = false;

  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    // Rebuild mỗi tick animation để card trượt mượt
    _anim.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void close() {
    _ctrl.reverse();
    setState(() {
      _isOpen = false;
      _dragOffset = 0;
    });
  }

  void _open() {
    _ctrl.forward();
    setState(() {
      _isOpen = true;
      _dragOffset = -_actionWidth;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    if (_ctrl.isAnimating) return; // bỏ qua drag khi đang snap
    final delta = d.primaryDelta ?? 0;
    setState(() {
      _dragOffset = (_dragOffset + delta).clamp(-_actionWidth, 0.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    if (_ctrl.isAnimating) return;
    final threshold = _actionWidth * 0.4;
    if (_dragOffset.abs() > threshold) {
      _open();
    } else {
      close();
    }
  }

  /// Offset dứt khoát: animation có độ ưu tiên cao hơn drag
  double get _slideX {
    if (_ctrl.isAnimating) {
      return _isOpen
          ? -_anim.value * _actionWidth          // đang mở
          : -(1 - _anim.value) * _actionWidth;  // đang đóng
    }
    return _dragOffset;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      // ── IntrinsicHeight: tự co theo nội dung thay vì fixed 104px ──
      // Không có RenderFlex overflow khi font scale hoặc màn nhỏ
      child: IntrinsicHeight(
        child: Stack(
          children: [
            // ── Action panel (đằng sau, full height theo IntrinsicHeight) ─
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SỬA (xanh dương)
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: SizedBox(
                      width: _actionWidth / 2,
                      child: ColoredBox(
                        color: const Color(0xFF3B82F6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              'Sửa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.sp(context, 12),
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // XÓA (đỏ)
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: SizedBox(
                      width: _actionWidth / 2,
                      child: ColoredBox(
                        color: const Color(0xFFEF4444),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_rounded,
                                color: Colors.white, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              'Xóa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.sp(context, 12),
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Card trắng (trên cùng, trượt sang trái) ──────────────
            // Dùng Transform.translate thay Positioned để không ảnh
            // hưởng layout flow, tránh overflow khi card đang mở
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              onTap: _isOpen ? close : null,
              child: Transform.translate(
                offset: Offset(_slideX, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1400ACB2),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────
class _ProfileAvatarPainter extends CustomPainter {
  const _ProfileAvatarPainter(this.letter);

  final String letter;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB2EFE7), Color(0xFF80DDD1)],
        ).createShader(rect),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          color: Color(0xFF00796B),
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas,
        Offset(
            (size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
