import 'dart:math';
import 'package:flutter/material.dart';
import 'package:family_guard/core/widgets/app_dialog.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/utils/responsive/responsive_helper.dart';


import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/features/physical/data/datasources/physical_activity_remote_data_source.dart';

class PhysicalActivityArgs {
  final String? memberId;
  final String? memberName;
  final String? avatarUrl;

  const PhysicalActivityArgs({
    this.memberId,
    this.memberName,
    this.avatarUrl,
  });
}

/// Hoạt động thể chất – dashboard + quản lý lịch tập
class PhysicalActivityScreen extends StatefulWidget {
  final PhysicalActivityArgs? args;
  const PhysicalActivityScreen({super.key, this.args});

  @override
  State<PhysicalActivityScreen> createState() => _PhysicalActivityScreenState();
}

class _PhysicalActivityScreenState extends State<PhysicalActivityScreen>
    with TickerProviderStateMixin {
  final PhysicalActivityRemoteDataSource _dataSource =
      PhysicalActivityRemoteDataSourceImpl();

  // ── Dashboard data ──────────────────────────────────────────────
  int _steps = 0;
  int _calories = 0;
  int _minutes = 0;
  int _stepsGoal = 10000;
  int _caloriesGoal = 500;
  int _minutesGoal = 60;

  // ── Activities ──────────────────────────────────────────────────
  List<_Activity> _activities = [];
  bool _isLoading = true;
  PhysicalActivityArgs? _args;
  final Map<String, String> _memberNameToUid = {};

  // ── Form state ──────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  _ActivityType _formType = _ActivityType.walking;
  double _formDuration = 30;
  TimeOfDay? _formTime;
  Set<int> _formDays = {};
  String _formMember = '';
  List<String> _members = ['Tất cả thành viên'];

  // ── Animation ───────────────────────────────────────────────────
  late final AnimationController _progressAnim;

  @override
  void initState() {
    super.initState();
    _args = widget.args;
    _progressAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _loadInitial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is PhysicalActivityArgs) {
        _args = routeArgs;
        _loadInitial();
      }
    }
  }

  Future<void> _loadInitial() async {
    try {
      final rels = await AppDependencies.instance.getRelationshipsUseCase.call();
      final names = <String>[];
      for (final r in rels) {
        if (r.processing == 'xacnhan' && r.relationUser != null) {
          final uName = r.relationUser!.name;
          final uId = r.relationUser!.uid;
          names.add(uName);
          _memberNameToUid[uName] = uId;
        }
      }

      if (_args?.memberName != null && _args!.memberName!.isNotEmpty) {
        if (!names.contains(_args!.memberName!)) {
          names.insert(0, _args!.memberName!);
          if (_args?.memberId != null) {
            _memberNameToUid[_args!.memberName!] = _args!.memberId!;
          }
        }
      }

      if (names.isNotEmpty) {
        _members = names;
        _formMember = _args?.memberName ?? _members.first;
      }

      await _fetchData();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final metrics = await _dataSource.getMetrics(
        memberUid: _args?.memberId,
      );
      final activitiesData = await _dataSource.getActivities(
        memberUid: _args?.memberId,
      );

      if (mounted) {
        setState(() {
          _steps = metrics.steps;
          _stepsGoal = metrics.stepsGoal;
          _calories = metrics.calories;
          _caloriesGoal = metrics.caloriesGoal;
          _minutes = metrics.activeMinutes;
          _minutesGoal = metrics.minutesGoal;

          _activities = activitiesData.map((m) {
            return _Activity(
              id: m.id,
              name: m.name,
              type: _parseType(m.activityType),
              durationMin: m.durationMin,
              time: _parseTimeOfDay(m.activityTime),
              repeatDays: Set.from(m.repeatDays),
              member: m.memberName ?? (_args?.memberName ?? 'Thành viên'),
              memberUid: m.memberUid,
              enabled: m.enabled,
            );
          }).toList();
          _isLoading = false;
        });
        _progressAnim.forward(from: 0.0);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return const TimeOfDay(hour: 6, minute: 30);
    }
  }

  _ActivityType _parseType(String t) {
    switch (t) {
      case 'running':
        return _ActivityType.running;
      case 'cycling':
        return _ActivityType.cycling;
      case 'yoga':
        return _ActivityType.yoga;
      case 'swimming':
        return _ActivityType.swimming;
      case 'other':
        return _ActivityType.other;
      default:
        return _ActivityType.walking;
    }
  }

  String _typeToString(_ActivityType t) {
    switch (t) {
      case _ActivityType.running:
        return 'running';
      case _ActivityType.cycling:
        return 'cycling';
      case _ActivityType.yoga:
        return 'yoga';
      case _ActivityType.swimming:
        return 'swimming';
      case _ActivityType.other:
        return 'other';
      default:
        return 'walking';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _progressAnim.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────
  void _showToast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(fontFamily: 'Lexend', color: Colors.white)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        duration: const Duration(seconds: 2),
      ));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  IconData _typeIcon(_ActivityType t) => switch (t) {
        _ActivityType.walking => Icons.directions_walk_rounded,
        _ActivityType.running => Icons.directions_run_rounded,
        _ActivityType.cycling => Icons.directions_bike_rounded,
        _ActivityType.yoga => Icons.self_improvement_rounded,
        _ActivityType.swimming => Icons.pool_rounded,
        _ActivityType.other => Icons.fitness_center_rounded,
      };

  Color _typeColor(_ActivityType t) => switch (t) {
        _ActivityType.walking => AppColors.primary,
        _ActivityType.running => AppColors.info,
        _ActivityType.cycling => AppColors.warning,
        _ActivityType.yoga => const Color(0xFF8B5CF6),
        _ActivityType.swimming => const Color(0xFF06B6D4),
        _ActivityType.other => AppColors.textSecondary,
      };

  String _typeLabel(_ActivityType t) => switch (t) {
        _ActivityType.walking => 'Đi bộ',
        _ActivityType.running => 'Chạy bộ',
        _ActivityType.cycling => 'Đạp xe',
        _ActivityType.yoga => 'Yoga',
        _ActivityType.swimming => 'Bơi lội',
        _ActivityType.other => 'Khác',
      };

  static const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  String _repeatText(Set<int> days) {
    if (days.length == 7) return 'Hàng ngày';
    if (days.containsAll({1, 2, 3, 4, 5}) && days.length == 5) return 'Ngày thường';
    if (days.containsAll({6, 7}) && days.length == 2) return 'Cuối tuần';
    return days.map((d) => _dayLabels[d - 1]).join(', ');
  }

  // ── CRUD ────────────────────────────────────────────────────────
  void _addActivity() {
    _nameCtrl.clear();
    _formType = _ActivityType.walking;
    _formDuration = 30;
    _formTime = null;
    _formDays = {};
    _formMember = _args?.memberName ?? (_members.isNotEmpty ? _members.first : '');
    _showFormSheet(editIndex: null);
  }

  void _editActivity(int index) {
    final a = _activities[index];
    _nameCtrl.text = a.name;
    _formType = a.type;
    _formDuration = a.durationMin.toDouble();
    _formTime = a.time;
    _formDays = Set.from(a.repeatDays);
    _formMember = a.member;
    _showFormSheet(editIndex: index);
  }

  Future<void> _toggleActivity(int index, bool value) async {
    final a = _activities[index];
    setState(() => a.enabled = value);
    try {
      await _dataSource.toggleActivity(a.id, value);
    } catch (_) {}
    _showToast(
        value ? 'Đã bật ${a.name}' : 'Đã tắt ${a.name}');
  }

  void _deleteActivity(int index) {
    final a = _activities[index];
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xóa hoạt động',
      content: 'Xóa "${a.name}"?',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () async {
        setState(() => _activities.removeAt(index));
        try {
          await _dataSource.deleteActivity(a.id);
        } catch (_) {}
        _showToast('Đã xóa hoạt động');
      },
    );
  }

  // ── Form Bottom Sheet ───────────────────────────────────────────
  void _showFormSheet({required int? editIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityFormSheet(
        nameCtrl: _nameCtrl,
        type: _formType,
        duration: _formDuration,
        time: _formTime,
        days: _formDays,
        member: _formMember,
        members: _members,
        typeLabel: _typeLabel,
        typeIcon: _typeIcon,
        typeColor: _typeColor,
        dayLabels: _dayLabels,
        onTypeChanged: (t) => _formType = t,
        onDurationChanged: (d) => _formDuration = d,
        onTimeChanged: (t) => _formTime = t,
        onDaysChanged: (d) => _formDays = d,
        onMemberChanged: (m) => _formMember = m,
        onSave: () async {
          if (_nameCtrl.text.trim().isEmpty) {
            _showToast('Vui lòng nhập tên hoạt động');
            return;
          }
          if (_formTime == null) {
            _showToast('Vui lòng chọn giờ tập');
            return;
          }
          if (_formDays.isEmpty) {
            _showToast('Vui lòng chọn ít nhất 1 ngày');
            return;
          }

          final name = _nameCtrl.text.trim();
          final type = _formType;
          final duration = _formDuration.round();
          final time = _formTime!;
          final days = Set<int>.from(_formDays);
          final member = _formMember;
          final memberUid = _memberNameToUid[member] ?? _args?.memberId;

          Navigator.pop(context);

          if (editIndex != null) {
            final a = _activities[editIndex];
            setState(() {
              a.name = name;
              a.type = type;
              a.durationMin = duration;
              a.time = time;
              a.repeatDays = days;
              a.member = member;
            });
            try {
              final timeStr =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              await _dataSource.updateActivity(
                a.id,
                name: name,
                activityType: _typeToString(type),
                durationMin: duration,
                activityTime: timeStr,
                repeatDays: days.toList(),
                memberUid: memberUid,
              );
              _showToast('Đã cập nhật hoạt động');
            } catch (e) {
              _showToast('Lỗi cập nhật: $e');
            }
          } else {
            try {
              final timeStr =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              final created = await _dataSource.createActivity(
                name: name,
                activityTime: timeStr,
                activityType: _typeToString(type),
                durationMin: duration,
                repeatDays: days.toList(),
                memberUid: memberUid,
                enabled: true,
              );
              setState(() {
                _activities.insert(
                  0,
                  _Activity(
                    id: created.id,
                    name: created.name,
                    type: _parseType(created.activityType),
                    durationMin: created.durationMin,
                    time: time,
                    repeatDays: Set.from(created.repeatDays),
                    member: member.isNotEmpty ? member : (created.memberName ?? 'Thành viên'),
                    memberUid: created.memberUid,
                    enabled: created.enabled,
                  ),
                );
              });
              _showToast('Đã thêm hoạt động mới');
            } catch (e) {
              _showToast('Lỗi tạo hoạt động: $e');
            }
          }
        },
        isEditing: editIndex != null,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    children: [
                      _buildDashboard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Lịch tập luyện', _activities.length),
                      const SizedBox(height: 10),
                      ..._activities
                          .asMap()
                          .entries
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildActivityCard(e.value, e.key),
                              )),
                      if (_activities.isEmpty) _buildEmpty(),
                    ],
                  ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addActivity,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm hoạt động',
            style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.horizontalPadding(context),
        16,
        ResponsiveHelper.horizontalPadding(context),
        12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientStart, AppColors.background],
        ),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadowPrimary,
                    blurRadius: 8,
                    offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.primaryDark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Hoạt động thể chất',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: ResponsiveHelper.sp(context, 20),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Dashboard ───────────────────────────────────────────────────
  Widget _buildDashboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowPrimary,
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: -2),
        ],
      ),
      child: Column(children: [
        const Text('Hôm nay',
            style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _progressAnim,
          builder: (_, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRing(
                label: 'Bước chân',
                value: _steps,
                goal: _stepsGoal,
                unit: '',
                color: AppColors.primary,
                icon: Icons.directions_walk_rounded,
                progress: _progressAnim.value,
              ),
              _buildRing(
                label: 'Calo',
                value: _calories,
                goal: _caloriesGoal,
                unit: 'kcal',
                color: AppColors.warning,
                icon: Icons.local_fire_department_rounded,
                progress: _progressAnim.value,
              ),
              _buildRing(
                label: 'Phút',
                value: _minutes,
                goal: _minutesGoal,
                unit: 'phút',
                color: AppColors.info,
                icon: Icons.timer_rounded,
                progress: _progressAnim.value,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildRing({
    required String label,
    required int value,
    required int goal,
    required String unit,
    required Color color,
    required IconData icon,
    required double progress,
  }) {
    final ratio = (value / goal).clamp(0.0, 1.0);
    final animatedRatio = ratio * progress;
    final size = ResponsiveHelper.sp(context, 90).clamp(70.0, 110.0);
    return Column(children: [
      SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            ratio: animatedRatio,
            color: color,
            bgColor: color.withAlpha(30),
            strokeWidth: 6,
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 2),
              Text(
                '${(value * progress).round()}',
                style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(label,
          style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
      Text('$value / $goal ${unit.isNotEmpty ? unit : ''}',
          style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 10,
              color: AppColors.textHint)),
    ]);
  }

  // ── Section Title ───────────────────────────────────────────────
  Widget _buildSectionTitle(String title, int count) {
    return Row(children: [
      Text(title,
          style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('$count',
            style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      ),
    ]);
  }

  // ── Empty State ─────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.iconBgYellow,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.fitness_center_rounded,
              size: 36, color: AppColors.warning),
        ),
        const SizedBox(height: 14),
        const Text('Chưa có hoạt động nào',
            style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark)),
        const SizedBox(height: 4),
        const Text('Nhấn nút bên dưới để thêm hoạt động',
            style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 12,
                color: AppColors.textSecondary)),
      ]),
    );
  }

  // ── Activity Card ───────────────────────────────────────────────
  Widget _buildActivityCard(_Activity a, int index) {
    final c = _typeColor(a.type);
    return GestureDetector(
      onTap: () => _editActivity(index),
      child: Dismissible(
        key: ValueKey('${a.name}_$index'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          _deleteActivity(index);
          return false; // dialog handles deletion
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          child:
              const Icon(Icons.delete_rounded, color: AppColors.error, size: 24),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: a.enabled ? AppColors.borderLight : AppColors.border),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadowPrimary,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: -2),
            ],
          ),
          child: Opacity(
            opacity: a.enabled ? 1.0 : 0.55,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_typeIcon(a.type), color: c, size: 24),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(a.name,
                              style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark)),
                        ),
                        SizedBox(
                          height: 28,
                          child: Switch.adaptive(
                            value: a.enabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (v) => _toggleActivity(index, v),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      // Tags row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _tag(Icons.timer_outlined, '${a.durationMin} phút',
                              AppColors.primary),
                          _tag(Icons.access_time_rounded,
                              _formatTime(a.time), AppColors.info),
                          _tag(Icons.repeat_rounded,
                              _repeatText(a.repeatDays), AppColors.warning),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(a.member,
                          style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary)),
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// RING PAINTER
// ═══════════════════════════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  final double ratio;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  _RingPainter({
    required this.ratio,
    required this.color,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (ratio > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * ratio,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.ratio != ratio;
}

