import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// ============================================================
/// UNIFIED SAFE ZONE ADD SCREEN
/// Gộp 3 màn hình (Add + Info + Config) vào 1 screen dạng step
/// Architecture: Scaffold → Stack → [Map, DraggableScrollableSheet]
/// 3 bước: Vị trí & Bán kính → Thông tin vùng → Cấu hình cảnh báo
/// ============================================================
class SafeZoneAddScreen extends StatefulWidget {
  const SafeZoneAddScreen({
    super.key,
    this.initialMemberId,
  });

  final String? initialMemberId;

  @override
  State<SafeZoneAddScreen> createState() => _SafeZoneAddScreenState();
}

class _SafeZoneAddScreenState extends State<SafeZoneAddScreen>
    with SingleTickerProviderStateMixin {
  // -- Step control
  int _currentStep = 0; // 0=Location, 1=Info, 2=Config
  final _sheetController = DraggableScrollableController();

  // -- Step 1: Location & Radius
  double _radius = 500;
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _searchFocus = FocusNode();
  final _nameFocus = FocusNode();

  // -- Step 2: Zone Information
  final _zoneNameCtrl = TextEditingController(text: 'Nhà của tôi');
  int _selectedRadiusChip = 2;
  final List<String> _radiusOptions = ['50m', '100m', '500m', '1km', '2km'];
  int _selectedZoneType = 0;
  bool _timeBasedEnabled = true;
  late AnimationController _toggleCtrl;

  // -- Step 3: Alert Configuration
  int _configRadius = 0;
  final List<String> _configRadiusOptions = ['50m', '100m', '200m', '500m'];
  bool _leaveAlert = true;
  bool _enterAlert = true;
  bool _stayLongAlert = false;
  List<_Contact> _contacts = const [];
  bool _contactsInitialized = false;

  String get _radiusLabel {
    if (_radius >= 1000) return '${(_radius / 1000).toStringAsFixed(1)}km';
    return '${_radius.round()}m';
  }

  @override
  void initState() {
    super.initState();
    _toggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _timeBasedEnabled ? 1.0 : 0.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_contactsInitialized) {
      return;
    }
    _contactsInitialized = true;
    _loadContactsFromService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _zoneNameCtrl.dispose();
    _searchFocus.dispose();
    _nameFocus.dispose();
    _toggleCtrl.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleTimeBased() {
    setState(() => _timeBasedEnabled = !_timeBasedEnabled);
    _timeBasedEnabled ? _toggleCtrl.forward() : _toggleCtrl.reverse();
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _sheetController.animateTo(
        0.65,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      final selectedContact = _selectedContact;
      if (selectedContact == null) {
        _showMessage('Vui long chon thanh vien de ap dung vung an toan.');
        return;
      }

      // Map _selectedZoneType index to SafeZoneType enum
      const typeMap = [SafeZoneType.home, SafeZoneType.school, SafeZoneType.hospital, SafeZoneType.custom];
      final service = SafeZoneProvider.read(context);
      const latitude = 10.7769;
      const longitude = 106.7009;
      final address = _searchController.text.trim().isEmpty
          ? '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}'
          : _searchController.text.trim();
      final newZone = SafeZone(
        id: service.nextZoneId(),
        name: _zoneNameCtrl.text.trim().isEmpty ? 'Vùng mới' : _zoneNameCtrl.text.trim(),
        targetUid: selectedContact.id,
        address: address,
        latitude: latitude,
        longitude: longitude,
        radius: _radius,
        zoneType: typeMap[_selectedZoneType],
        isActive: true,
        timeBasedEnabled: _timeBasedEnabled,
        alertConfig: AlertConfig(
          leaveAlert: _leaveAlert,
          enterAlert: _enterAlert,
          stayLongAlert: _stayLongAlert,
        ),
        recipientIds: [selectedContact.id],
      );
      final created = await service.addZone(newZone);
      if (!mounted) {
        return;
      }
      if (created == null) {
        _showMessage(service.lastErrorMessage ?? 'Khong tao duoc vung an toan.');
        return;
      }
      _showMessage('Da them vung an toan "${created.name}".');
      Navigator.of(context).maybePop();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _sheetController.animateTo(
        _currentStep == 0 ? 0.42 : 0.65,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            _buildMapArea(),
            _buildAppBar(topPadding),
            if (_currentStep == 0)
              Positioned(
                top: topPadding + 72,
                left: 16,
                right: 16,
                child: _buildSearchBar(),
              ),
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).size.height * 0.45 + 16,
              child: _buildGpsButton(),
            ),
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.42,
              minChildSize: 0.20,
              maxChildSize: 0.85,
              snap: true,
              snapSizes: const [0.20, 0.42, 0.65, 0.85],
              builder: (context, scrollController) {
                return Container(
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0x0C00ACB2)),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x1E000000),
                        blurRadius: 30,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDragHandle(),
                      _buildStepIndicator(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 100,
                          ),
                          children: _buildStepContent(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _buildBottomButtons(),
            ),
          ],
        ),
      ),
    );
  }

  _Contact? get _selectedContact {
    for (final contact in _contacts) {
      if (contact.checked) {
        return contact;
      }
    }
    return null;
  }

  void _loadContactsFromService() {
    final members = SafeZoneProvider.of(context).members;
    if (members.isEmpty) {
      _contacts = const [];
      return;
    }

    final preferredId = widget.initialMemberId;
    final contacts = <_Contact>[];
    var hasPreferred = false;
    for (var index = 0; index < members.length; index++) {
      final member = members[index];
      final isPreferred = preferredId != null && member.id == preferredId;
      if (isPreferred) {
        hasPreferred = true;
      }
      contacts.add(
        _Contact(
          id: member.id,
          name: member.name,
          initials: _initialsOf(member.name),
          color: member.badgeTextColor,
          checked: isPreferred || (preferredId == null && index == 0),
        ),
      );
    }

    if (!hasPreferred && preferredId != null && contacts.isNotEmpty) {
      contacts[0] = contacts[0].copyWith(checked: true);
    }

    _contacts = contacts;
  }

  String _initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'TV';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // == COMMON WIDGETS ==

  Widget _buildAppBar(double topPadding) {
    const titles = [
      'Thêm vùng an toàn mới',
      'Thông tin vùng an toàn',
      'Cấu hình cảnh báo',
    ];
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: AppBackHeaderBar(
          title: titles[_currentStep],
          backgroundColor: Colors.transparent,
          onBack: _prevStep,
          trailingAreaWidth: 72,
          trailing: _currentStep > 0
              ? TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      color: const Color(0xFF00ACB2),
                      fontSize: ResponsiveHelper.sp(context, 16),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 48, height: 6,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x3300ACB2),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF00ACB2)
                    : isDone
                        ? const Color(0x9900ACB2)
                        : const Color(0x3300ACB2),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButtons() {
    const labels = ['Tiếp tục', 'Tiếp tục', 'Lưu cấu hình'];
    return Container(
      padding: EdgeInsets.only(
        top: 16, left: 16, right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(width: 1, color: Color(0x1900ACB2)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00ACB2),
                  side: const BorderSide(width: 1, color: Color(0xFF00ACB2)),
                  minimumSize: const Size(0, 56),
                ),
                child: const Text('Quay lại'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: ElevatedButton.icon(
              onPressed: _nextStep,
              icon: _currentStep == 2
                  ? const Icon(Icons.save_rounded, size: 20)
                  : (_currentStep < 2
                      ? const Icon(Icons.arrow_forward_rounded, size: 20)
                      : const SizedBox.shrink()),
              iconAlignment: _currentStep < 2 ? IconAlignment.end : IconAlignment.start,
              label: Text(labels[_currentStep]),
            ),
          ),
        ],
      ),
    );
  }

  // == MAP ==

  Widget _buildMapArea() {
    const defaultCenter = LatLng(10.7769, 106.7009);
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: defaultCenter,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.figma_app',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: defaultCenter,
                    radius: _radius / 10,
                    color: const Color(0x3300ACB2),
                    borderColor: const Color(0xFF00ACB2),
                    borderStrokeWidth: 4,
                  ),
                ],
              ),
            ],
          ),
          // Resize handle on right edge of circle
          Positioned(
            right: (MediaQuery.of(context).size.width - 220) / 2 - 12,
            child: Container(
              width: 24, height: 24,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2, color: Color(0xFF00ACB2)),
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: const [
                  BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
                ],
              ),
            ),
          ),
          // Location pin at center
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF00ACB2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x19000000), blurRadius: 10, offset: Offset(0, 8), spreadRadius: -6),
                  ],
                ),
                child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
              ),
              Container(
                width: 4, height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF00ACB2),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 47,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x1900ACB2)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
          BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: TextStyle(
          color: const Color(0xFF0C1D1A),
          fontSize: ResponsiveHelper.sp(context, 16),
          fontFamily: 'Lexend',
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm địa chỉ hoặc vị trí...',
          hintStyle: TextStyle(
            color: const Color(0x9900ACB2),
            fontSize: ResponsiveHelper.sp(context, 16),
            fontFamily: 'Lexend',
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0x9900ACB2), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGpsButton() {
    return Container(
      width: 48, height: 48,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x1900ACB2)),
          borderRadius: BorderRadius.circular(9999),
        ),
        shadows: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 10, offset: Offset(0, 8), spreadRadius: -6),
        ],
      ),
      child: const Icon(Icons.my_location_rounded, color: Color(0xFF00ACB2), size: 22),
    );
  }

  // == STEP CONTENT ROUTER ==

  List<Widget> _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep1Content();
      case 1: return _buildStep2Content();
      case 2: return _buildStep3Content();
      default: return [];
    }
  }

  // == STEP 1: Vi tri & Ban kinh ==

  List<Widget> _buildStep1Content() {
    return [
      Text(
        'TÊN VÙNG AN TOÀN',
        style: TextStyle(
          color: const Color(0xFF00ACB2),
          fontSize: ResponsiveHelper.sp(context, 14),
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.70,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity, height: 56,
        decoration: ShapeDecoration(
          color: AppColors.background,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x3300ACB2)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: TextField(
          controller: _nameController,
          focusNode: _nameFocus,
          style: TextStyle(
            color: const Color(0xFF0C1D1A),
            fontSize: ResponsiveHelper.sp(context, 16),
            fontFamily: 'Lexend',
          ),
          decoration: InputDecoration(
            hintText: 'Ví dụ: Nhà riêng, Công viên...',
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: ResponsiveHelper.sp(context, 16),
              fontFamily: 'Lexend',
            ),
            prefixIcon: const Icon(Icons.edit_location_alt_rounded, color: Color(0xFF00ACB2), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BÁN KÍNH VÙNG AN TOÀN',
              style: TextStyle(
                color: const Color(0xFF00ACB2),
                fontSize: ResponsiveHelper.sp(context, 14),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: 0.70,
              ),
            ),
            Text(
              _radiusLabel,
              style: TextStyle(
                color: const Color(0xFF00ACB2),
                fontSize: ResponsiveHelper.sp(context, 18),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      SliderTheme(
        data: SliderThemeData(
          activeTrackColor: const Color(0xFF00ACB2),
          inactiveTrackColor: const Color(0x3300ACB2),
          thumbColor: const Color(0xFF00ACB2),
          overlayColor: const Color(0x1900ACB2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          trackHeight: 8,
        ),
        child: Slider(
          value: _radius, min: 100, max: 1000, divisions: 18,
          onChanged: (v) => setState(() => _radius = v),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sliderLabel('100m'),
            _sliderLabel('500m'),
            _sliderLabel('1000m'),
          ],
        ),
      ),
    ];
  }

  Widget _sliderLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0x9900ACB2),
        fontSize: ResponsiveHelper.sp(context, 12),
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w500,
        height: 1.33,
      ),
    );
  }

  // == STEP 2: Thong tin vung an toan ==

  List<Widget> _buildStep2Content() {
    return [
      _buildSectionLabel('TÊN VÙNG'),
      const SizedBox(height: 12),
      _buildZoneNameField(),
      const SizedBox(height: 32),
      _buildSectionLabel('ĐỊA CHỈ'),
      const SizedBox(height: 12),
      _buildAddressField(),
      const SizedBox(height: 32),
      _buildRadiusHeader(),
      const SizedBox(height: 16),
      _buildRadiusChips(),
      const SizedBox(height: 32),
      _buildSectionLabel('LOẠI VÙNG'),
      const SizedBox(height: 16),
      _buildZoneTypeGrid(),
      const SizedBox(height: 32),
      _buildTimeBasedCard(),
    ];
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xCC00ACB2),
          fontSize: ResponsiveHelper.sp(context, 14),
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.70,
        ),
      ),
    );
  }

  Widget _buildZoneNameField() {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x1900ACB2), blurRadius: 0, offset: Offset(0, 0), spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.edit_location_alt_rounded, color: Color(0xFF00ACB2), size: 22),
          ),
          Expanded(
            child: TextField(
              controller: _zoneNameCtrl,
              style: TextStyle(
                color: const Color(0xFF0C1D1A),
                fontSize: ResponsiveHelper.sp(context, 16),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                border: InputBorder.none,
                hintText: 'Nhập tên vùng...',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0x7FF3F4F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.location_on_rounded, color: Color(0xFF6B7280), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '123 Đường Lê Lợi, Quận 1, TP. Hồ Chí Minh',
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: ResponsiveHelper.sp(context, 16),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'BÁN KÍNH',
            style: TextStyle(
              color: const Color(0xCC00ACB2),
              fontSize: ResponsiveHelper.sp(context, 14),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              height: 1.43,
              letterSpacing: 0.70,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: ShapeDecoration(
              color: const Color(0x1900ACB2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
            ),
            child: Text(
              'Tùy chỉnh',
              style: TextStyle(
                color: const Color(0xFF00ACB2),
                fontSize: ResponsiveHelper.sp(context, 12),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusChips() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: List.generate(_radiusOptions.length, (i) {
        final isSelected = i == _selectedRadiusChip;
        return GestureDetector(
          onTap: () => setState(() => _selectedRadiusChip = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: isSelected ? 2 : 1,
                  color: isSelected ? const Color(0xFF00ACB2) : const Color(0x0C00ACB2),
                ),
                borderRadius: BorderRadius.circular(9999),
              ),
              shadows: const [
                BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
                BoxShadow(color: Color(0x0C00ACB2), blurRadius: 0, offset: Offset(0, 0), spreadRadius: 1),
              ],
            ),
            child: Text(
              _radiusOptions[i],
              style: TextStyle(
                color: isSelected ? const Color(0xFF00ACB2) : const Color(0xFF4B5563),
                fontSize: ResponsiveHelper.sp(context, 14),
                fontFamily: 'Lexend',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                height: 1.43,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildZoneTypeGrid() {
    final zoneTypes = [
      _ZoneType(label: 'Nhà', icon: Icons.home_rounded, iconBg: const Color(0xFFEFF6FF), iconColor: const Color(0xFF3B82F6)),
      _ZoneType(label: 'Trường học', icon: Icons.school_rounded, iconBg: const Color(0xFFFFFBEB), iconColor: const Color(0xFFD97706)),
      _ZoneType(label: 'Bệnh viện', icon: Icons.local_hospital_rounded, iconBg: const Color(0xFFFFF1F2), iconColor: const Color(0xFFF43F5E)),
      _ZoneType(label: 'Tùy chỉnh', icon: Icons.tune_rounded, iconBg: const Color(0xFFF8FAFC), iconColor: const Color(0xFF64748B)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
      ),
      itemCount: zoneTypes.length,
      itemBuilder: (_, i) {
        final z = zoneTypes[i];
        final isSelected = i == _selectedZoneType;
        return GestureDetector(
          onTap: () => setState(() => _selectedZoneType = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 2,
                  color: isSelected ? const Color(0xFF00ACB2) : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? z.iconBg : z.iconBg.withValues(alpha: 0.70),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(z.icon, color: isSelected ? z.iconColor : z.iconColor.withValues(alpha: 0.60), size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  z.label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0C1D1A) : const Color(0xFF6B7280),
                    fontSize: ResponsiveHelper.sp(context, 14),
                    fontFamily: 'Lexend',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeBasedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x0C00ACB2)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Color(0x1900ACB2), shape: BoxShape.circle),
                child: const Icon(Icons.schedule_rounded, color: Color(0xFF00ACB2), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hoạt động theo giờ', style: TextStyle(
                      color: const Color(0xFF0C1D1A),
                      fontSize: ResponsiveHelper.sp(context, 16),
                      fontFamily: 'Lexend', fontWeight: FontWeight.w700, height: 1.50,
                    )),
                    Text('Chỉ thông báo trong khung giờ này', style: TextStyle(
                      color: const Color(0xFF9CA3AF),
                      fontSize: ResponsiveHelper.sp(context, 12),
                      fontFamily: 'Lexend', fontWeight: FontWeight.w400, height: 1.33,
                    )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggleTimeBased,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48, height: 24,
                  decoration: BoxDecoration(
                    color: _timeBasedEnabled ? const Color(0xFF00ACB2) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: _timeBasedEnabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 20, height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        border: Border.all(width: 1, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _timeBasedEnabled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF9FAFB), thickness: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Khung giờ hiện tại', style: TextStyle(
                      color: const Color(0xFF4B5563),
                      fontSize: ResponsiveHelper.sp(context, 14),
                      fontFamily: 'Lexend', fontWeight: FontWeight.w500, height: 1.43,
                    )),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.safeZoneTimeRules),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: ShapeDecoration(
                          color: const Color(0x0C00ACB2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('08:00 - 18:00', style: TextStyle(
                              color: const Color(0xFF00ACB2),
                              fontSize: ResponsiveHelper.sp(context, 16),
                              fontFamily: 'Lexend', fontWeight: FontWeight.w700, height: 1.50,
                            )),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF00ACB2), size: 20),
                          ],
                        ),
                      ),
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

  // == STEP 3: Cau hinh canh bao ==

  List<Widget> _buildStep3Content() {
    return [
      _buildZoneInfoCard(),
      const SizedBox(height: 24),
      _buildConfigSectionTitle('Bán kính vùng an toàn'),
      const SizedBox(height: 12),
      _buildConfigRadiusChips(),
      const SizedBox(height: 24),
      _buildConfigSectionTitle('Thông báo thông minh'),
      const SizedBox(height: 12),
      _buildSmartAlertsCard(),
      const SizedBox(height: 24),
      _buildRecipientsHeader(),
      const SizedBox(height: 12),
      _buildRecipientsCard(),
    ];
  }

  Widget _buildConfigSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF0C1D1A),
          fontSize: ResponsiveHelper.sp(context, 16),
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
      ),
    );
  }

  Widget _buildZoneInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x0C00ACB2)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64, height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0x1900ACB2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IgnorePointer(
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(10.7769, 106.7009),
                  initialZoom: 14,
                  interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.figma_app',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nhà riêng', style: TextStyle(
                  color: const Color(0xFF00ACB2),
                  fontSize: ResponsiveHelper.sp(context, 18),
                  fontFamily: 'Lexend', fontWeight: FontWeight.w700, height: 1.56,
                )),
                const SizedBox(height: 4),
                Text('123 Đường ABC, Quận 1, TP.\nHCM', style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: ResponsiveHelper.sp(context, 14),
                  fontFamily: 'Lexend', fontWeight: FontWeight.w400, height: 1.63,
                )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _currentStep = 1),
            child: const Icon(Icons.edit_rounded, color: Color(0xFF00ACB2), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRadiusChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_configRadiusOptions.length, (i) {
          final isSelected = i == _configRadius;
          return Padding(
            padding: EdgeInsets.only(right: i < _configRadiusOptions.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _configRadius = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.horizontalPadding(context)),
                decoration: ShapeDecoration(
                  color: isSelected ? const Color(0xFF00ACB2) : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: isSelected ? const Color(0xFF00ACB2) : const Color(0x1900ACB2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: isSelected ? const [
                    BoxShadow(color: Color(0x3300ACB2), blurRadius: 4, offset: Offset(0, 2), spreadRadius: -2),
                    BoxShadow(color: Color(0x3300ACB2), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -1),
                  ] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  _configRadiusOptions[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    fontSize: ResponsiveHelper.sp(context, 16),
                    fontFamily: 'Lexend', fontWeight: FontWeight.w500, height: 1.50,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSmartAlertsCard() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x0C00ACB2)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          _buildAlertRow(icon: Icons.logout_rounded, iconBg: const Color(0xFFFEF2F2), iconColor: const Color(0xFFEF4444), label: 'Rời vùng', value: _leaveAlert, onToggle: (v) => setState(() => _leaveAlert = v), showDivider: false),
          _buildAlertRow(icon: Icons.login_rounded, iconBg: const Color(0xFFEFF6FF), iconColor: const Color(0xFF3B82F6), label: 'Vào vùng', value: _enterAlert, onToggle: (v) => setState(() => _enterAlert = v), showDivider: true),
          _buildAlertRow(icon: Icons.timer_rounded, iconBg: const Color(0xFFFFFBEB), iconColor: const Color(0xFFD97706), label: 'Ở lại quá lâu', value: _stayLongAlert, onToggle: (v) => setState(() => _stayLongAlert = v), showDivider: true),
        ],
      ),
    );
  }

  Widget _buildAlertRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required bool value,
    required ValueChanged<bool> onToggle,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: showDivider ? const BoxDecoration(
        border: Border(top: BorderSide(width: 1, color: Color(0x0C00ACB2))),
      ) : null,
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(
              color: const Color(0xFF0C1D1A),
              fontSize: ResponsiveHelper.sp(context, 16),
              fontFamily: 'Lexend', fontWeight: FontWeight.w500, height: 1.50,
            )),
          ),
          GestureDetector(
            onTap: () => onToggle(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF00ACB2) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20, height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    border: Border.all(width: 1, color: value ? Colors.white : const Color(0xFFD1D5DB)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Người thân', style: TextStyle(
            color: const Color(0xFF0C1D1A),
            fontSize: ResponsiveHelper.sp(context, 16),
            fontFamily: 'Lexend', fontWeight: FontWeight.w700, height: 1.50,
          )),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.safeZoneSelectMember),
            child: Text('+ Thêm mới', style: TextStyle(
              color: const Color(0xFF00ACB2),
              fontSize: ResponsiveHelper.sp(context, 14),
              fontFamily: 'Lexend', fontWeight: FontWeight.w400, height: 1.43,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsCard() {
    if (_contacts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x0C00ACB2)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Chua co thanh vien da xac nhan de ap dung vung an toan.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontFamily: 'Lexend',
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x0C00ACB2)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: List.generate(_contacts.length, (i) {
          final c = _contacts[i];
          return GestureDetector(
            onTap: () => setState(() {
              _contacts = [
                for (var index = 0; index < _contacts.length; index++)
                  _contacts[index].copyWith(checked: index == i),
              ];
            }),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: i > 0 ? const BoxDecoration(
                border: Border(top: BorderSide(width: 1, color: Color(0x0C00ACB2))),
              ) : null,
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                    child: CustomPaint(painter: _AvatarPainter(initials: c.initials, color: c.color)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(c.name, style: TextStyle(
                      color: const Color(0xFF0C1D1A),
                      fontSize: ResponsiveHelper.sp(context, 16),
                      fontFamily: 'Lexend', fontWeight: FontWeight.w500, height: 1.50,
                    )),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22, height: 22,
                    decoration: ShapeDecoration(
                      color: c.checked ? const Color(0xFF00ACB2) : Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: c.checked ? const Color(0xFF00ACB2) : const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: c.checked ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// == DATA MODELS ==

class _ZoneType {
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  const _ZoneType({required this.label, required this.icon, required this.iconBg, required this.iconColor});
}

class _Contact {
  final String id;
  final String name;
  final String initials;
  final Color color;
  final bool checked;

  const _Contact({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
    required this.checked,
  });

  _Contact copyWith({
    String? id,
    String? name,
    String? initials,
    Color? color,
    bool? checked,
  }) {
    return _Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      color: color ?? this.color,
      checked: checked ?? this.checked,
    );
  }
}

// == CUSTOM PAINTERS ==

class _AvatarPainter extends CustomPainter {
  final String initials;
  final Color color;
  const _AvatarPainter({required this.initials, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, Paint()..color = color.withValues(alpha: 0.15));
    final tp = TextPainter(
      text: TextSpan(text: initials, style: TextStyle(color: color, fontSize: size.width * 0.35, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) => old.initials != initials || old.color != color;
}


