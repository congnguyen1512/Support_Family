import 'package:flutter/material.dart';
import 'package:family_guard/core/widgets/app_dialog.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/utils/responsive/responsive_helper.dart';


import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/features/medical/data/datasources/medical_appointment_remote_data_source.dart';

class MedicalAppointmentArgs {
  final String? memberId;
  final String? memberName;
  final String? avatarUrl;

  const MedicalAppointmentArgs({
    this.memberId,
    this.memberName,
    this.avatarUrl,
  });
}

/// Lịch hẹn khám bệnh – quản lý danh sách lịch khám
class MedicalAppointmentScreen extends StatefulWidget {
  final MedicalAppointmentArgs? args;
  const MedicalAppointmentScreen({super.key, this.args});

  @override
  State<MedicalAppointmentScreen> createState() =>
      _MedicalAppointmentScreenState();
}

class _MedicalAppointmentScreenState extends State<MedicalAppointmentScreen>
    with SingleTickerProviderStateMixin {
  final MedicalAppointmentRemoteDataSource _dataSource =
      MedicalAppointmentRemoteDataSourceImpl();

  // ── Filter ──────────────────────────────────────────────────────
  int _filterIndex = 0; // 0=Tất cả, 1=Sắp tới, 2=Đã khám, 3=Đã hủy
  final List<String> _filterLabels = [
    'Tất cả',
    'Sắp tới',
    'Đã khám',
    'Đã hủy',
  ];

  // ── Appointments data ────────────────────────────────────────────
  List<_Appointment> _appointments = [];
  bool _isLoading = true;
  MedicalAppointmentArgs? _args;
  final Map<String, String> _memberNameToUid = {};

  // ── Form controllers ─────────────────────────────────────────────
  final _clinicCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _formDate;
  TimeOfDay? _formTime;
  String _formMember = '';
  List<String> _members = ['Tất cả thành viên'];

  late final AnimationController _fabAnimCtrl;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _args = widget.args;
    _fabAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fabScale = CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.elasticOut);
    _fabAnimCtrl.forward();
    _loadInitial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is MedicalAppointmentArgs) {
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

      await _fetchAppointments();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dataSource.getAppointments(
        memberUid: _args?.memberId,
      );
      if (mounted) {
        setState(() {
          _appointments = data.map((m) {
            return _Appointment(
              id: m.id,
              clinic: m.clinic,
              doctor: m.doctor,
              date: m.appointmentDate,
              time: _parseTimeOfDay(m.appointmentTime),
              member: m.memberName ?? (_args?.memberName ?? 'Thành viên'),
              memberUid: m.memberUid,
              notes: m.notes,
              status: _parseStatus(m.status),
              remindBefore1Day: m.remindBefore1Day,
              remindBefore2Hours: m.remindBefore2Hours,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  _AppointmentStatus _parseStatus(String s) {
    switch (s) {
      case 'done':
        return _AppointmentStatus.done;
      case 'cancelled':
        return _AppointmentStatus.cancelled;
      default:
        return _AppointmentStatus.upcoming;
    }
  }

  @override
  void dispose() {
    _clinicCtrl.dispose();
    _doctorCtrl.dispose();
    _notesCtrl.dispose();
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────
  List<_Appointment> get _filtered {
    if (_filterIndex == 0) return _appointments;
    final status = _AppointmentStatus.values[_filterIndex - 1];
    return _appointments.where((a) => a.status == status).toList();
  }

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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Color _statusColor(_AppointmentStatus s) => switch (s) {
        _AppointmentStatus.upcoming => AppColors.info,
        _AppointmentStatus.done => AppColors.success,
        _AppointmentStatus.cancelled => AppColors.error,
      };

  String _statusLabel(_AppointmentStatus s) => switch (s) {
        _AppointmentStatus.upcoming => 'Sắp tới',
        _AppointmentStatus.done => 'Đã khám',
        _AppointmentStatus.cancelled => 'Đã hủy',
      };

  IconData _statusIcon(_AppointmentStatus s) => switch (s) {
        _AppointmentStatus.upcoming => Icons.schedule_rounded,
        _AppointmentStatus.done => Icons.check_circle_rounded,
        _AppointmentStatus.cancelled => Icons.cancel_rounded,
      };

  // ── CRUD ─────────────────────────────────────────────────────────
  void _addAppointment() {
    _clinicCtrl.clear();
    _doctorCtrl.clear();
    _notesCtrl.clear();
    _formDate = null;
    _formTime = null;
    _formMember = _args?.memberName ?? (_members.isNotEmpty ? _members.first : '');
    _showFormSheet(editIndex: null);
  }

  void _editAppointment(int index) {
    final a = _appointments[index];
    _clinicCtrl.text = a.clinic;
    _doctorCtrl.text = a.doctor;
    _notesCtrl.text = a.notes;
    _formDate = a.date;
    _formTime = a.time;
    _formMember = a.member;
    _showFormSheet(editIndex: index);
  }

  Future<void> _cancelAppointment(int index) async {
    final a = _appointments[index];
    setState(() {
      a.status = _AppointmentStatus.cancelled;
    });
    try {
      await _dataSource.updateAppointment(a.id, status: 'cancelled');
    } catch (_) {}
    _showToast('Đã hủy lịch hẹn');
  }

  void _deleteAppointment(int index) {
    final a = _appointments[index];
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xóa lịch hẹn',
      content: 'Bạn có chắc muốn xóa lịch hẹn này?',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () async {
        setState(() => _appointments.removeAt(index));
        try {
          await _dataSource.deleteAppointment(a.id);
        } catch (_) {}
        _showToast('Đã xóa lịch hẹn');
      },
    );
  }

  // ── Form Bottom Sheet ────────────────────────────────────────────
  void _showFormSheet({required int? editIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentFormSheet(
        clinicCtrl: _clinicCtrl,
        doctorCtrl: _doctorCtrl,
        notesCtrl: _notesCtrl,
        date: _formDate,
        time: _formTime,
        member: _formMember,
        members: _members,
        onDateChanged: (d) => _formDate = d,
        onTimeChanged: (t) => _formTime = t,
        onMemberChanged: (m) => _formMember = m,
        onSave: () async {
          // Validate
          if (_clinicCtrl.text.trim().isEmpty) {
            _showToast('Vui lòng nhập tên phòng khám');
            return;
          }
          if (_doctorCtrl.text.trim().isEmpty) {
            _showToast('Vui lòng nhập tên bác sĩ');
            return;
          }
          if (_formDate == null) {
            _showToast('Vui lòng chọn ngày khám');
            return;
          }
          if (_formTime == null) {
            _showToast('Vui lòng chọn giờ khám');
            return;
          }

          final clinic = _clinicCtrl.text.trim();
          final doctor = _doctorCtrl.text.trim();
          final notes = _notesCtrl.text.trim();
          final date = _formDate!;
          final time = _formTime!;
          final member = _formMember;
          final memberUid = _memberNameToUid[member] ?? _args?.memberId;

          Navigator.pop(context);

          if (editIndex != null) {
            final a = _appointments[editIndex];
            setState(() {
              a.clinic = clinic;
              a.doctor = doctor;
              a.date = date;
              a.time = time;
              a.member = member;
              a.notes = notes;
            });
            try {
              final timeStr =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              await _dataSource.updateAppointment(
                a.id,
                clinic: clinic,
                doctor: doctor,
                appointmentDate: date,
                appointmentTime: timeStr,
                memberUid: memberUid,
                notes: notes,
              );
              _showToast('Đã cập nhật lịch hẹn');
            } catch (e) {
              _showToast('Lỗi cập nhật: $e');
            }
          } else {
            try {
              final timeStr =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              final created = await _dataSource.createAppointment(
                clinic: clinic,
                doctor: doctor,
                appointmentDate: date,
                appointmentTime: timeStr,
                memberUid: memberUid,
                notes: notes,
              );
              setState(() {
                _appointments.insert(
                  0,
                  _Appointment(
                    id: created.id,
                    clinic: created.clinic,
                    doctor: created.doctor,
                    date: created.appointmentDate,
                    time: time,
                    member: member.isNotEmpty ? member : (created.memberName ?? 'Thành viên'),
                    memberUid: created.memberUid,
                    notes: created.notes,
                    status: _parseStatus(created.status),
                    remindBefore1Day: created.remindBefore1Day,
                    remindBefore2Hours: created.remindBefore2Hours,
                  ),
                );
              });
              _showToast('Đã thêm lịch hẹn mới');
            } catch (e) {
              _showToast('Lỗi tạo lịch hẹn: $e');
            }
          }
        },
        isEditing: editIndex != null,
      ),
    );
  }

  // ── Detail Bottom Sheet ──────────────────────────────────────────
  void _showDetail(int index) {
    final a = _appointments[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(a.status).withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_statusIcon(a.status),
                              size: 14, color: _statusColor(a.status)),
                          const SizedBox(width: 4),
                          Text(_statusLabel(a.status),
                              style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(a.status))),
                        ]),
                      ),
                      const Spacer(),
                      Text(a.member,
                          style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary)),
                    ]),
                    const SizedBox(height: 16),

                    // Clinic
                    Text(a.clinic,
                        style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark)),
                    const SizedBox(height: 8),

                    // Doctor
                    _detailRow(Icons.person_rounded, a.doctor),
                    const SizedBox(height: 6),
                    _detailRow(Icons.calendar_today_rounded,
                        _formatDate(a.date)),
                    const SizedBox(height: 6),
                    _detailRow(Icons.access_time_rounded,
                        _formatTime(a.time)),
                    if (a.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _detailRow(Icons.notes_rounded, a.notes),
                    ],
                    const SizedBox(height: 20),

                    // Reminders toggles
                    _buildToggleRow(
                      'Nhắc trước 1 ngày',
                      a.remindBefore1Day,
                      (v) async {
                        setState(() => a.remindBefore1Day = v);
                        try {
                          await _dataSource.updateAppointment(a.id, remindBefore1Day: v);
                        } catch (_) {}
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                        _showToast(v
                            ? 'Đã bật nhắc trước 1 ngày'
                            : 'Đã tắt nhắc trước 1 ngày');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildToggleRow(
                      'Nhắc trước 2 tiếng',
                      a.remindBefore2Hours,
                      (v) async {
                        setState(() => a.remindBefore2Hours = v);
                        try {
                          await _dataSource.updateAppointment(a.id, remindBefore2Hours: v);
                        } catch (_) {}
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                        _showToast(v
                            ? 'Đã bật nhắc trước 2 tiếng'
                            : 'Đã tắt nhắc trước 2 tiếng');
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    if (a.status == _AppointmentStatus.upcoming)
                      Row(children: [
                        Expanded(
                          child: _actionBtn(
                            label: 'Sửa',
                            icon: Icons.edit_rounded,
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.pop(context);
                              _editAppointment(index);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionBtn(
                            label: 'Hủy hẹn',
                            icon: Icons.cancel_outlined,
                            color: AppColors.warning,
                            onTap: () {
                              Navigator.pop(context);
                              _cancelAppointment(index);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionBtn(
                            label: 'Xóa',
                            icon: Icons.delete_outline_rounded,
                            color: AppColors.error,
                            onTap: () {
                              Navigator.pop(context);
                              _deleteAppointment(index);
                            },
                          ),
                        ),
                      ]),
                    if (a.status != _AppointmentStatus.upcoming)
                      SizedBox(
                        width: double.infinity,
                        child: _actionBtn(
                          label: 'Xóa',
                          icon: Icons.delete_outline_rounded,
                          color: AppColors.error,
                          onTap: () {
                            Navigator.pop(context);
                            _deleteAppointment(index);
                          },
                        ),
                      ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: AppColors.textSecondary)),
      ),
    ]);
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(Icons.notifications_active_rounded,
            size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBody)),
        ),
        SizedBox(
          height: 24,
          child: Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final realIndex = _appointments.indexOf(filtered[i]);
                          return _buildAppointmentCard(filtered[i], realIndex);
                        },
                      ),
          ),
        ]),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.extended(
          onPressed: _addAppointment,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Thêm lịch hẹn',
              style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
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
            'Lịch hẹn khám bệnh',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: ResponsiveHelper.sp(context, 20),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        // Count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_appointments.length}',
            style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
        ),
      ]),
    );
  }

  // ── Filter Chips ────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filterLabels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.borderLight),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withAlpha(40),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : null,
              ),
              child: Text(
                _filterLabels[i],
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.iconBgTeal,
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.event_busy_rounded, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text('Chưa có lịch hẹn nào',
            style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark)),
        const SizedBox(height: 6),
        const Text('Nhấn nút bên dưới để thêm lịch hẹn',
            style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                color: AppColors.textSecondary)),
      ]),
    );
  }

  // ── Appointment Card ────────────────────────────────────────────
  Widget _buildAppointmentCard(_Appointment a, int index) {
    final statusClr = _statusColor(a.status);
    return GestureDetector(
      onTap: () => _showDetail(index),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top row: status + member
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusClr.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_statusIcon(a.status), size: 12, color: statusClr),
                const SizedBox(width: 4),
                Text(_statusLabel(a.status),
                    style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusClr)),
              ]),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(a.member,
                  style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary)),
            ),
          ]),
          const SizedBox(height: 12),

          // Clinic name
          Text(a.clinic,
              style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 4),

          // Doctor
          Row(children: [
            const Icon(Icons.person_rounded,
                size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(a.doctor,
                style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 13,
                    color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 8),

          // Date + Time row
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(_formatDate(a.date),
                  style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textBody)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(_formatTime(a.time),
                  style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textBody)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FORM BOTTOM SHEET (stateful)
// ═══════════════════════════════════════════════════════════════════
class _AppointmentFormSheet extends StatefulWidget {
  final TextEditingController clinicCtrl;
  final TextEditingController doctorCtrl;
  final TextEditingController notesCtrl;
  final DateTime? date;
  final TimeOfDay? time;
  final String member;
  final List<String> members;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<String> onMemberChanged;
  final VoidCallback onSave;
  final bool isEditing;

  const _AppointmentFormSheet({
    required this.clinicCtrl,
    required this.doctorCtrl,
    required this.notesCtrl,
    required this.date,
    required this.time,
    required this.member,
    required this.members,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onMemberChanged,
    required this.onSave,
    required this.isEditing,
  });

  @override
  State<_AppointmentFormSheet> createState() => _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends State<_AppointmentFormSheet> {
  late DateTime? _date = widget.date;
  late TimeOfDay? _time = widget.time;
  late String _member = widget.member;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
              decoration: BoxDecoration(
                color: AppColors.iconBgTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              widget.isEditing ? 'Sửa lịch hẹn' : 'Thêm lịch hẹn',
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Phòng khám / Bệnh viện'),
                  _textField(widget.clinicCtrl, 'Nhập tên phòng khám...'),
                  const SizedBox(height: 14),
                  _label('Bác sĩ'),
                  _textField(widget.doctorCtrl, 'Nhập tên bác sĩ...'),
                  const SizedBox(height: 14),

                  // Date picker
                  _label('Ngày khám'),
                  _pickerTile(
                    icon: Icons.calendar_today_rounded,
                    text: _date != null
                        ? '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}'
                        : 'Chọn ngày',
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(
                            const Duration(days: 365)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 730)),
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
                      if (d != null) {
                        setState(() => _date = d);
                        widget.onDateChanged(d);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Time picker
                  _label('Giờ khám'),
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
                  const SizedBox(height: 14),

                  // Notes
                  _label('Ghi chú (tùy chọn)'),
                  _textField(widget.notesCtrl, 'Thêm ghi chú...',
                      maxLines: 3),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.onSave,
                      child: Text(
                        widget.isEditing ? 'Cập nhật' : 'Lưu lịch hẹn',
                      ),
                    ),
                  ),
                ]),
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

  Widget _textField(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(
          fontFamily: 'Lexend', fontSize: 14, color: AppColors.textBody),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 14,
            color: AppColors.textHint),
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
enum _AppointmentStatus { upcoming, done, cancelled }

class _Appointment {
  final int id;
  String clinic;
  String doctor;
  DateTime date;
  TimeOfDay time;
  String member;
  String memberUid;
  String notes;
  _AppointmentStatus status;
  bool remindBefore1Day;
  bool remindBefore2Hours;

  _Appointment({
    this.id = 0,
    required this.clinic,
    required this.doctor,
    required this.date,
    required this.time,
    required this.member,
    this.memberUid = '',
    required this.notes,
    required this.status,
    required this.remindBefore1Day,
    required this.remindBefore2Hours,
  });
}


