import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// ============================================================
/// SAFE ZONE TIME RULES SCREEN - Lịch hoạt động vùng an toàn
/// Được dịch và sửa lỗi từ Figma Dev Mode export
/// ============================================================
class SafeZoneTimeRulesScreen extends StatefulWidget {
  const SafeZoneTimeRulesScreen({super.key});

  @override
  State<SafeZoneTimeRulesScreen> createState() =>
      _SafeZoneTimeRulesScreenState();
}

class _SafeZoneTimeRulesScreenState extends State<SafeZoneTimeRulesScreen> {
  bool _scheduleEnabled = true;

  // Ngày trong tuần: true = được chọn
  final Map<String, bool> _days = {
    'T2': true,
    'T3': true,
    'T4': true,
    'T5': true,
    'T6': true,
    'T7': false,
    'CN': false,
  };

  // Danh sách khung giờ
  final List<String> _timeSlots = ['08:00 - 17:00'];

  // Mẫu đang chọn
  String _selectedPreset = 'Giờ học (08:00 - 17:00)';

  final List<String> _presets = [
    'Giờ học (08:00 - 17:00)',
    'Giờ làm (08:00 - 18:00)',
    'Tùy chỉnh',
  ];

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _addTimeSlot() async {
    final start = await _pickTime(const TimeOfDay(hour: 8, minute: 0));
    if (start == null || !mounted) return;
    final end = await _pickTime(const TimeOfDay(hour: 17, minute: 0));
    if (end == null || !mounted) return;
    setState(() => _timeSlots.add('${_fmt(start)} - ${_fmt(end)}'));
  }

  Future<void> _editTimeSlot(int index) async {
    final parts = _timeSlots[index].split(' - ');
    final sParts = parts[0].split(':');
    final eParts = parts[1].split(':');
    final startInit = TimeOfDay(hour: int.parse(sParts[0]), minute: int.parse(sParts[1]));
    final endInit = TimeOfDay(hour: int.parse(eParts[0]), minute: int.parse(eParts[1]));

    final start = await _pickTime(startInit);
    if (start == null || !mounted) return;
    final end = await _pickTime(endInit);
    if (end == null || !mounted) return;
    setState(() => _timeSlots[index] = '${_fmt(start)} - ${_fmt(end)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Colors.white, AppColors.kPrimaryLight],
          ),
        ),
        child: Column(
          children: [
            // ── AppBar ─────────────────────────────────────────
            _buildAppBar(context),

            // ── Nội dung cuộn ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle card
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _buildToggleCard(),
                    ),

                    if (_scheduleEnabled) ...[
                      // Chọn ngày
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildDayPicker(),
                      ),

                      // Khung giờ hoạt động
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildTimeSlotsSection(),
                      ),

