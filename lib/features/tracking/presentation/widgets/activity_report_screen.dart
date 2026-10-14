import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'dart:math' as math;
import 'package:family_guard/core/theme/theme.dart';
import 'package:family_guard/core/routes/app_routes.dart';

import 'package:family_guard/features/tracking/data/datasources/health_tracking_remote_data_source.dart';
import 'package:family_guard/features/tracking/data/models/health_report_model.dart';

class ActivityReportArgs {
  final String? memberId;
  final String? memberName;
  final String? avatarUrl;

  const ActivityReportArgs({
    this.memberId,
    this.memberName,
    this.avatarUrl,
  });
}

class ActivityReportScreen extends StatefulWidget {
  final ActivityReportArgs? args;
  const ActivityReportScreen({super.key, this.args});

  @override
  State<ActivityReportScreen> createState() => _ActivityReportScreenState();
}

class _ActivityReportScreenState extends State<ActivityReportScreen> {
  final HealthTrackingRemoteDataSource _dataSource =
      HealthTrackingRemoteDataSourceImpl();

  ActivityReportArgs? _args;
  HealthReportModel? _report;
  bool _isLoading = true;
  String selectedPeriod = 'Tháng này';

  @override
  void initState() {
    super.initState();
    _args = widget.args;
    _fetchReport();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is ActivityReportArgs) {
        _args = routeArgs;
        _fetchReport();
      }
    }
  }

  String _periodToKey(String p) {
    switch (p) {
      case 'Hôm nay':
        return 'today';
      case 'Tuần này':
        return 'week';
      case 'Tháng này':
      default:
        return 'month';
    }
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final rep = await _dataSource.getReport(
        memberUid: _args?.memberId,
        period: _periodToKey(selectedPeriod),
      );
      if (mounted) {
        setState(() {
          _report = rep;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 102),
                        child: Column(
                          children: [
                            _buildCompletionRateCard(),
                            const SizedBox(height: 16),
                            _buildStatsRow(),
                            const SizedBox(height: 16),
                            _buildRecentReminders(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        border: const Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0x1900ACB2),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Báo cáo hoạt động',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: ResponsiveHelper.sp(context, 18),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.historyStatistics);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.filter_list,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveHelper.horizontalPadding(context),
              right: ResponsiveHelper.horizontalPadding(context),
              bottom: 8,
            ),
            child: Row(
              children: [
                _buildPeriodChip('Hôm nay'),
                const SizedBox(width: 8),
                _buildPeriodChip('Tuần này'),
                const SizedBox(width: 8),
                _buildPeriodChip('Tháng này'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label) {
    final isSelected = selectedPeriod == label;
    return GestureDetector(
      onTap: () {
        if (selectedPeriod != label) {
          setState(() {
            selectedPeriod = label;
          });
          _fetchReport();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.primary : const Color(0x1900ACB2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontSize: ResponsiveHelper.sp(context, 14),
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionRateCard() {
    final memberDisplayName =
        _report?.memberName ?? (_args?.memberName ?? 'Thành viên');
    final count = _report?.totalReminders ?? 120;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x0C00ACB2),
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
          Text(
            'Tỷ lệ hoàn thành của $memberDisplayName',
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: ResponsiveHelper.sp(context, 20),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dựa trên $count lời nhắc trong $selectedPeriod',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: ResponsiveHelper.sp(context, 14),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressCircle(),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    final comp = (_report?.completionRate ?? 95).toDouble();
    final late = (_report?.lateRate ?? 3).toDouble();

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(180, 180),
            painter: CircularProgressPainter(
              completionPercentage: comp,
              latePercentage: late,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_report?.completionRate ?? 95}%',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: ResponsiveHelper.sp(context, 30),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.20,
                  ),
                ),
                const Text(
                  'TỶ LỆ',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                    letterSpacing: 0.50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Đúng giờ',
              '${_report?.onTimeRate ?? 95}%',
              _report?.onTimeChange ?? '1%',
              AppColors.primary,
              const Color(0xFF10B981),
              true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Trễ',
              '${_report?.lateRate ?? 3}%',
              _report?.lateChange ?? '0.5%',
              const Color(0xFFF59E0B),
              const Color(0xFFEF4444),
              false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Bỏ lỡ',
              '${_report?.missedRate ?? 2}%',
              _report?.missedChange ?? '0.5%',
              const Color(0xFFEF4444),
              const Color(0xFF10B981),
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String change,
    Color labelColor,
    Color changeColor,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x0C00ACB2),
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
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: ResponsiveHelper.sp(context, 12),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: ResponsiveHelper.sp(context, 20),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeColor,
                size: 12,
              ),
              Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontSize: ResponsiveHelper.sp(context, 10),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReminders() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 8,
        left: 22,
        right: 22,
        bottom: 16,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nhắc nhở gần đây',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: ResponsiveHelper.sp(context, 16),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.historyStatistics);
                  },
                  child: Text(
                    'Xem tất cả',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: ResponsiveHelper.sp(context, 14),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_report != null && _report!.recentLogs.isNotEmpty)
            ..._report!.recentLogs.map((log) {
              final iconData = _getLogIcon(log.category);
              final iconColor = _getLogIconColor(log.category);
              final statusColor = _getLogStatusColor(log.status);
              final statusLabel = _getLogStatusLabel(log.status);
              final timeStr = _formatLogTime(log.scheduledAt);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReminderItem(
                  log.title,
                  timeStr,
                  statusLabel,
                  log.detail.isNotEmpty ? log.detail : statusLabel,
                  iconData,
                  iconColor.withAlpha(25),
                  iconColor,
                  statusColor.withAlpha(25),
                  statusColor,
                ),
              );
            })
          else ...[
            _buildReminderItem(
              'Uống thuốc huyết áp',
              'Hôm nay • 08:00 AM',
              'HOÀN THÀNH',
              '08:02 AM',
              Icons.medication,
              const Color(0x1900ACB2),
              AppColors.primary,
              const Color(0x1910B981),
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _buildReminderItem(
              'Đo đường huyết',
              'Hôm nay • 10:00 AM',
              'BỎ LỠ',
              'Không thực hiện',
              Icons.bloodtype,
              const Color(0x19EF4444),
              const Color(0xFFEF4444),
              const Color(0x19EF4444),
              const Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            _buildReminderItem(
              'Đi bộ nhẹ nhàng',
              'Hôm qua • 05:00 PM',
              'HOÀN THÀNH TRỄ',
              '05:45 PM',
              Icons.directions_walk,
              const Color(0x19F59E0B),
              const Color(0xFFF59E0B),
              const Color(0x19F59E0B),
              const Color(0xFFF59E0B),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getLogIcon(String category) {
    switch (category) {
      case 'vitals':
        return Icons.bloodtype;
      case 'activity':
        return Icons.directions_walk;
      case 'checkup':
        return Icons.local_hospital;
      case 'medicine':
      default:
        return Icons.medication;
    }
  }

  Color _getLogIconColor(String category) {
    switch (category) {
      case 'vitals':
        return const Color(0xFF00ACB2);
      case 'activity':
        return const Color(0xFFF59E0B);
      case 'checkup':
        return const Color(0xFF8B5CF6);
      case 'medicine':
      default:
        return AppColors.primary;
    }
  }

  Color _getLogStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'late':
        return const Color(0xFFF59E0B);
      case 'missed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getLogStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'HOÀN THÀNH';
      case 'late':
        return 'HOÀN THÀNH TRỄ';
      case 'missed':
        return 'BỎ LỠ';
      default:
        return 'CHỜ THỰC HIỆN';
    }
  }

  String _formatLogTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month • $hour:$min';
  }

  Widget _buildReminderItem(
    String title,
    String time,
    String status,
    String detail,
    IconData icon,
    Color iconBgColor,
    Color iconColor,
    Color statusBgColor,
    Color statusTextColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x0C00ACB2),
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
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: iconBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: ResponsiveHelper.sp(context, 14),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
                Text(
                  time,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              const SizedBox(height: 4),
              Text(
                detail,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: ResponsiveHelper.sp(context, 10),
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double completionPercentage;
  final double latePercentage;

  CircularProgressPainter({
    required this.completionPercentage,
    required this.latePercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 30) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawCircle(center, radius, bgPaint);

    // Completion arc (green/teal)
    final completionPaint = Paint()
      ..color = const Color(0xFF00ACB2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final completionSweepAngle = 2 * math.pi * (completionPercentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      completionSweepAngle,
      false,
      completionPaint,
    );

    // Late arc (orange)
    final latePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final lateSweepAngle = 2 * math.pi * (latePercentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + completionSweepAngle,
      lateSweepAngle,
      false,
      latePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


