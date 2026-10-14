import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_dialog.dart';
import 'package:family_guard/features/reminder/data/datasources/reminder_remote_data_source.dart';
import 'package:family_guard/features/reminder/data/models/reminder_model.dart';
import 'package:flutter/material.dart';

class ReminderListArgs {
  const ReminderListArgs({
    this.memberId,
    this.memberName,
    this.avatarUrl,
    this.roleLabel,
    this.address,
  });

  final String? memberId;
  final String? memberName;
  final String? avatarUrl;
  final String? roleLabel;
  final String? address;
}

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key, this.args});

  final ReminderListArgs? args;

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  final ReminderRemoteDataSource _dataSource = ReminderRemoteDataSourceImpl();

  List<ReminderModel> _reminders = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? _memberId;
  String _memberName = 'Thành viên';
  String _memberAvatar = '';
  String _address = 'Đà Nẵng';
  String _statusText = 'Đang ở nhà';
  bool _didInitArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitArgs) {
      _didInitArgs = true;
      _initMemberInfo();
    }
  }

  Future<void> _initMemberInfo() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    ReminderListArgs? resolvedArgs = widget.args;

    if (routeArgs is ReminderListArgs) {
      resolvedArgs = routeArgs;
    } else if (routeArgs is Map) {
      resolvedArgs = ReminderListArgs(
        memberId: routeArgs['memberId']?.toString(),
        memberName: routeArgs['memberName']?.toString(),
        avatarUrl: routeArgs['avatarUrl']?.toString(),
        roleLabel: routeArgs['roleLabel']?.toString(),
        address: routeArgs['address']?.toString(),
      );
    }

    if (resolvedArgs != null && resolvedArgs.memberId != null && resolvedArgs.memberId!.isNotEmpty) {
      _memberId = resolvedArgs.memberId;
      _memberName = resolvedArgs.memberName ?? 'Thành viên';
      _memberAvatar = resolvedArgs.avatarUrl ?? '';
      _address = resolvedArgs.address ?? 'Đà Nẵng';
      _statusText = resolvedArgs.roleLabel ?? 'Đang kết nối';
      _loadReminders();
      return;
    }

    // Nếu không truyền args, lấy danh sách quan hệ để gán thành viên đầu tiên
    try {
      final relationships = await AppDependencies.instance.getRelationshipsUseCase();
      final confirmed = relationships.where((r) => r.processing == 'xacnhan').toList();
      if (confirmed.isNotEmpty) {
        final first = confirmed.first;
        final user = first.relationUser;
        _memberId = first.relationId;
        _memberName = user?.name ?? 'Thành viên';
        _memberAvatar = user?.avata ?? '';
        _address = user?.address ?? 'Đà Nẵng';
        _statusText = 'Đang kết nối';
      }
    } catch (_) {
      // Giữ mặc định
    }

    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _dataSource.getReminders(memberUid: _memberId);
      if (!mounted) return;
      setState(() {
        _reminders = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleReminder(ReminderModel reminder) async {
    final newActive = !reminder.isActive;
    setState(() {
      reminder.isActive = newActive;
    });

    try {
      await _dataSource.toggleReminder(reminder.id, newActive);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        reminder.isActive = !newActive;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật trạng thái: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onAddReminder() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.createReminder,
      arguments: {
        'memberId': _memberId,
        'memberName': _memberName,
      },
    );

    if (result == true || result != null) {
      _loadReminders();
    }
  }

  Future<void> _onTapReminder(ReminderModel reminder) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.reminderDetail,
      arguments: reminder,
    );

    if (result == true || result != null) {
      _loadReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FFF8), Colors.white],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _loadReminders,
            color: const Color(0xFF00ACB2),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppBackHeaderBar(title: 'Lịch nhắc đã tạo'),
                  _buildMemberCard(hPad),
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                    child: Text(
                      'Lịch nhắc đã tạo',
                      style: TextStyle(
                        color: const Color(0xFF0C1D1A),
                        fontSize: ResponsiveHelper.sp(context, 24),
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
                    child: _buildBodyContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00ACB2)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 40),
              const SizedBox(height: 12),
              Text(
                'Lỗi tải lịch nhắc: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadReminders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ACB2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reminders.isEmpty) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x2600ACB2)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0x1900ACB2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF00ACB2),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có lịch nhắc nào',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: ResponsiveHelper.sp(context, 16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0C1D1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tạo lịch nhắc để ứng dụng tự động nhắc nhở $_memberName đúng giờ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: ResponsiveHelper.sp(context, 13),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildAddButton(),
        ],
      );
    }

    return Column(
      children: [
        ..._reminders.map(
          (reminder) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildReminderCard(reminder),
          ),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildMemberCard(double hPad) {
    ImageProvider avatarImage;
    if (_memberAvatar.startsWith('http')) {
      avatarImage = NetworkImage(_memberAvatar);
    } else {
      avatarImage = const NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80');
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x2600ACB2)),
            borderRadius: BorderRadius.circular(24),
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
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: avatarImage,
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2, color: Color(0x3300ACB2)),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF22C55E),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _memberName,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: ResponsiveHelper.sp(context, 18),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.home_rounded,
                        size: 14,
                        color: Color(0xFF00ACB2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _statusText,
                        style: TextStyle(
                          color: const Color(0xFF00ACB2),
                          fontSize: ResponsiveHelper.sp(context, 14),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _address.split(',').first.trim(),
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: ResponsiveHelper.sp(context, 12),
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.battery_charging_full_rounded,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '85%',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: ResponsiveHelper.sp(context, 12),
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    return GestureDetector(
      onTap: () => _onTapReminder(reminder),
      onLongPress: () => _showReminderActions(reminder),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x14000000)),
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 2),
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
                color: reminder.iconBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Icon(
                reminder.icon,
                color: reminder.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      color: const Color(0xFF0C1D1A),
                      fontSize: ResponsiveHelper.sp(context, 16),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.formattedTime,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: ResponsiveHelper.sp(context, 14),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _toggleReminder(reminder),
              child: _buildToggleSwitch(reminder.isActive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 28,
      padding: EdgeInsets.only(
        left: isActive ? 22 : 2,
        right: isActive ? 2 : 22,
        top: 2,
        bottom: 2,
      ),
      decoration: ShapeDecoration(
        color: isActive ? const Color(0xFF00ACB2) : const Color(0xFFE2E8F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _onAddReminder,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF00ACB2),
          side: const BorderSide(width: 2, color: Color(0x4C00ACB2)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.add_circle_outline, size: 24),
        label: const Text(
          'Thêm nhắc nhở mới',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showReminderActions(ReminderModel reminder) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              reminder.title,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF0C1D1A),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF00ACB2),
              ),
              title: const Text(
                'Chỉnh sửa lịch nhắc',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.reminderDetail,
                  arguments: reminder,
                ).then((res) {
                  if (res == true || res != null) _loadReminders();
                });
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
              ),
              title: const Text(
                'Xóa lịch nhắc',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteReminder(reminder);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _deleteReminder(ReminderModel reminder) {
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xóa lịch nhắc?',
      content: 'Bạn có chắc chắn muốn xóa lịch nhắc "${reminder.title}" không? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () async {
        Navigator.pop(context);
        try {
          await _dataSource.deleteReminder(reminder.id);
          _loadReminders();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xóa lịch nhắc'),
                backgroundColor: Color(0xFF00ACB2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi xóa lịch nhắc: $e'),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }
}