                      // Mẫu thiết lập sẵn
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildPresetsSection(),
                      ),

                      // Xem trước lịch trình
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildSchedulePreview(),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom bar nút lưu ──────────────────────────────
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── AppBar tuỳ chỉnh ──────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AppBackHeaderBar(
        title: 'Lịch hoạt động vùng an toàn',
        onBack: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  // ── Toggle "Chỉ hoạt động trong khoảng thời gian" ─────────────────
  Widget _buildToggleCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x3300ACB2)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text bên trái
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chỉ hoạt động trong khoảng\nthời gian nhất định',
                  style: TextStyle(
                    color: Color(0xFF0C4A40),
                    fontSize: ResponsiveHelper.sp(context, 16),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bật để giới hạn thời gian giám sát',
                  style: TextStyle(
                    color: Color(0xFF00ACB2),
                    fontSize: ResponsiveHelper.sp(context, 14),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Toggle switch
          GestureDetector(
            onTap: () => setState(() => _scheduleEnabled = !_scheduleEnabled),
            child: SizedBox(
              width: 44,
              height: 24,
              child: Stack(
                children: [
                  Container(
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _scheduleEnabled
                          ? const Color(0xFF00ACB2)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: _scheduleEnabled ? 22 : 2,
                    top: 2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chọn ngày trong tuần ──────────────────────────────────────────
  Widget _buildDayPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn ngày trong tuần',
          style: TextStyle(
            color: Color(0xFF0C4A40),
            fontSize: ResponsiveHelper.sp(context, 16),
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _days.entries.map((entry) {
            final isSelected = entry.value;
            return GestureDetector(
              onTap: () => setState(() => _days[entry.key] = !entry.value),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: isSelected ? const Color(0xFF00ACB2) : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: isSelected
                        ? BorderSide.none
                        : const BorderSide(
                            width: 1, color: Color(0x3300ACB2)),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  shadows: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  entry.key,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF0C4A40),
                    fontSize: ResponsiveHelper.sp(context, 14),
                    fontFamily: 'Lexend',
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    height: 1.43,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Khung giờ hoạt động ───────────────────────────────────────────
  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + nút thêm
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Khung giờ hoạt động',
              style: TextStyle(
                color: Color(0xFF0C4A40),
                fontSize: ResponsiveHelper.sp(context, 16),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addTimeSlot(),
              icon: Icon(
                Icons.add_rounded,
                color: Color(0xFF00ACB2),
                size: 18,
              ),
              label: Text(
                'Thêm khung giờ',
                style: TextStyle(
                  color: Color(0xFF00ACB2),
                  fontSize: ResponsiveHelper.sp(context, 14),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Danh sách khung giờ
        ..._timeSlots.asMap().entries.map((e) => _buildTimeSlotCard(e.key, e.value)),
      ],
    );
  }

  Widget _buildTimeSlotCard(int index, String slot) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x3300ACB2)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Giờ + icon clock
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0x1900ACB2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF00ACB2),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                slot,
                style: TextStyle(
                  color: Color(0xFF0C4A40),
                  fontSize: ResponsiveHelper.sp(context, 18),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                ),
              ),
            ],
          ),
          // Nút edit + delete
          Row(
            children: [
              // Edit
              GestureDetector(
                onTap: () => _editTimeSlot(index),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              GestureDetector(
                onTap: () {
                  setState(() => _timeSlots.remove(slot));
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mẫu thiết lập sẵn ─────────────────────────────────────────────
  Widget _buildPresetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mẫu thiết lập sẵn',
          style: TextStyle(
            color: Color(0xFF0C4A40),
            fontSize: ResponsiveHelper.sp(context, 16),
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _presets.map((preset) {
              final isSelected = preset == _selectedPreset;
              return GestureDetector(
                onTap: () => setState(() => _selectedPreset = preset),
                child: Container(
                  margin: EdgeInsets.only(right: 8),
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: ShapeDecoration(
                    color: isSelected ? const Color(0xFF00ACB2) : Colors.white,
                    shape: RoundedRectangleBorder(
                      side: isSelected
                          ? BorderSide.none
                          : const BorderSide(
                              width: 1, color: Color(0x3300ACB2)),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    shadows: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      preset,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF0C4A40),
                        fontSize: ResponsiveHelper.sp(context, 14),
                        fontFamily: 'Lexend',
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Xem trước lịch trình (bar chart) ──────────────────────────────
  Widget _buildSchedulePreview() {
    final dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xem trước lịch trình',
          style: TextStyle(
            color: Color(0xFF0C4A40),
            fontSize: ResponsiveHelper.sp(context, 16),
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x1900ACB2)),
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Biểu đồ cột
              SizedBox(
                height: 128,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(7, (i) {
                    final dayKey = dayLabels[i];
                    final isActive = _days[dayKey] ?? false;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 6 ? 4 : 0),
                        child: isActive
                            ? Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xCC00ACB2),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              // Nhãn ngày bên dưới
              Row(
                children: List.generate(7, (i) {
                  return Expanded(
                    child: Text(
                      dayLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: ResponsiveHelper.sp(context, 10),
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom bar nút lưu ────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 1, color: Color(0xFFF3F4F6))),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _saveAndReturn,
          child: const Text('Lưu lịch hoạt động'),
        ),
      ),
    );
  }

  /// Lưu và trả kết quả về parent screen (Fix #1: dead-end)
  void _saveAndReturn() {
    // Đóng gói kết quả để trả về parent (SafeZoneAdd / SafeZoneDetail)
    final result = {
      'enabled': _scheduleEnabled,
      'days': Map<String, bool>.from(_days),
      'timeSlots': List<String>.from(_timeSlots),
      'selectedPreset': _selectedPreset,
    };
    Navigator.of(context).pop(result);
  }
}


