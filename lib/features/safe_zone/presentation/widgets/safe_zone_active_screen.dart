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


// ═══════════════════════════════════════════════════════════════════
// SAFE ZONE MEMBER SCREEN – Redesigned
// ═══════════════════════════════════════════════════════════════════
class SafeZoneMemberScreen extends StatefulWidget {
  final Map<String, dynamic> member;
  final VoidCallback? onBackToHome;
  const SafeZoneMemberScreen({
    super.key,
    this.member = const {'name': 'Bà Lan', 'role': 'Người cao tuổi', 'avatar': 'B', 'id': '1'},
    this.onBackToHome,
  });

  @override
  State<SafeZoneMemberScreen> createState() => _SafeZoneMemberScreenState();
}

class _SafeZoneMemberScreenState extends State<SafeZoneMemberScreen> {
  List<SafeZone> get _zones => SafeZoneProvider.of(context).getZonesForMember(widget.member['id']);

  // ── toast ──────────────────────────────────────────────────────
  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Lexend', color: Colors.white)),
        backgroundColor: const Color(0xFF00ACB2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        duration: const Duration(seconds: 2),
      ));
  }

  // ── delete confirm ─────────────────────────────────────────────
  void _confirmDelete(SafeZone zone) {
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xóa vùng an toàn',
      content: 'Bạn có chắc muốn xóa "${zone.name}"?',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () {
        SafeZoneProvider.read(context).removeZone(zone.id);
        _toast('Đã xóa "${zone.name}"');
      },
    );
  }

  // ── add zone bottom sheet ──────────────────────────────────────
  void _showAddZoneSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddZoneSheet(
        onSave: (name, lat, lng, radius, address) async {
          final service = SafeZoneProvider.read(context);
          final created = await service.addZone(SafeZone(
            id: service.nextZoneId(),
            name: name,
            targetUid: widget.member['id']?.toString(),
            latitude: lat,
            longitude: lng,
            radius: radius,
            address: address,
            isActive: true,
            recipientIds: [widget.member['id']],
          ));
          _toast('Đã thêm "$name"');
          if (!mounted) {
            return;
          }
          if (created == null) {
            _toast(service.lastErrorMessage ?? 'Khong tao duoc vung an toan');
            return;
          }
        },
      ),
    );
  }

  // ── edit zone bottom sheet ─────────────────────────────────────
  void _showEditSheet(SafeZone zone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditZoneSheet(
        zone: zone,
        onSave: (name, lat, lng, radius, address) {
          SafeZoneProvider.read(context).updateZone(zone.copyWith(
            name: name,
            latitude: lat,
            longitude: lng,
            radius: radius,
            address: address,
          ));
          _toast('Đã cập nhật "$name"');
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topInset = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72 + topInset),
        child: SafeArea(
          bottom: false,
          child: AppBackHeaderBar(
            title: 'Vùng an toàn',
            onBack: () {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPad),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: const Text('Quay về'),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          _buildMemberCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Vùng an toàn đang hoạt động',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.end,
                      children: const [
                        Icon(Icons.swipe, size: 16, color: Color(0xFF00ACB2)),
                        Text(
                          'Vuốt để sửa/xóa',
                          style: TextStyle(fontSize: 13, color: Color(0xFF00ACB2)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(children: [
              ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 100 + bottomPad),
                itemCount: _zones.length,
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSwipeableZoneCard(_zones[i]),
                  );
                },
              ),
              // FAB
              Positioned(
                right: 16,
                bottom: 24 + bottomPad,
                child: _buildFAB(),
              ),
            ]),
          ),
        ]),
      ),
    );
  }


  // ── Member Card ───────────────────────────────────────────────
  Widget _buildMemberCard() {
    final member = widget.member;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x4CE6F4F2)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1400ACB2),
                blurRadius: 20,
                offset: Offset(0, 4),
                spreadRadius: -2),
          ],
        ),
        child: Row(children: [
          // Avatar
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(clipBehavior: Clip.none, children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: member['color'] ?? const Color(0xFF80CBC4),
                child: Text(
                  (member['avatar'] ?? '').toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ACB2),
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 14),

          // Name + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member['name'] ?? '',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: ResponsiveHelper.sp(context, 18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0C1D1A),
                    )),
                const SizedBox(height: 4),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shield_rounded,
                      size: 15, color: Color(0xFF45A191)),
                  const SizedBox(width: 5),
                  Text('${member['activeZones'] ?? 0} vùng an toàn đang bật',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: ResponsiveHelper.sp(context, 13),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF45A191),
                      )),
                ]),
                if (member['role'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      member['role'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── Swipeable Zone Card ───────────────────────────────────────
  Widget _buildSwipeableZoneCard(SafeZone zone) {
    return _SwipeableZoneItem(
      zone: zone,
      onEdit: () => _showEditSheet(zone),
      onDelete: () => _confirmDelete(zone),
      child: _buildZoneCard(zone),
    );
  }

  Widget _buildZoneCard(SafeZone zone) {
    final radiusLabel = zone.radius >= 1000
        ? '${(zone.radius / 1000).toStringAsFixed(zone.radius % 1000 == 0 ? 0 : 1)}KM'
        : '${zone.radius.round()}M';
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SafeZoneDetailRedesigned(zoneId: zone.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x1A00ACB2)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2)),
            BoxShadow(
                color: Color(0x0F00ACB2),
                blurRadius: 20,
                offset: Offset(0, 4),
                spreadRadius: -4),
          ],
        ),
        child: Row(children: [
          // Map thumbnail
          _buildMapThumb(zone),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(zone.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: ResponsiveHelper.sp(context, 15),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C1D1A),
                        )),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimaryLight,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(radiusLabel,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: ResponsiveHelper.sp(context, 10),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00ACB2),
                        )),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(zone.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: ResponsiveHelper.sp(context, 13),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Toggle
          GestureDetector(
            onTap: () => SafeZoneProvider.read(context).toggleZone(zone.id),
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
                          offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Map thumbnail ─────────────────────────────────────────────
  Widget _buildMapThumb(SafeZone zone) {
    final center = LatLng(zone.latitude, zone.longitude);
    return Container(
      width: 76,
      height: 76,
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
            interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.figma_app',
            ),
            CircleLayer(circles: [
              CircleMarker(
                point: center,
                radius: 18,
                color: const Color(0x3300ACB2),
                borderColor: const Color(0xFF00ACB2),
                borderStrokeWidth: 2,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return GestureDetector(
      onTap: _showAddZoneSheet,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFF00ACB2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color(0x6600ACB2),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: -4),
            BoxShadow(
                color: Color(0x6600ACB2),
                blurRadius: 15,
                offset: Offset(0, 10),
                spreadRadius: -3),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SWIPEABLE ZONE ITEM – reveals Edit/Delete on swipe left
// ═══════════════════════════════════════════════════════════════════
class _SwipeableZoneItem extends StatefulWidget {
  final SafeZone zone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Widget child;

  const _SwipeableZoneItem({
    required this.zone,
    required this.onEdit,
    required this.onDelete,
    required this.child,
  });

  @override
  State<_SwipeableZoneItem> createState() => _SwipeableZoneItemState();
}

class _SwipeableZoneItemState extends State<_SwipeableZoneItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<Offset> _slideAnim;
  double _dragExtent = 0;
  static const double _actionWidth = 120; // 2 buttons x 60

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _slideAnim = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    _dragExtent = (_dragExtent + d.delta.dx).clamp(-_actionWidth, 0);
    _slideAnim = AlwaysStoppedAnimation(Offset(_dragExtent, 0));
    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    final open = _dragExtent.abs() > _actionWidth / 2;
    final target = open ? -_actionWidth : 0.0;
    _slideAnim = Tween<Offset>(
      begin: Offset(_dragExtent, 0),
      end: Offset(target, 0),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward(from: 0).then((_) => _dragExtent = target);
  }

  void _close() {
    _slideAnim = Tween<Offset>(
      begin: Offset(_dragExtent, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward(from: 0).then((_) => _dragExtent = 0);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 108,
        child: Stack(children: [
          // Action buttons behind
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _close();
                    widget.onEdit();
                  },
                  child: Container(
                    width: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                    ),
                    child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_rounded,
                              color: Colors.white, size: 22),
                          SizedBox(height: 4),
                          Text('Sửa',
                              style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ]),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _close();
                    widget.onDelete();
                  },
                  child: Container(
                    width: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                    ),
                    child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_rounded,
                              color: Colors.white, size: 22),
                          SizedBox(height: 4),
                          Text('Xóa',
                              style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ]),
                  ),
                ),
              ],
            ),
          ),

          // Foreground card
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Transform.translate(
              offset: _slideAnim.value,
              child: GestureDetector(
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: widget.child,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ADD ZONE BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════
class _AddZoneSheet extends StatefulWidget {
  final void Function(
      String name, double lat, double lng, double radius, String address)
      onSave;

  const _AddZoneSheet({required this.onSave});

  @override
  State<_AddZoneSheet> createState() => _AddZoneSheetState();
}

class _AddZoneSheetState extends State<_AddZoneSheet> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _mapCtrl = MapController();
  double _radius = 500;
  LatLng? _selectedPoint;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content:
            Text(msg, style: const TextStyle(fontFamily: 'Lexend', color: Colors.white)),
        backgroundColor: const Color(0xFF00ACB2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_location_rounded,
                  color: Color(0xFF00ACB2), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Thêm vùng mới',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF006D5B),
                )),
          ]),
        ),
        const Divider(color: Color(0xFFF1F5F9)),

        // Scrollable content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name input
                _label('Tên vùng'),
                _textField(_nameCtrl, 'Nhập tên vùng an toàn...'),
                const SizedBox(height: 14),

                // Map
                _label('Chọn vị trí trên bản đồ'),
                const SizedBox(height: 6),
                Container(
                  height: 220,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter:
                          const LatLng(10.7769, 106.7009), // HCMC default
                      initialZoom: 14,
                      onTap: (_, point) {
                        setState(() {
                          _selectedPoint = point;
                          _addressCtrl.text =
                              '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.figma_app',
                      ),
                      if (_selectedPoint != null) ...[
                        CircleLayer(circles: [
                          CircleMarker(
                            point: _selectedPoint!,
                            radius: _mapRadius(),
                            color: const Color(0x2200ACB2),
                            borderColor: const Color(0xFF00ACB2),
                            borderStrokeWidth: 2,
                          ),
                        ]),
                        MarkerLayer(markers: [
                          Marker(
                            point: _selectedPoint!,
                            width: 32,
                            height: 32,
                            child: const Icon(Icons.location_pin,
                                color: Color(0xFF00ACB2), size: 32),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
                if (_selectedPoint == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Nhấn vào bản đồ để chọn vị trí',
                        style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 11,
                            color: Color(0xFF9CA3AF))),
                  ),
                const SizedBox(height: 14),

                // Radius slider
                _label('Bán kính: ${_radius >= 1000 ? '${(_radius / 1000).toStringAsFixed(1)}km' : '${_radius.round()}m'}'),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF00ACB2),
                    inactiveTrackColor: const Color(0xFF00ACB2).withAlpha(30),
                    thumbColor: const Color(0xFF00ACB2),
                    overlayColor: const Color(0xFF00ACB2).withAlpha(30),
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _radius,
                    min: 100,
                    max: 5000,
                    divisions: 49,
                    label:
                        _radius >= 1000 ? '${(_radius / 1000).toStringAsFixed(1)}km' : '${_radius.round()}m',
                    onChanged: (v) => setState(() => _radius = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('100m',
                        style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 10,
                            color: Color(0xFF9CA3AF))),
                    Text('5km',
                        style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 10,
                            color: Color(0xFF9CA3AF))),
                  ],
                ),
                const SizedBox(height: 14),

                // Address
                _label('Địa chỉ'),
                _textField(_addressCtrl, 'Tự điền khi chọn vị trí...',
                    readOnly: true),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Buttons — always visible
        Padding(
          padding: EdgeInsets.fromLTRB(24, 4, 24, 20 + keyboardInset),
          child: Row(children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Hủy',
                      style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ACB2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Lưu',
                      style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  double _mapRadius() {
    // Visual radius on map at common zoom levels (~14)
    return (_radius / 30).clamp(5.0, 80.0);
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      _toast('Vui lòng nhập tên vùng');
      return;
    }
    if (_selectedPoint == null) {
      _toast('Vui lòng chọn vị trí trên bản đồ');
      return;
    }
    widget.onSave(
      _nameCtrl.text.trim(),
      _selectedPoint!.latitude,
      _selectedPoint!.longitude,
      _radius,
      _addressCtrl.text.trim(),
    );
    Navigator.pop(context);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF006D5B))),
      );

  Widget _textField(TextEditingController ctrl, String hint,
      {bool readOnly = false}) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      style: const TextStyle(
          fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00ACB2), width: 1.5),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EDIT ZONE BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════