// ═══════════════════════════════════════════════════════════════════
// FORM BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════
class _ActivityFormSheet extends StatefulWidget {
  final TextEditingController nameCtrl;
  final _ActivityType type;
  final double duration;
  final TimeOfDay? time;
  final Set<int> days;
  final String member;
  final List<String> members;
  final String Function(_ActivityType) typeLabel;
  final IconData Function(_ActivityType) typeIcon;
  final Color Function(_ActivityType) typeColor;
  final List<String> dayLabels;
  final ValueChanged<_ActivityType> onTypeChanged;
  final ValueChanged<double> onDurationChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<Set<int>> onDaysChanged;
  final ValueChanged<String> onMemberChanged;
  final VoidCallback onSave;
  final bool isEditing;

  const _ActivityFormSheet({
    required this.nameCtrl,
    required this.type,
    required this.duration,
    required this.time,
    required this.days,
    required this.member,
    required this.members,
    required this.typeLabel,
    required this.typeIcon,
    required this.typeColor,
    required this.dayLabels,
    required this.onTypeChanged,
    required this.onDurationChanged,
    required this.onTimeChanged,
    required this.onDaysChanged,
    required this.onMemberChanged,
    required this.onSave,
    required this.isEditing,
  });

  @override
  State<_ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<_ActivityFormSheet> {
  late _ActivityType _type = widget.type;
  late double _duration = widget.duration;
  late TimeOfDay? _time = widget.time;
  late final Set<int> _days = Set.from(widget.days);
  late String _member = widget.member;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
            color: AppColors.handleBar,
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
                color: AppColors.iconBgYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center_rounded,
                  color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              widget.isEditing ? 'Sửa hoạt động' : 'Thêm hoạt động',
              style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark),
            ),
          ]),
        ),
        const Divider(color: AppColors.divider),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _label('Tên hoạt động'),
                  _textField(widget.nameCtrl, 'Nhập tên hoạt động...'),
                  const SizedBox(height: 14),

                  // Type selector
                  _label('Loại hoạt động'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ActivityType.values.map((t) {
                      final sel = t == _type;
                      final c = widget.typeColor(t);
                      return GestureDetector(
                        onTap: () {
                          setState(() => _type = t);
                          widget.onTypeChanged(t);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? c.withAlpha(25) : AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: sel ? c : AppColors.inputBorder,
                                width: sel ? 1.5 : 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(widget.typeIcon(t),
                                size: 16, color: sel ? c : AppColors.textHint),
                            const SizedBox(width: 6),
                            Text(widget.typeLabel(t),
                                style: TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 12,
                                    fontWeight:
                                        sel ? FontWeight.w600 : FontWeight.w400,
                                    color: sel ? c : AppColors.textSecondary)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Duration slider
                  _label('Thời lượng: ${_duration.round()} phút'),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primary.withAlpha(30),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withAlpha(30),
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: _duration,
                      min: 10,
                      max: 120,
                      divisions: 22,
                      label: '${_duration.round()} phút',
                      onChanged: (v) {
                        setState(() => _duration = v);
                        widget.onDurationChanged(v);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('10 phút',
                          style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 10,
                              color: AppColors.textHint)),
                      Text('120 phút',
                          style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 10,
                              color: AppColors.textHint)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Time picker
                  _label('Giờ tập'),
                  _pickerTile(
                    icon: Icons.access_time_rounded,
                    text: _time != null
                        ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
                        : 'Chọn giờ',
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _time ?? TimeOfDay.now(),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primary,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: AppColors.textBody,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (t != null) {
                        setState(() => _time = t);
                        widget.onTimeChanged(t);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Day selector
                  _label('Ngày lặp lại'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final sel = _days.contains(day);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (sel) {
                              _days.remove(day);
                            } else {
                              _days.add(day);
                            }
                          });
                          widget.onDaysChanged(_days);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.inputBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.inputBorder),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.dayLabels[i],
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Member selector
                  _label('Thành viên'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _member,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary),
                        style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            color: AppColors.textBody),
                        items: widget.members
                            .map((m) => DropdownMenuItem(
                                value: m, child: Text(m)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _member = v);
                            widget.onMemberChanged(v);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
          ),
        ),
        // Save button — always visible outside scroll
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + keyboardInset),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.onSave,
              child: Text(
                widget.isEditing ? 'Cập nhật' : 'Lưu hoạt động',
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark)),
      );

  Widget _textField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(
          fontFamily: 'Lexend', fontSize: 14, color: AppColors.textBody),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Lexend', fontSize: 14, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                    color: text.startsWith('Chọn')
                        ? AppColors.textHint
                        : AppColors.textBody)),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: AppColors.primary),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════
enum _ActivityType { walking, running, cycling, yoga, swimming, other }

class _Activity {
  final int id;
  String name;
  _ActivityType type;
  int durationMin;
  TimeOfDay time;
  Set<int> repeatDays; // 1=T2 .. 7=CN
  String member;
  String memberUid;
  bool enabled;

  _Activity({
    this.id = 0,
    required this.name,
    required this.type,
    required this.durationMin,
    required this.time,
    required this.repeatDays,
    required this.member,
    this.memberUid = '',
    required this.enabled,
  });
}


