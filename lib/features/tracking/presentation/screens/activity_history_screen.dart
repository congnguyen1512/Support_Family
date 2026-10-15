import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/network/api_exception.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/theme.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';
import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';
import 'package:family_guard/features/tracking/data/datasources/safe_zone_history_remote_data_source.dart';
import 'package:family_guard/features/tracking/data/models/safe_zone_event_model.dart';

// ── Timeline rows ────────────────────────────────────────────────────

class _TimelineRow {
  const _TimelineRow.day(this.dayLabel, this.isToday) : event = null;
  const _TimelineRow.event(this.event)
      : dayLabel = null,
        isToday = false;

  final String? dayLabel;
  final bool isToday;
  final SafeZoneEventModel? event;
}

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key, this.initialMemberId});

  /// Thanh vien duoc chon san khi mo man hinh (tuy chon).
  final String? initialMemberId;

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  static const _filterAll = 'Tất cả';
  static const _filterLeave = 'Rời vùng';
  static const _filterEnter = 'Vào vùng';
  static const _monthEventsLimit = 1000;
  static const _autoRefreshInterval = Duration(seconds: 60);
  static const _memberPalette = [
    Color(0xFF00ACB2),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
  ];

  // ── Dependencies ─────────────────────────────────────────────────
  late final SafeZoneService _safeZoneService;
  late final SafeZoneHistoryRemoteDataSource _historySource;

  // ── State ────────────────────────────────────────────────────────
  List<SafeZoneMember> _members = const [];
  bool _membersLoading = true;
  String? _selectedMemberId;
  String _selectedFilter = _filterAll;
  late int _selectedMonth;
  late int _selectedYear;

  /// Su kien cua thang dang xem (tat ca loai) - loc theo tab o client
  /// de chuyen tab tuc thi, khong goi lai API.
  List<SafeZoneEventModel> _events = const [];
  bool _eventsLoading = false;
  String? _eventsError;
  final Set<int> _expandedIds = <int>{};

  /// Cache theo "uid|yyyy-mm": quay lai thanh vien/thang da xem hien ngay,
  /// sau do lam moi ngam.
  final Map<String, List<SafeZoneEventModel>> _cache = {};
  int _requestToken = 0;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _historySource = SafeZoneHistoryRemoteDataSourceImpl();
    _safeZoneService = AppDependencies.instance.safeZoneService;
    _safeZoneService.addListener(_onMembersChanged);
    _syncMembers();
    unawaited(_initMembers());

    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      if (mounted && _isViewingCurrentMonth && !_eventsLoading) {
        unawaited(_loadEvents(silent: true));
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _safeZoneService.removeListener(_onMembersChanged);
    super.dispose();
  }

  // ── Members ──────────────────────────────────────────────────────

  Future<void> _initMembers() async {
    try {
      await _safeZoneService.initialize();
      if (_safeZoneService.members.isEmpty) {
        await _safeZoneService.refresh();
      }
    } catch (_) {
      // Loi da duoc SafeZoneService luu vao lastErrorMessage.
    }
    if (!mounted) return;
    setState(() => _membersLoading = false);
    _syncMembers();
  }

  void _onMembersChanged() {
    if (!mounted) return;
    _syncMembers();
  }

  void _syncMembers() {
    // Nguoi duoc cham soc (co vung an toan) len truoc, nguoi cham soc xep sau.
    final members = List<SafeZoneMember>.of(_safeZoneService.members)
      ..sort((a, b) {
        final aCaregiver = a.role == 'nguoichamsoc' ? 1 : 0;
        final bCaregiver = b.role == 'nguoichamsoc' ? 1 : 0;
        return aCaregiver.compareTo(bCaregiver);
      });

    final previous = _selectedMemberId;
    String? nextSelected = previous;
    if (nextSelected == null || !members.any((m) => m.id == nextSelected)) {
      final initial = widget.initialMemberId;
      if (previous == null &&
          initial != null &&
          members.any((m) => m.id == initial)) {
        nextSelected = initial;
      } else {
        nextSelected = members.isEmpty ? null : members.first.id;
      }
    }

    setState(() {
      _members = members;
      if (members.isNotEmpty) _membersLoading = false;
      _selectedMemberId = nextSelected;
    });

    if (nextSelected != previous) {
      _onSelectionChanged();
    }
  }

  SafeZoneMember? get _selectedMember {
    final id = _selectedMemberId;
    if (id == null) return null;
    for (final m in _members) {
      if (m.id == id) return m;
    }
    return null;
  }

  Color _memberColor(SafeZoneMember member) {
    final index = _members.indexWhere((m) => m.id == member.id);
    return _memberPalette[(index < 0 ? 0 : index) % _memberPalette.length];
  }

  Future<void> _openAddMember() async {
    await Navigator.pushNamed(context, AppRoutes.addMember);
    if (!mounted) return;
    unawaited(_safeZoneService.refresh());
  }

  // ── Events ───────────────────────────────────────────────────────

  bool get _isViewingCurrentMonth {
    final now = DateTime.now();
    return now.year == _selectedYear && now.month == _selectedMonth;
  }

  String get _cacheKey =>
      '$_selectedMemberId|$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';

  void _onSelectionChanged() {
    final cached = _selectedMemberId == null ? null : _cache[_cacheKey];
    setState(() {
      _events = cached ?? const [];
      _eventsError = null;
      _expandedIds.clear();
    });
    unawaited(_loadEvents(silent: cached != null));
  }

  Future<void> _loadEvents({bool silent = false}) async {
    final memberId = _selectedMemberId;
    if (memberId == null) {
      setState(() {
        _events = const [];
        _eventsLoading = false;
      });
      return;
    }

    final token = ++_requestToken;
    final key = _cacheKey;
    final from = DateTime(_selectedYear, _selectedMonth, 1);
    final to = DateTime(_selectedYear, _selectedMonth + 1, 1);

    if (!silent) {
      setState(() {
        _eventsLoading = true;
        _eventsError = null;
      });
    }

    try {
      final events = await _historySource.getEvents(
        memberUid: memberId,
        from: from,
        to: to,
        limit: _monthEventsLimit,
      );
      _cache[key] = events;
      if (!mounted || token != _requestToken) return;
      setState(() {
        _events = events;
        _eventsLoading = false;
        _eventsError = null;
        _expandedIds.removeWhere((id) => !events.any((e) => e.id == id));
      });
    } catch (error) {
      if (!mounted || token != _requestToken) return;
      final message = _errorMessage(error);
      setState(() {
        _eventsLoading = false;
        if (_events.isEmpty) _eventsError = message;
      });
      if (_events.isNotEmpty && !silent) {
        _showSnack(message, isError: true);
      }
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _safeZoneService.refresh(),
      _loadEvents(silent: _events.isNotEmpty),
    ]);
  }

  String _errorMessage(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 403) {
        return 'Bạn không có quyền xem lịch sử của thành viên này.';
      }
      if (error.message.trim().isNotEmpty) return error.message;
    }
    return 'Không tải được lịch sử di chuyển. Vui lòng thử lại.';
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message,
            style: const TextStyle(fontFamily: 'Lexend', color: Colors.white)),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF00ACB2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ));
  }

  // ── Derived data ─────────────────────────────────────────────────

  List<SafeZoneEventModel> get _filteredEvents {
    return _events.where((e) {
      if (_selectedFilter == _filterEnter && !e.isEnter) return false;
      if (_selectedFilter == _filterLeave && e.isEnter) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  List<_TimelineRow> get _timelineRows {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final rows = <_TimelineRow>[];
    DateTime? currentDay;

    for (final e in _filteredEvents) {
      final t = e.occurredAt;
      final d = DateTime(t.year, t.month, t.day);
      if (currentDay == null || d != currentDay) {
        currentDay = d;
        final dd = t.day.toString().padLeft(2, '0');
        final mm = t.month.toString().padLeft(2, '0');
        final String label;
        if (d == today) {
          label = 'HÔM NAY, $dd/$mm';
        } else if (d == yesterday) {
          label = 'HÔM QUA, $dd/$mm';
        } else {
          label = '$dd/$mm/${t.year}';
        }
        rows.add(_TimelineRow.day(label, d == today));
      }
      rows.add(_TimelineRow.event(e));
    }
    return rows;
  }

  String get _monthLabel {
    return 'Tháng ${_selectedMonth.toString().padLeft(2, '0')}, $_selectedYear';
  }

  // ── Formatting ───────────────────────────────────────────────────

  String _two(int v) => v.toString().padLeft(2, '0');

  String _formatTime(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

  String _formatDateTime(DateTime t) =>
      '${_formatTime(t)} - ${_two(t.day)}/${_two(t.month)}/${t.year}';

  String _formatDuration(Duration d) {
    if (d.inMinutes < 1) return 'dưới 1 phút';
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    if (days > 0) return '$days ngày ${hours}h ${_two(minutes)}m';
    if (d.inHours > 0) return '${d.inHours}h ${_two(minutes)}m';
    return '$minutes phút';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }

  String _eventSubtitle(SafeZoneEventModel e) {
    if (e.address != null) return e.address!;
    if (e.hasEventPoint) {
      return '${e.latitude!.toStringAsFixed(5)}, ${e.longitude!.toStringAsFixed(5)}';
    }
    return 'Không rõ vị trí';
  }

  // ── Actions ──────────────────────────────────────────────────────

  void _showMonthPicker() {
    final now = DateTime.now();
    int tmpMonth = _selectedMonth;
    int tmpYear = _selectedYear;
    bool isFuture(int year, int month) =>
        year > now.year || (year == now.year && month > now.month);

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
                  const Text('Chọn tháng', style: TextStyle(
                    color: Color(0xFF0C1D1A), fontSize: 18,
                    fontFamily: 'Lexend', fontWeight: FontWeight.w700,
                  )),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Color(0xFF6B7280)),
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
                  Text('$tmpYear', style: const TextStyle(
                    fontSize: 18, fontFamily: 'Lexend', fontWeight: FontWeight.w700,
                    color: Color(0xFF0C1D1A),
                  )),
                  IconButton(
                    onPressed: tmpYear >= now.year
                        ? null
                        : () => setBS(() {
                              tmpYear++;
                              if (isFuture(tmpYear, tmpMonth)) {
                                tmpMonth = now.month;
                              }
                            }),
                    icon: Icon(
                      Icons.chevron_right,
                      color: tmpYear >= now.year
                          ? const Color(0xFFD1D5DB)
                          : AppColors.primary,
                    ),
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
                  final disabled = isFuture(tmpYear, m);
                  return GestureDetector(
                    onTap: disabled ? null : () => setBS(() => tmpMonth = m),
                    child: Opacity(
                      opacity: disabled ? 0.35 : 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? AppColors.primary : const Color(0xFFE5E7EB),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text('Th ${_two(m)}', style: TextStyle(
                          color: sel ? Colors.white : const Color(0xFF6B7280),
                          fontSize: 13, fontFamily: 'Lexend', fontWeight: FontWeight.w600,
                        )),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (tmpMonth == _selectedMonth && tmpYear == _selectedYear) {
                      return;
                    }
                    setState(() {
                      _selectedMonth = tmpMonth;
                      _selectedYear = tmpYear;
                    });
                    _onSelectionChanged();
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

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _refreshAll,
                child: _buildBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final hPad = ResponsiveHelper.horizontalPadding(context);
    final rows = _timelineRows;

    Widget content;
    if (_members.isEmpty && _membersLoading) {
      content = _buildLoadingSliver();
    } else if (_members.isEmpty) {
      content = _buildMessageSliver(
        icon: Icons.group_outlined,
        title: 'Chưa có thành viên',
        message: 'Hãy thêm thành viên gia đình để theo dõi lịch sử di chuyển.',
        actionLabel: 'Thêm thành viên',
        onAction: _openAddMember,
      );
    } else if (_eventsLoading && _events.isEmpty) {
      content = _buildLoadingSliver();
    } else if (_eventsError != null && _events.isEmpty) {
      content = _buildMessageSliver(
        icon: Icons.cloud_off_rounded,
        title: 'Không tải được dữ liệu',
        message: _eventsError!,
        actionLabel: 'Thử lại',
        onAction: () => _loadEvents(),
      );
    } else if (rows.isEmpty) {
      content = _buildMessageSliver(
        icon: Icons.history,
        title: _events.isEmpty
            ? 'Chưa có lịch sử trong tháng này'
            : 'Không có hoạt động phù hợp',
        message: _events.isEmpty
            ? 'Lịch sử được ghi tự động mỗi khi ${_selectedMember?.name ?? 'thành viên'} '
                'vào hoặc rời một vùng an toàn.'
            : 'Thử chọn bộ lọc khác để xem thêm hoạt động.',
      );
    } else {
      content = SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final row = rows[index];
              if (row.event == null) {
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 8, bottom: 16),
                  child: _buildTimelineBadge(row.dayLabel!, row.isToday),
                );
              }
              return Padding(
                key: ValueKey('event_${row.event!.id}'),
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildTimelineItem(event: row.event!),
              );
            },
            childCount: rows.length,
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 24, left: hPad, right: hPad),
          sliver: SliverToBoxAdapter(child: _buildFilterTabs()),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 24,
            child: (_eventsLoading && _events.isNotEmpty)
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad + 24, vertical: 11),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  )
                : null,
          ),
        ),
        content,
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildLoadingSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00ACB2)),
        ),
      ),
    );
  }

  Widget _buildMessageSliver({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0C1D1A), fontSize: 16,
                fontFamily: 'Lexend', fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280), fontSize: 13,
                fontFamily: 'Lexend', fontWeight: FontWeight.w400, height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
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
    final hPad = ResponsiveHelper.horizontalPadding(context);
    if (_members.isEmpty && _membersLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00ACB2)),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._members.map((m) {
            final isSel = m.id == _selectedMemberId;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
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

  Widget _buildMemberAvatar(SafeZoneMember member, {required bool isSelected}) {
    final color = _memberColor(member);
    final initial = member.name.trim().isEmpty
        ? '?'
        : member.name.trim().characters.first.toUpperCase();
    final initialWidget = Center(
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final hasAvatar = member.avatarUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        if (member.id == _selectedMemberId) return;
        setState(() => _selectedMemberId = member.id);
        _onSelectionChanged();
      },
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: ShapeDecoration(
                color: color.withValues(alpha: 0.15),
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
              child: hasAvatar
                  ? ClipOval(
                      child: Image.network(
                        member.avatarUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => initialWidget,
                      ),
                    )
                  : initialWidget,
            ),
            const SizedBox(height: 8),
            Text(
              member.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
      onTap: _openAddMember,
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
          Expanded(child: _buildFilterTab(_filterAll)),
          Expanded(child: _buildFilterTab(_filterLeave)),
          Expanded(child: _buildFilterTab(_filterEnter)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        if (_selectedFilter == label) return;
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

  Widget _buildTimelineItem({required SafeZoneEventModel event}) {
    final isEnter = event.isEnter;
    final expanded = _expandedIds.contains(event.id);
    final pinColor = isEnter ? AppColors.primary : const Color(0xFFF43F5E);
    final iconColor = isEnter ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        if (!_expandedIds.remove(event.id)) _expandedIds.add(event.id);
      }),
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
                    _formatTime(event.occurredAt),
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
                                    _eventSubtitle(event),
                                    maxLines: expanded ? 3 : 1,
                                    overflow: TextOverflow.ellipsis,
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
                            const SizedBox(width: 8),
                            _buildStatusBadge(isEnter),
                          ],
                        ),
                        if (event.isOngoing) ...[
                          const SizedBox(height: 10),
                          _buildOngoingChip(event),
                        ],
                        const SizedBox(height: 12),
                        _buildMapPreview(event, pinColor),
                        // Expanded detail
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox(width: double.infinity),
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

  Widget _buildStatusBadge(bool isEnter) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: isEnter ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: isEnter ? const Color(0xFFD1FAE5) : const Color(0xFFFECACA),
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Text(
        isEnter ? 'AN TOÀN' : 'CẢNH BÁO',
        style: TextStyle(
          color: isEnter ? const Color(0xFF047857) : const Color(0xFFDC2626),
          fontSize: ResponsiveHelper.sp(context, 10),
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
      ),
    );
  }

  Widget _buildOngoingChip(SafeZoneEventModel event) {
    final duration = event.stayDuration;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              duration == null
                  ? 'Đang ở trong vùng'
                  : 'Đang ở trong vùng · ${_formatDuration(duration)}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: ResponsiveHelper.sp(context, 11),
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetail(SafeZoneEventModel event) {
    final stay = event.stayDuration;
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
            if (event.hasEventPoint) ...[
              _buildDetailRow(Icons.location_on_outlined, 'Tọa độ',
                  '${event.latitude!.toStringAsFixed(5)}, ${event.longitude!.toStringAsFixed(5)}'),
              const SizedBox(height: 8),
            ],
            _buildDetailRow(Icons.access_time, 'Thời gian',
                _formatDateTime(event.occurredAt)),
            if (event.distanceMeters != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.social_distance_outlined, 'Cách tâm vùng',
                  _formatDistance(event.distanceMeters!)),
            ],
            if (event.zoneRadiusMeters != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.radar_outlined, 'Bán kính vùng',
                  _formatDistance(event.zoneRadiusMeters!)),
            ],
            if (stay != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.timer_outlined,
                event.isOngoing ? 'Đã ở được' : 'Thời gian ở',
                _formatDuration(stay),
              ),
            ],
            if (!event.isEnter && event.stayStartedAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.login_rounded, 'Vào vùng lúc',
                  _formatDateTime(event.stayStartedAt!)),
            ],
            if (event.isEnter && !event.isOngoing && event.stayEndedAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.logout_rounded, 'Rời vùng lúc',
                  _formatDateTime(event.stayEndedAt!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  /// Ban do thu nho (khong tuong tac): vong tron vung an toan + diem vi tri
  /// luc vao/roi vung. Zoom tu tinh de thay ca vung lan diem.
  Widget _buildMapPreview(SafeZoneEventModel event, Color pinColor) {
    const height = 110.0;
    final eventPoint = event.hasEventPoint
        ? LatLng(event.latitude!, event.longitude!)
        : null;
    final zoneCenter = (event.zoneLatitude != null && event.zoneLongitude != null)
        ? LatLng(event.zoneLatitude!, event.zoneLongitude!)
        : null;
    final center = zoneCenter ?? eventPoint;

    if (center == null) {
      return Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.map_outlined, color: Color(0xFF9CA3AF)),
      );
    }

    final radius = event.zoneRadiusMeters ?? 100;
    final distance = (zoneCenter != null && eventPoint != null)
        ? const Distance().as(LengthUnit.Meter, zoneCenter, eventPoint)
        : 0.0;
    final extent = math.max(radius, distance) * 1.3;
    // met/pixel tai zoom z = 156543.03 * cos(lat) / 2^z; can extent vua ~45% chieu cao
    final metersPerPixel = math.max(extent, 30) / (height * 0.45);
    final zoom = (math.log(156543.03 * math.cos(center.latitude * math.pi / 180) /
                metersPerPixel) /
            math.ln2)
        .clamp(3.0, 18.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: IgnorePointer(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: zoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.familyguard.app',
                maxZoom: 19,
              ),
              if (zoneCenter != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: zoneCenter,
                      radius: radius,
                      useRadiusInMeter: true,
                      color: pinColor.withValues(alpha: 0.18),
                      borderColor: pinColor,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              if (eventPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: eventPoint,
                      width: 16,
                      height: 16,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: pinColor,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