class _EditZoneSheet extends StatefulWidget {
  final SafeZone zone;
  final void Function(
      String name, double lat, double lng, double radius, String address)
      onSave;

  const _EditZoneSheet({required this.zone, required this.onSave});

  @override
  State<_EditZoneSheet> createState() => _EditZoneSheetState();
}

class _EditZoneSheetState extends State<_EditZoneSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  final _mapCtrl = MapController();
  late double _radius;
  late LatLng _selectedPoint;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.zone.name);
    _addressCtrl = TextEditingController(text: widget.zone.address.isNotEmpty
        ? widget.zone.address
        : '${widget.zone.latitude.toStringAsFixed(5)}, ${widget.zone.longitude.toStringAsFixed(5)}');
    _radius = widget.zone.radius;
    _selectedPoint = LatLng(widget.zone.latitude, widget.zone.longitude);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(fontFamily: 'Lexend', color: Colors.white)),
        backgroundColor: const Color(0xFF00ACB2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_location_rounded,
                  color: Color(0xFFF59E0B), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Chỉnh sửa vùng',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF006D5B),
                )),
          ]),
        ),
        const Divider(color: Color(0xFFF1F5F9)),

        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Tên vùng'),
                _textField(_nameCtrl, 'Nhập tên vùng an toàn...'),
                const SizedBox(height: 14),

                _label('Chọn vị trí trên bản đồ'),
                const SizedBox(height: 6),
                Container(
                  height: 220,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: _selectedPoint,
                      initialZoom: 14,
                      onTap: (_, point) {
                        setState(() {
                          _selectedPoint = point;
                          _addressCtrl.text =
                              '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.figma_app',
                      ),
                      CircleLayer(circles: [
                        CircleMarker(
                          point: _selectedPoint,
                          radius: _mapRadius(),
                          color: const Color(0x2200ACB2),
                          borderColor: const Color(0xFF00ACB2),
                          borderStrokeWidth: 2,
                        ),
                      ]),
                      MarkerLayer(markers: [
                        Marker(
                          point: _selectedPoint,
                          width: 32, height: 32,
                          child: const Icon(Icons.location_pin,
                              color: Color(0xFF00ACB2), size: 32),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                _label('Bán kính: ${_radius >= 1000 ? '${(_radius / 1000).toStringAsFixed(1)}km' : '${_radius.round()}m'}'),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF00ACB2),
                    inactiveTrackColor: const Color(0xFF00ACB2).withAlpha(30),
                    thumbColor: const Color(0xFF00ACB2),
                    overlayColor: const Color(0xFF00ACB2).withAlpha(30),
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _radius,
                    min: 100, max: 5000, divisions: 49,
                    label: _radius >= 1000
                        ? '${(_radius / 1000).toStringAsFixed(1)}km'
                        : '${_radius.round()}m',
                    onChanged: (v) => setState(() => _radius = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('100m',
                        style: TextStyle(
                            fontFamily: 'Lexend', fontSize: 10,
                            color: Color(0xFF9CA3AF))),
                    Text('5km',
                        style: TextStyle(
                            fontFamily: 'Lexend', fontSize: 10,
                            color: Color(0xFF9CA3AF))),
                  ],
                ),
                const SizedBox(height: 14),

                _label('Địa chỉ'),
                _textField(_addressCtrl, 'Tự điền khi chọn vị trí...',
                    readOnly: true),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(24, 4, 24, 20 + keyboardInset),
          child: Row(children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Lưu'),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  double _mapRadius() => (_radius / 30).clamp(5.0, 80.0);

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      _toast('Vui lòng nhập tên vùng');
      return;
    }
    widget.onSave(
      _nameCtrl.text.trim(),
      _selectedPoint.latitude,
      _selectedPoint.longitude,
      _radius,
      _addressCtrl.text.trim(),
    );
    Navigator.pop(context);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF006D5B))),
      );

  Widget _textField(TextEditingController ctrl, String hint,
      {bool readOnly = false}) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      style: const TextStyle(
          fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00ACB2), width: 1.5),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SAFE ZONE DETAIL SCREEN (redesigned) – inline in same file
