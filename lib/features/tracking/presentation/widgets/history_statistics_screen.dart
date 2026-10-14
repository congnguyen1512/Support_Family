import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/theme.dart';

class HistoryStatisticsScreen extends StatefulWidget {
  const HistoryStatisticsScreen({super.key});

  @override
  State<HistoryStatisticsScreen> createState() => _HistoryStatisticsScreenState();
}

class _HistoryStatisticsScreenState extends State<HistoryStatisticsScreen> {
  static const _members = ['Bà Lan', 'Ông Hùng', 'Bé Bo'];
  static const _months = [
    'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
    'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
    'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];

  String selectedMember = 'Bà Lan';
  int _selectedMonthIndex = 9; // Tháng 10
  int _selectedYear = 2023;
  int currentDay = 5;

  String get selectedMonth => '${_months[_selectedMonthIndex]}, $_selectedYear';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [AppColors.kPrimaryLight, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFilters(),
                      _buildStatisticsGrid(),
                      _buildCalendar(),
                      _buildRecentActivity(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.80),
                shape: RoundedRectangleBorder(
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
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF0C1D1A),
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 40),
              child: Text(
                'Lịch sử & Thống kê',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0C1D1A),
                  fontSize: ResponsiveHelper.sp(context, 18),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showMemberPicker,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0x3300ACB2),
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
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: ShapeDecoration(
                        image: const DecorationImage(
                          image: NetworkImage("https://placehold.co/32x32"),
                          fit: BoxFit.cover,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedMember,
                        style: TextStyle(
                          color: Color(0xFF0C1D1A),
                          fontSize: ResponsiveHelper.sp(context, 14),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showMonthPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0x3300ACB2),
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
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedMonth,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0C1D1A),
                      fontSize: ResponsiveHelper.sp(context, 14),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
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

  void _showMemberPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Chọn thành viên',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF0C1D1A),
              ),
            ),
            const SizedBox(height: 8),
            ..._members.map((m) => ListTile(
              leading: CircleAvatar(
                backgroundColor: m == selectedMember
                    ? AppColors.primary
                    : const Color(0xFFE5E7EB),
                child: Text(
                  m[0],
                  style: TextStyle(
                    color: m == selectedMember ? Colors.white : const Color(0xFF6B7280),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                m,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: m == selectedMember ? FontWeight.w700 : FontWeight.w400,
                  color: const Color(0xFF0C1D1A),
                ),
              ),
              trailing: m == selectedMember
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => selectedMember = m);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() {
    int tempMonth = _selectedMonthIndex;
    int tempYear = _selectedYear;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setSheetState(() => tempYear--),
                      child: const Icon(Icons.chevron_left, color: AppColors.primary),
                    ),
                    Text(
                      '$tempYear',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF0C1D1A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setSheetState(() => tempYear++),
                      child: const Icon(Icons.chevron_right, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, i) {
                    final isSel = i == tempMonth;
                    return GestureDetector(
                      onTap: () => setSheetState(() => tempMonth = i),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppColors.primary : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          'Th ${i + 1}',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 13,
                            color: isSel ? Colors.white : const Color(0xFF0C1D1A),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedMonthIndex = tempMonth;
                        _selectedYear = tempYear;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.horizontalPadding(context)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Hoàn thành',
                  '45',
                  Icons.check_circle,
                  const Color(0xFFDCFCE7),
                  const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Bỏ lỡ',
                  '3',
                  Icons.cancel,
                  const Color(0xFFFEE2E2),
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Đúng giờ',
                  '92%',
                  Icons.access_time,
                  const Color(0xFFDBEAFE),
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Trung bình',
                  '08:15',
                  Icons.schedule,
                  const Color(0xFFFEF9C3),
                  const Color(0xFFEAB308),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x1900ACB2),
          ),
          borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: ResponsiveHelper.sp(context, 12),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: ShapeDecoration(
                  color: bgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: value == '08:15' ? const Color(0xFF1F2937) : const Color(0xFF0C1D1A),
              fontSize: ResponsiveHelper.sp(context, 24),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x1900ACB2),
          ),
          borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedMonth,
                style: TextStyle(
                  color: Color(0xFF0C1D1A),
                  fontSize: ResponsiveHelper.sp(context, 14),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedMonthIndex == 0) {
                          _selectedMonthIndex = 11;
                          _selectedYear--;
                        } else {
                          _selectedMonthIndex--;
                        }
                      });
                    },
                    child: Icon(
                      Icons.chevron_left,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedMonthIndex == 11) {
                          _selectedMonthIndex = 0;
                          _selectedYear++;
                        } else {
                          _selectedMonthIndex++;
                        }
                      });
                    },
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) => Expanded(
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: ResponsiveHelper.sp(context, 10),
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarDays() {
    return Column(
      children: [
        _buildCalendarRow([26, 27, 28, 29, 30, 1, 2], [false, false, false, false, false, true, true]),
        const SizedBox(height: 12),
        _buildCalendarRow([3, 4, 5, 6, 7, 8, 9], [true, true, true, true, true, true, true], [
          [const Color(0xFF22C55E)],
          [const Color(0xFF22C55E), const Color(0xFFEF4444)],
          [const Color(0xFF22C55E), const Color(0xFFEAB308)],
          [],
          [],
          [],
          [],
        ]),
        const SizedBox(height: 12),
        _buildCalendarRow([10, 11, 12, 13, 14, 15, 0], [true, true, true, true, true, true, false]),
      ],
    );
  }

  Widget _buildCalendarRow(List<int> days, List<bool> isCurrentMonth, [List<List<Color>>? indicators]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final day = days[index];
        final isCurrent = isCurrentMonth[index];
        final isSelected = day == currentDay && isCurrent;
        final dayIndicators = indicators != null && index < indicators.length ? indicators[index] : <Color>[];

        return Expanded(
          child: Container(
            alignment: Alignment.center,
            child: day == 0 
              ? Text(
                  '...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0C1D1A),
                    fontSize: ResponsiveHelper.sp(context, 14),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isSelected ? 28 : null,
                      height: isSelected ? 28 : null,
                      decoration: isSelected ? ShapeDecoration(
                        color: AppColors.primary,
                        shape: RoundedRectangleBorder(
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
                      ) : null,
                      alignment: Alignment.center,
                      child: Text(
                        day.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected 
                            ? Colors.white
                            : isCurrent 
                              ? const Color(0xFF0C1D1A)
                              : const Color(0xFFD1D5DB),
                          fontSize: ResponsiveHelper.sp(context, 14),
                          fontFamily: 'Lexend',
                          fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ),
                    if (dayIndicators.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: dayIndicators.map((color) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: ShapeDecoration(
                              color: color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
          ),
        );
      }),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoạt động gần đây',
            style: TextStyle(
              color: Color(0xFF0C1D1A),
              fontSize: ResponsiveHelper.sp(context, 16),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Uống thuốc huyết áp',
            '08:00 • Hôm nay',
            'Hoàn thành',
            const Color(0xFF22C55E),
            const Color(0xFFDCFCE7),
            const Color(0xFF15803D),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Ăn sáng',
            '07:00 • Hôm nay',
            'Hoàn thành',
            const Color(0xFF22C55E),
            const Color(0xFFDCFCE7),
            const Color(0xFF15803D),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Đo huyết áp',
            '16:00 • Hôm qua',
            'Bỏ lỡ',
            const Color(0xFFEF4444),
            const Color(0xFFFEE2E2),
            const Color(0xFFB91C1C),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    String status,
    Color borderColor,
    Color statusBgColor,
    Color statusTextColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 4,
            color: borderColor,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF0C1D1A),
                    fontSize: ResponsiveHelper.sp(context, 14),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: ResponsiveHelper.sp(context, 12),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: ShapeDecoration(
              color: statusBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusTextColor,
                fontSize: ResponsiveHelper.sp(context, 10),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


