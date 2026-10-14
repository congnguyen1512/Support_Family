import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/theme.dart';

// ── Data models ──────────────────────────────────────────────────────

class _Member {
  final String id;
  final String name;
  final Color color;

  const _Member({required this.id, required this.name, required this.color});
}

enum _EventType { enter, leave }

class _ZoneEvent {
  final String id;
  final String memberId;
  final _EventType type;
  final DateTime dateTime;
  final String zoneName;
  final String address;
  final double lat;
  final double lng;
  final Duration? stayDuration;
  bool expanded = false;

  _ZoneEvent({
    required this.id,
    required this.memberId,
    required this.type,
    required this.dateTime,
    required this.zoneName,
    required this.address,
    this.lat = 10.7769,
    this.lng = 106.7009,
    this.stayDuration,
  });

  bool get isSafe => type == _EventType.enter;
}

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  // ── State ────────────────────────────────────────────────────────
  late List<_Member> _members;
  late List<_ZoneEvent> _events;
  String _selectedMemberId = 'm1';
  String _selectedFilter = 'Tất cả';
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _members = const [
      _Member(id: 'm1', name: 'Bà Lan', color: Color(0xFF00ACB2)),
      _Member(id: 'm2', name: 'Ông Hùng', color: Color(0xFF3B82F6)),
      _Member(id: 'm3', name: 'Bé Bo', color: Color(0xFFF59E0B)),
    ];

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    _events = [
      // Hôm nay
      _ZoneEvent(
        id: 'e1', memberId: 'm1', type: _EventType.enter,
        dateTime: today.add(const Duration(hours: 10, minutes: 45)),
        zoneName: 'Nhà riêng', address: '123 Đường Lê Lợi, Quận 1',
        lat: 10.7769, lng: 106.7009, stayDuration: const Duration(hours: 2, minutes: 15),
      ),
      _ZoneEvent(
        id: 'e2', memberId: 'm1', type: _EventType.leave,
        dateTime: today.add(const Duration(hours: 8, minutes: 15)),
        zoneName: 'Chợ Bến Thành', address: 'Quận 1, TP. Hồ Chí Minh',
        lat: 10.7725, lng: 106.6980,
      ),
      _ZoneEvent(
        id: 'e3', memberId: 'm2', type: _EventType.enter,
        dateTime: today.add(const Duration(hours: 9, minutes: 30)),
        zoneName: 'Bệnh viện Chợ Rẫy', address: '201B Nguyễn Chí Thanh, Quận 5',
        lat: 10.7556, lng: 106.6595, stayDuration: const Duration(hours: 1, minutes: 30),
      ),
      _ZoneEvent(
        id: 'e4', memberId: 'm3', type: _EventType.leave,
        dateTime: today.add(const Duration(hours: 7, minutes: 0)),
        zoneName: 'Trường Tiểu học', address: '45 Nguyễn Du, Quận 1',
        lat: 10.7800, lng: 106.6950,
      ),
      // Hôm qua
      _ZoneEvent(
        id: 'e5', memberId: 'm1', type: _EventType.leave,
        dateTime: yesterday.add(const Duration(hours: 17, minutes: 30)),
        zoneName: 'Công viên Tao Đàn', address: 'Quận 1, TP. Hồ Chí Minh',
        lat: 10.7743, lng: 106.6922,
      ),
      _ZoneEvent(
        id: 'e6', memberId: 'm1', type: _EventType.enter,
        dateTime: yesterday.add(const Duration(hours: 14, minutes: 0)),
        zoneName: 'Công viên Tao Đàn', address: 'Quận 1, TP. Hồ Chí Minh',
        lat: 10.7743, lng: 106.6922, stayDuration: const Duration(hours: 3, minutes: 30),
      ),
      _ZoneEvent(
        id: 'e7', memberId: 'm2', type: _EventType.enter,
        dateTime: yesterday.add(const Duration(hours: 8, minutes: 45)),
        zoneName: 'Nhà riêng', address: '56 Trần Hưng Đạo, Quận 5',
        lat: 10.7556, lng: 106.6700, stayDuration: const Duration(hours: 5),
      ),
      // 2 ngày trước
      _ZoneEvent(
        id: 'e8', memberId: 'm3', type: _EventType.enter,
        dateTime: twoDaysAgo.add(const Duration(hours: 16, minutes: 20)),
        zoneName: 'Nhà riêng', address: '789 Lý Thường Kiệt, Quận 10',
        lat: 10.7730, lng: 106.6620, stayDuration: const Duration(hours: 4),
      ),
      _ZoneEvent(
        id: 'e9', memberId: 'm1', type: _EventType.leave,
        dateTime: twoDaysAgo.add(const Duration(hours: 11, minutes: 10)),
        zoneName: 'Siêu thị CoopMart', address: 'Quận 3, TP. Hồ Chí Minh',
        lat: 10.7800, lng: 106.6860,
      ),
      _ZoneEvent(
        id: 'e10', memberId: 'm2', type: _EventType.leave,
        dateTime: twoDaysAgo.add(const Duration(hours: 6, minutes: 30)),
        zoneName: 'Bệnh viện Chợ Rẫy', address: '201B Nguyễn Chí Thanh, Quận 5',
        lat: 10.7556, lng: 106.6595,
      ),
    ];
  }

  // ── Derived data ─────────────────────────────────────────────────

  List<_ZoneEvent> get _filteredEvents {
    return _events.where((e) {
      if (e.memberId != _selectedMemberId) return false;
      if (e.dateTime.month != _selectedMonth || e.dateTime.year != _selectedYear) return false;
      if (_selectedFilter == 'Vào vùng' && e.type != _EventType.enter) return false;
      if (_selectedFilter == 'Rời vùng' && e.type != _EventType.leave) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Map<String, List<_ZoneEvent>> get _groupedEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final grouped = <String, List<_ZoneEvent>>{};

    for (final e in _filteredEvents) {
      final d = DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
      String label;
      if (d == today) {
        label = 'HÔM NAY, ${e.dateTime.day.toString().padLeft(2, '0')}/${e.dateTime.month.toString().padLeft(2, '0')}';
      } else if (d == yesterday) {
        label = 'HÔM QUA, ${e.dateTime.day.toString().padLeft(2, '0')}/${e.dateTime.month.toString().padLeft(2, '0')}';
      } else {
        label = '${e.dateTime.day.toString().padLeft(2, '0')}/${e.dateTime.month.toString().padLeft(2, '0')}/${e.dateTime.year}';
      }
      grouped.putIfAbsent(label, () => []).add(e);
    }
    return grouped;
  }

  String get _monthLabel {
    const months = [
      '', 'Tháng 01', 'Tháng 02', 'Tháng 03', 'Tháng 04', 'Tháng 05',
      'Tháng 06', 'Tháng 07', 'Tháng 08', 'Tháng 09', 'Tháng 10',
      'Tháng 11', 'Tháng 12',
    ];
    return '${months[_selectedMonth]}, $_selectedYear';
  }

  // ── Actions ──────────────────────────────────────────────────────

  void _showMonthPicker() {
    int tmpMonth = _selectedMonth;
    int tmpYear = _selectedYear;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chọn tháng', style: TextStyle(
                    color: const Color(0xFF0C1D1A), fontSize: 18,
                    fontFamily: 'Lexend', fontWeight: FontWeight.w700,
                  )),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(Icons.close, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setBS(() => tmpYear--),
                    icon: Icon(Icons.chevron_left, color: AppColors.primary),
                  ),
                  Text('$tmpYear', style: TextStyle(
                    fontSize: 18, fontFamily: 'Lexend', fontWeight: FontWeight.w700,
                    color: const Color(0xFF0C1D1A),
                  )),
                  IconButton(
                    onPressed: () => setBS(() => tmpYear++),
                    icon: Icon(Icons.chevron_right, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 8, crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: List.generate(12, (i) {
                  final m = i + 1;
                  final sel = m == tmpMonth;
                  return GestureDetector(
                    onTap: () => setBS(() => tmpMonth = m),
                    child: Container(
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? AppColors.primary : const Color(0xFFE5E7EB),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text('Th ${m.toString().padLeft(2, '0')}', style: TextStyle(
                        color: sel ? Colors.white : const Color(0xFF6B7280),
                        fontSize: 13, fontFamily: 'Lexend', fontWeight: FontWeight.w600,
                      )),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() { _selectedMonth = tmpMonth; _selectedYear = tmpYear; });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Xác nhận'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddActivitySheet() {
    final nameCtrl = TextEditingController();
    _EventType selectedType = _EventType.enter;
    double duration = 60; // minutes
    TimeOfDay startTime = TimeOfDay.now();
    List<int> selectedDays = [1, 2, 3, 4, 5]; // T2-T6

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.kPrimaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_location_alt_rounded,
                        color: Color(0xFF00ACB2), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Thêm hoạt động',
                      style: TextStyle(
                        fontFamily: 'Lexend', fontSize: 18,
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
                      // Tên hoạt động
                      _sheetLabel('Tên hoạt động'),
                      TextField(
                        controller: nameCtrl,
                        style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
                        decoration: _sheetInputDecor('Nhập tên vùng / hoạt động...'),
                      ),
                      const SizedBox(height: 16),

                      // Loại hoạt động
                      _sheetLabel('Loại hoạt động'),
                      Row(children: [
                        _typeChip(setBS, 'Vào vùng', _EventType.enter, selectedType,
                            (t) => selectedType = t),
                        const SizedBox(width: 10),
                        _typeChip(setBS, 'Rời vùng', _EventType.leave, selectedType,
                            (t) => selectedType = t),
                      ]),
                      const SizedBox(height: 16),

                      // Thời lượng
                      _sheetLabel('Thời lượng: ${duration >= 60 ? '${(duration / 60).toStringAsFixed(1)} giờ' : '${duration.round()} phút'}'),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF00ACB2),
                          inactiveTrackColor: const Color(0xFF00ACB2).withAlpha(30),
                          thumbColor: const Color(0xFF00ACB2),
                          overlayColor: const Color(0xFF00ACB2).withAlpha(30),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: duration,
                          min: 15, max: 480, divisions: 31,
                          onChanged: (v) => setBS(() => duration = v),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Giờ bắt đầu
                      _sheetLabel('Giờ bắt đầu'),
                      GestureDetector(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: startTime,
                            builder: (c, child) => Theme(
                              data: Theme.of(c).copyWith(
                                colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF00ACB2)),
                              ),
                              child: child!,
                            ),
                          );
                          if (t != null) setBS(() => startTime = t);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.access_time_rounded,
                                size: 18, color: Color(0xFF00ACB2)),
                            const SizedBox(width: 8),
                            Text(
                              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  fontFamily: 'Lexend', fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B)),
                            ),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 20, color: Color(0xFF9CA3AF)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ngày lặp
                      _sheetLabel('Ngày lặp'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) {
                          final day = (i + 1) % 7; // 1=T2..6=T7,0=CN
                          final labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                          final isOn = selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () => setBS(() {
                              if (isOn) {
                                selectedDays.remove(day);
                              } else {
                                selectedDays.add(day);
                              }
                            }),
                            child: Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: isOn
                                    ? const Color(0xFF00ACB2)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isOn
                                      ? const Color(0xFF00ACB2)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Center(
                                child: Text(labels[day],
                                    style: TextStyle(
                                      fontFamily: 'Lexend', fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isOn
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    )),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Buttons
              Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 4, 24, 20 + MediaQuery.of(ctx).viewInsets.bottom),
                child: Row(children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Hủy'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(ctx)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                content: Text('Vui lòng nhập tên hoạt động',
                                    style: TextStyle(fontFamily: 'Lexend')),
                                backgroundColor: Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                              ));
                            return;
                          }
                          final now = DateTime.now();
                          final dt = DateTime(now.year, now.month, now.day,
                              startTime.hour, startTime.minute);
                          setState(() {
                            _events.add(_ZoneEvent(
                              id: 'e${_events.length + 1}',
                              memberId: _selectedMemberId,
                              type: selectedType,
                              dateTime: dt,
                              zoneName: name,
                              address: '',
                              stayDuration: selectedType == _EventType.enter
                                  ? Duration(minutes: duration.round())
                                  : null,
                            ));
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text('Đã thêm thành công',
                                  style: const TextStyle(
                                      fontFamily: 'Lexend',
                                      color: Colors.white)),
                              backgroundColor: const Color(0xFF00ACB2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ));
                        },
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
        },
      ),
    );
  }

  Widget _sheetLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Lexend', fontSize: 13,
                fontWeight: FontWeight.w600, color: Color(0xFF006D5B))),
      );

  InputDecoration _sheetInputDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Lexend', fontSize: 14, color: Color(0xFF9CA3AF)),
        filled: true, fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      );

  Widget _typeChip(StateSetter setBS, String label, _EventType type,
      _EventType selected, ValueChanged<_EventType> onSelect) {
    final isActive = type == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => setBS(() => onSelect(type)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF00ACB2) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFF00ACB2) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == _EventType.enter
                    ? Icons.login_rounded
                    : Icons.logout_rounded,
                size: 16,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Lexend', fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF6B7280),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    Color pickedColor = const Color(0xFFEC4899);
    final palette = const [
      Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFFF59E0B),
      Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFFEF4444),
    ];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Thêm thành viên', style: TextStyle(
            fontFamily: 'Lexend', fontWeight: FontWeight.w700, fontSize: 18,
            color: const Color(0xFF0C1D1A),
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Nhập tên', hintStyle: TextStyle(color: const Color(0xFF9CA3AF)),
                  filled: true, fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                  ),
                ),
                style: TextStyle(fontFamily: 'Lexend'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: palette.map((c) => GestureDetector(
                  onTap: () => setDlg(() => pickedColor = c),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: Border.all(
                        color: pickedColor == c ? const Color(0xFF0C1D1A) : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Hủy', style: TextStyle(color: const Color(0xFF6B7280), fontFamily: 'Lexend')),
            ),
            ElevatedButton(
              onPressed: () {
                final n = nameCtrl.text.trim();
                if (n.isEmpty) return;
                setState(() {
                  _members.add(_Member(
                    id: 'm${_members.length + 1}',
                    name: n, color: pickedColor,
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivitySheet,
        backgroundColor: const Color(0xFF00ACB2),
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, -0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [AppColors.kPrimaryLight, AppColors.background],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 24,
                      left: ResponsiveHelper.horizontalPadding(context),
                      right: ResponsiveHelper.horizontalPadding(context)),
                  child: Column(
                    children: [
                      _buildFilterTabs(),
                      const SizedBox(height: 24),
                      _buildTimeline(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        border: const Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0x1900ACB2),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 40),
                      child: Text(
                        'Lịch sử hoạt động',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF0C1D1A),
                          fontSize: ResponsiveHelper.sp(context, 18),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          letterSpacing: -0.45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildMemberSelector(),
            const SizedBox(height: 16),
            _buildDateSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.horizontalPadding(context),
          vertical: 12),
      child: Row(
        children: [
          ..._members.map((m) {
            final isSel = m.id == _selectedMemberId;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Opacity(
                opacity: isSel ? 1.0 : 0.60,
                child: _buildMemberAvatar(m, isSelected: isSel),
              ),
            );
          }),
          Opacity(
            opacity: 0.40,
            child: _buildAddMember(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(_Member member, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMemberId = member.id;
        });
      },
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: ShapeDecoration(
                color: member.color.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 0,
                          offset: const Offset(0, 0),
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  member.name.characters.first,
                  style: TextStyle(
                    color: member.color,
                    fontSize: 22,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              member.name,
              style: TextStyle(
                color: isSelected ? AppColors.primary : const Color(0xFF0C1D1A),
                fontSize: ResponsiveHelper.sp(context, 12),
                fontFamily: 'Lexend',
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMember() {
    return GestureDetector(
      onTap: _showAddMemberDialog,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: ShapeDecoration(
                color: const Color(0xFFF9FAFB),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 2,
                    color: Color(0xFF9CA3AF),
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF9CA3AF),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm',
              style: TextStyle(
                color: const Color(0xFF0C1D1A),
                fontSize: ResponsiveHelper.sp(context, 12),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w500,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.horizontalPadding(context)),
      child: GestureDetector(
        onTap: _showMonthPicker,
        child: Container(
          width: double.infinity,
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.horizontalPadding(context)),
          decoration: ShapeDecoration(
            color: const Color(0x1900ACB2),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0x3300ACB2),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _monthLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF00ACB2),
                  fontSize: ResponsiveHelper.sp(context, 14),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                  letterSpacing: 0.35,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFilterTabs() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x3300ACB2),
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterTab('Tất cả')),
          Expanded(child: _buildFilterTab('Rời vùng')),
          Expanded(child: _buildFilterTab('Vào vùng')),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          shadows: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontSize: ResponsiveHelper.sp(context, 12),
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final grouped = _groupedEvents;
    if (grouped.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text('Không có hoạt động', style: TextStyle(
              color: const Color(0xFF9CA3AF), fontSize: 16,
              fontFamily: 'Lexend', fontWeight: FontWeight.w500,
            )),
          ],
        ),
      );
    }

    final dayKeys = grouped.keys.toList();
    return Column(
      children: [
        for (int d = 0; d < dayKeys.length; d++) ...[
          if (d > 0) const SizedBox(height: 24),
          _buildTimelineBadge(dayKeys[d], dayKeys[d].startsWith('HÔM NAY')),
          const SizedBox(height: 16),
          ...grouped[dayKeys[d]]!.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTimelineItem(event: e),
          )),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTimelineBadge(String label, bool isToday) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isToday ? const Color(0x3300ACB2) : const Color(0xFFF3F4F6),
            ),
            borderRadius: BorderRadius.circular(9999),
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
        child: Text(
          label,
          style: TextStyle(
            color: isToday ? AppColors.primary : const Color(0xFF9CA3AF),
            fontSize: ResponsiveHelper.sp(context, 14),
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            height: 1.43,
            letterSpacing: 1.40,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({required _ZoneEvent event}) {
    final isEnter = event.type == _EventType.enter;
    final pinColor = isEnter ? AppColors.primary : const Color(0xFFF43F5E);
    final iconColor = isEnter ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6);
    final timeStr = '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => setState(() => event.expanded = !event.expanded),
      child: Stack(
        children: [
          // Timeline line
          Positioned(
            left: 37,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.30),
              ),
            ),
          ),
          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    timeStr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isEnter ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                      fontSize: ResponsiveHelper.sp(context, 12),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Opacity(
                  opacity: isEnter ? 1.0 : 0.90,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0x1900ACB2),
                        ),
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
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: ShapeDecoration(
                                color: iconColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Icon(
                                isEnter ? Icons.home : Icons.exit_to_app,
                                color: isEnter
                                    ? const Color(0xFF047857)
                                    : const Color(0xFFF43F5E),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${isEnter ? "Vào vùng" : "Rời vùng"}: ${event.zoneName}',
                                    style: TextStyle(
                                      color: const Color(0xFF0C1D1A),
                                      fontSize: ResponsiveHelper.sp(context, 14),
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w700,
                                      height: 1.43,
                                    ),
                                  ),
                                  Text(
                                    event.address,
                                    style: TextStyle(
                                      color: const Color(0xFF6B7280),
                                      fontSize: ResponsiveHelper.sp(context, 11),
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isEnter)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFECFDF5),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFFD1FAE5),
                                    ),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                                child: Text(
                                  'AN TOÀN',
                                  style: TextStyle(
                                    color: const Color(0xFF047857),
                                    fontSize: ResponsiveHelper.sp(context, 10),
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFFFECACA),
                                    ),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                                child: Text(
                                  'CẢNH BÁO',
                                  style: TextStyle(
                                    color: const Color(0xFFDC2626),
                                    fontSize: ResponsiveHelper.sp(context, 10),
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildMapPreview(pinColor, isEnter),
                        // Expanded detail
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: event.expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: _buildEventDetail(event),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetail(_ZoneEvent event) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            _buildDetailRow(Icons.location_on_outlined, 'Tọa độ',
                '${event.lat.toStringAsFixed(4)}, ${event.lng.toStringAsFixed(4)}'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, 'Thời gian',
                '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')} - ${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}'),
            if (event.stayDuration != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.timer_outlined, 'Thời gian ở',
                  '${event.stayDuration!.inHours}h ${event.stayDuration!.inMinutes.remainder(60)}m'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(
          color: const Color(0xFF6B7280), fontSize: 12,
          fontFamily: 'Lexend', fontWeight: FontWeight.w500,
        )),
        Expanded(
          child: Text(value, style: TextStyle(
            color: const Color(0xFF0C1D1A), fontSize: 12,
            fontFamily: 'Lexend', fontWeight: FontWeight.w600,
          )),
        ),
      ],
    );
  }

  Widget _buildMapPreview(Color pinColor, bool isActive) {
    return Container(
      width: double.infinity,
      height: 96,
      decoration: ShapeDecoration(
        color: const Color(0xFFF3F4F6),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFF3F4F6),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Geofence circle
          Positioned(
            left: 15,
            top: 16,
            child: Container(
              width: isActive ? 58 : 64,
              height: 64,
              decoration: ShapeDecoration(
                color: pinColor.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: pinColor,
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
          // Location pin
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: ShapeDecoration(
                  color: pinColor,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                      spreadRadius: -3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