// ═══════════════════════════════════════════════════════════════════
class SafeZoneDetailRedesigned extends StatefulWidget {
  final String zoneId;
  const SafeZoneDetailRedesigned({super.key, required this.zoneId});

  @override
  State<SafeZoneDetailRedesigned> createState() =>
      _SafeZoneDetailRedesignedState();
}

class _SafeZoneDetailRedesignedState extends State<SafeZoneDetailRedesigned> {
  SafeZone? get _zone => SafeZoneProvider.of(context).getZone(widget.zoneId);

  void _confirmDelete() {
    final zone = _zone;
    if (zone == null) return;
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xóa vùng an toàn',
      content: 'Bạn có chắc muốn xóa "${zone.name}"?',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () {
        SafeZoneProvider.read(context).removeZone(zone.id);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final zone = _zone;
    if (zone == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: Text('Vùng không tồn tại',
                style: TextStyle(fontFamily: 'Lexend'))),
      );
    }

    final center = LatLng(zone.latitude, zone.longitude);
    final radiusLabel = zone.radius >= 1000
        ? '${(zone.radius / 1000).toStringAsFixed(zone.radius % 1000 == 0 ? 0 : 1)} km'
        : '${zone.radius.round()} m';
    final members = SafeZoneProvider.of(context).members;
    final appliedMembers = members
        .where((m) => zone.recipientIds.contains(m.id))
        .toList();
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72 + topInset),
        child: SafeArea(
          bottom: false,
          child: AppBackHeaderBar(
            title: zone.name,
            trailing: GestureDetector(
              onTap: () => Navigator.of(context)
                  .pushNamed(AppRoutes.safeZoneEdit, arguments: zone.id),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.kPrimaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 18, color: Color(0xFF00ACB2)),
              ),
            ),
            trailingAreaWidth: 44,
          ),
        ),
      ),
      body: Column(children: [

        // Map — 50% of remaining height
        Expanded(
          flex: 5,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              interactionOptions:
                  const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.figma_app',
              ),
              CircleLayer(circles: [
                CircleMarker(
                  point: center,
                  radius: (zone.radius / 10).clamp(15.0, 120.0),
                  color: const Color(0x2200ACB2),
                  borderColor: const Color(0xFF00ACB2),
                  borderStrokeWidth: 2,
                ),
              ]),
              MarkerLayer(markers: [
                Marker(
                  point: center,
                  width: 36,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ACB2),
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: Colors.white),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x3300ACB2),
                            blurRadius: 8,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ],
          ),
        ),

        // Info panel — 50% of remaining height
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x1400ACB2),
                    blurRadius: 20,
                    offset: Offset(0, -4)),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Address
                    _infoRow(Icons.location_on_rounded, 'Địa chỉ',
                        zone.address),
                    const SizedBox(height: 14),

                    // Radius
                    _infoRow(Icons.radar_rounded, 'Bán kính', radiusLabel),
                    const SizedBox(height: 14),

                    // Status
                    _infoRow(
                      zone.isActive
                          ? Icons.check_circle_rounded
                          : Icons.pause_circle_rounded,
                      'Trạng thái',
                      zone.isActive ? 'Đang hoạt động' : 'Đã tắt',
                    ),
                    const SizedBox(height: 14),

                    // Members
                    const Text('Thành viên được áp dụng',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006D5B),
                        )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: appliedMembers.map((m) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(m.name,
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF00ACB2),
                              )),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Delete button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _confirmDelete,
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444), size: 20),
                        label: const Text('Xóa vùng'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side:
                              BorderSide(color: const Color(0xFFEF4444).withAlpha(50)),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.kPrimaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF00ACB2)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 11,
                    color: Color(0xFF9CA3AF))),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B))),
          ],
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════
// AVATAR PAINTER
// ═══════════════════════════════════════════════════════════════════








