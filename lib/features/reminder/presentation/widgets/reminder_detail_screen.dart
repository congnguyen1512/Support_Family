import 'dart:math';
import 'package:flutter/material.dart';
import 'package:family_guard/core/widgets/app_dialog.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/theme.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/features/reminder/data/models/reminder_model.dart';
import 'package:family_guard/features/reminder/data/datasources/reminder_remote_data_source.dart';


/// ============================================================
/// MÀN HÌNH: Chi tiết lịch nhắc (Redesigned)
/// ============================================================
class ReminderDetailScreen extends StatefulWidget {
  const ReminderDetailScreen({super.key});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen>
    with TickerProviderStateMixin {
  // === STATE ===
  bool _isActive = true;
  bool _isEditing = false;
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _hasUnsavedChanges = false;

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String _selectedFrequency = 'Mỗi ngày';
  final List<String> _frequencies = ['Mỗi ngày', 'Hằng tuần', 'Tùy chỉnh'];

  // Snapshot để phát hiện thay đổi
  String _savedTitle = 'Uống thuốc huyết áp';
  String _savedSubtitle = 'Nhắc nhở sức khỏe định kỳ';
  TimeOfDay _savedTime = const TimeOfDay(hour: 8, minute: 0);
  String _savedFrequency = 'Mỗi ngày';
  late List<String> _savedRecipientNames;

  // Animations
  late AnimationController _waveAnimController;
  late AnimationController _recordPulseController;

  final List<_Recipient> _recipients = [
    const _Recipient(name: 'Bà Lan', imageUrl: 'https://i.pravatar.cc/150?img=47'),
  ];

  final List<_Recipient> _availableMembers = [
    const _Recipient(name: 'Ông Hùng', imageUrl: 'https://i.pravatar.cc/150?img=68'),
    const _Recipient(name: 'Anh Tuấn', imageUrl: 'https://i.pravatar.cc/150?img=12'),
    const _Recipient(name: 'Chị Mai', imageUrl: 'https://i.pravatar.cc/150?img=32'),
    const _Recipient(name: 'Bé Bo', imageUrl: 'https://i.pravatar.cc/150?img=3'),
  ];

  final ReminderRemoteDataSource _dataSource = ReminderRemoteDataSourceImpl();
  int _reminderId = 0;
  bool _didInitReminder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitReminder) {
      _didInitReminder = true;
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is ReminderModel) {
        _reminderId = arg.id;
        _savedTitle = arg.title;
        _savedSubtitle = arg.subtitle ?? '';
        _titleController.text = arg.title;
        _subtitleController.text = arg.subtitle ?? '';

        final parts = arg.reminderTime.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 8;
          final m = int.tryParse(parts[1]) ?? 0;
          _selectedTime = TimeOfDay(hour: h, minute: m);
          _savedTime = _selectedTime;
        }

        if (arg.scheduleType == 'weekly') {
          _selectedFrequency = 'Hằng tuần';
        } else if (arg.scheduleType == 'custom') {
          _selectedFrequency = 'Tùy chỉnh';
        } else {
          _selectedFrequency = 'Mỗi ngày';
        }
        _savedFrequency = _selectedFrequency;

        _isActive = arg.isActive;

        if (arg.memberName != null && arg.memberName!.isNotEmpty) {
          _recipients.clear();
          _recipients.add(_Recipient(
            name: arg.memberName!,
            imageUrl: arg.memberAvatar ??
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
          ));
          _savedRecipientNames = [_recipients.first.name];
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _savedTitle);
    _subtitleController = TextEditingController(text: _savedSubtitle);
    _savedRecipientNames = _recipients.map((r) => r.name).toList();

    _titleController.addListener(_checkUnsavedChanges);
    _subtitleController.addListener(_checkUnsavedChanges);

    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _recordPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _waveAnimController.dispose();
    _recordPulseController.dispose();
    super.dispose();
  }

  void _checkUnsavedChanges() {
    final changed = _titleController.text != _savedTitle ||
        _subtitleController.text != _savedSubtitle ||
        _selectedTime != _savedTime ||
        _selectedFrequency != _savedFrequency ||
        !_recipientListEquals();
    if (changed != _hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = changed);
    }
  }

  bool _recipientListEquals() {
    if (_recipients.length != _savedRecipientNames.length) return false;
    for (int i = 0; i < _recipients.length; i++) {
      if (_recipients[i].name != _savedRecipientNames[i]) return false;
    }
    return true;
  }

  String get _timeStr =>
      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

  // ═══════════════════════ BUILD ═══════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  _buildTitleCard(),
                  const SizedBox(height: 14),
                  _buildTimeCard(),
                  const SizedBox(height: 14),
                  _buildVoiceCard(),
                  const SizedBox(height: 14),
                  _buildRecipientCard(),
                  const SizedBox(height: 14),
                  _buildActivationCard(),
                  const SizedBox(height: 18),
                  _buildPreviewButton(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AppBackHeaderBar(
      title: 'Chi tiết lịch nhắc',
      trailing: _buildHeaderIcon(
        icon: _isEditing ? Icons.check_rounded : Icons.edit_outlined,
        onTap: _toggleEditMode,
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF1E293B),
    Color bgColor = Colors.transparent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // ═══════════════════════ TITLE CARD ═══════════════════════
  Widget _buildTitleCard() {
    return _CardWrapper(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD6E0), Color(0xFFFF8FAB)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.medication_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isEditing
                    ? _buildEditField(
                        controller: _titleController,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00ACB2),
                        hint: 'Tên lịch nhắc...',
                      )
                    : Text(
                        _titleController.text,
                        style: TextStyle(
                          color: const Color(0xFF00ACB2),
                          fontSize: ResponsiveHelper.sp(context, 18),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                const SizedBox(height: 2),
                _isEditing
                    ? _buildEditField(
                        controller: _subtitleController,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        hint: 'Mô tả ngắn...',
                      )
                    : Text(
                        _subtitleController.text,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: ResponsiveHelper.sp(context, 13),
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                          height: 1.46,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: color,
        fontSize: ResponsiveHelper.sp(context, fontSize),
        fontFamily: 'Lexend',
        fontWeight: fontWeight,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00ACB2), width: 1.5),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFFCBD5E1),
          fontSize: ResponsiveHelper.sp(context, fontSize),
          fontFamily: 'Lexend',
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  // ═══════════════════════ TIME CARD ═══════════════════════
  Widget _buildTimeCard() {
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('THỜI GIAN'),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildCircleIcon(Icons.access_time_rounded),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isEditing ? _pickTime : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isEditing ? const Color(0xFFF1F5F9) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: _isEditing
                        ? Border.all(color: const Color(0xFFE2E8F0))
                        : null,
                  ),
                  child: Text(
                    _timeStr,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: ResponsiveHelper.sp(context, 22),
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.27,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (_isEditing)
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          _buildFrequencySelector(),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: _frequencies.map((f) {
          final selected = f == _selectedFrequency;
          return Expanded(
            child: GestureDetector(
              onTap: _isEditing
                  ? () {
                      setState(() {
                        _selectedFrequency = f;
                        _checkUnsavedChanges();
                      });
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  f,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF00ACB2)
                        : const Color(0xFF94A3B8),
                    fontSize: ResponsiveHelper.sp(context, 13),
                    fontFamily: 'Lexend',
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════ VOICE CARD ═══════════════════════
  Widget _buildVoiceCard() {
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('GHI \u00C2M GI\u1ECCNG N\u00D3I'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1900ACB2)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ACB2),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4C00ACB2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildAnimatedWaveform()),
                const SizedBox(width: 10),
                Text(
                  '0:12',
                  style: TextStyle(
                    color: const Color(0xFF00ACB2),
                    fontSize: ResponsiveHelper.sp(context, 12),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 10),
            _buildRecordButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedWaveform() {
    const barCount = 20;
    final rng = Random(42);
    final baseHeights =
        List.generate(barCount, (_) => 6.0 + rng.nextDouble() * 26);

    return AnimatedBuilder(
      animation: _waveAnimController,
      builder: (context, child) {
        final animating = _isPlaying || _isRecording;
        return SizedBox(
          height: 32,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (i) {
              double h = baseHeights[i];
              if (animating) {
                h = h *
                    (0.4 +
                        0.6 *
                            sin((_waveAnimController.value * pi * 2) + i * 0.5)
                                .abs());
              }
              return Expanded(
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 3,
                    height: h.clamp(4.0, 32.0),
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF00ACB2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRecording = !_isRecording;
          if (_isRecording) {
            _recordPulseController.repeat(reverse: true);
            _waveAnimController.repeat(reverse: true);
          } else {
            _recordPulseController.stop();
          }
        });
      },
      child: AnimatedBuilder(
        animation: _recordPulseController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _isRecording
                  ? Color.lerp(const Color(0xFFFEE2E2), const Color(0xFFFECACA),
                      _recordPulseController.value)
                  : Colors.transparent,
              border: Border.all(
                color: _isRecording
                    ? const Color(0xFFEF4444)
                    : const Color(0x4D00ACB2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 18,
                  color:
                      _isRecording ? const Color(0xFFEF4444) : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _isRecording ? 'Dừng ghi âm' : 'Ghi âm mới',
                  style: TextStyle(
                    color: _isRecording
                        ? const Color(0xFFEF4444)
                        : AppColors.primary,
                    fontSize: ResponsiveHelper.sp(context, 13),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isRecording) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════ RECIPIENT CARD ═══════════════════════
  Widget _buildRecipientCard() {
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('NGƯỜI NHẬN'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...List.generate(_recipients.length, (i) {
                return _buildRecipientChip(_recipients[i], i);
              }),
              if (_isEditing)
                TextButton.icon(
                  onPressed: _showAddRecipientSheet,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Thêm',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(context, 13),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientChip(_Recipient r, int index) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x3300ACB2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x3300ACB2), width: 1.5),
            ),
            child: Image.network(r.imageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(width: 8),
          Text(
            r.name,
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: ResponsiveHelper.sp(context, 14),
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _recipients.removeAt(index);
                  _checkUnsavedChanges();
                });
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: Color(0xFFEF4444)),
              ),
            ),
          ] else
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ═══════════════════════ ACTIVATION CARD ═══════════════════════
  Widget _buildActivationCard() {
    return _CardWrapper(
      child: Row(
        children: [
          _buildCircleIcon(Icons.notifications_active_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kích hoạt',
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontSize: ResponsiveHelper.sp(context, 15),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w500,
                    height: 1.47,
                  ),
                ),
                Text(
                  _isActive ? 'Đang bật' : 'Đã tắt',
                  style: TextStyle(
                    color: _isActive
                        ? const Color(0xFF00ACB2)
                        : const Color(0xFF94A3B8),
                    fontSize: ResponsiveHelper.sp(context, 12),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isActive = !_isActive),
            child: _buildToggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 52,
      height: 28,
      decoration: BoxDecoration(
        color: _isActive ? const Color(0xFF00ACB2) : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: _isActive ? 26 : 3,
            top: 3,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════ PREVIEW BUTTON ═══════════════════════
  Widget _buildPreviewButton() {
    return OutlinedButton.icon(
      onPressed: _showNotificationPreview,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.background,
        side: const BorderSide(color: Color(0x3300ACB2)),
      ),
      icon: const Icon(Icons.visibility_outlined, size: 20),
      label: const Text('Xem trước thông báo'),
    );
  }

  // ═══════════════════════ BOTTOM BAR ═══════════════════════
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0x1900ACB2), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: OutlinedButton(
                onPressed: _handleDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
                child: const Text('Xóa lịch nhắc'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: ElevatedButton(
                onPressed: _handleSave,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Lưu thay đổi'),
                    if (_hasUnsavedChanges) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Chưa lưu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.sp(context, 10),
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════ SHARED WIDGETS ═══════════════════════
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF94A3B8),
        fontSize: ResponsiveHelper.sp(context, 11),
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0x1900ACB2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }

  // ═══════════════════════ ACTIONS ═══════════════════════
  void _toggleEditMode() {
    if (_isEditing) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiêu đề không được để trống'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      _commitSave();
    } else {
      setState(() => _isEditing = true);
    }
  }

  Future<void> _commitSave({bool popAfterSave = false}) async {
    setState(() {
      _isEditing = false;
      _isRecording = false;
      _isPlaying = false;
      _savedTitle = _titleController.text;
      _savedSubtitle = _subtitleController.text;
      _savedTime = _selectedTime;
      _savedFrequency = _selectedFrequency;
      _savedRecipientNames = _recipients.map((r) => r.name).toList();
      _hasUnsavedChanges = false;
    });
    _recordPulseController.stop();

    if (_reminderId > 0) {
      try {
        final timeStr =
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

        String scheduleType = 'daily';
        if (_selectedFrequency.contains('tuần') || _selectedFrequency.contains('Hằng tuần')) {
          scheduleType = 'weekly';
        } else if (_selectedFrequency.contains('chỉnh') || _selectedFrequency.contains('Tùy chỉnh')) {
          scheduleType = 'custom';
        }

        await _dataSource.updateReminder(
          _reminderId,
          title: _savedTitle,
          subtitle: _savedSubtitle,
          reminderTime: timeStr,
          scheduleType: scheduleType,
          isActive: _isActive,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật lịch nhắc: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu thành công'),
        backgroundColor: Color(0xFF00ACB2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (popAfterSave && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiêu đề không được để trống'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _commitSave(popAfterSave: true);
  }

  void _handleDelete() {
    AppDialog.show(
      context: context,
      type: AppDialogType.delete,
      title: 'Xóa lịch nhắc?',
      content: 'Bạn có chắc chắn muốn xóa lịch nhắc "${_titleController.text}" không? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa',
      icon: Icons.delete_outline_rounded,
      onConfirm: () async {
        Navigator.pop(context);
        if (_reminderId > 0) {
          try {
            await _dataSource.deleteReminder(_reminderId);
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
            return;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa lịch nhắc'),
              backgroundColor: Color(0xFF00ACB2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      },
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00ACB2)),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
      _checkUnsavedChanges();
    }
  }

  void _showAddRecipientSheet() {
    final available = _availableMembers
        .where((m) => !_recipients.any((r) => r.name == m.name))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm tất cả thành viên'),
          backgroundColor: Color(0xFF00ACB2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chọn người nhận',
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontSize: ResponsiveHelper.sp(context, 18),
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...available.map((member) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _recipients.add(member);
                        _checkUnsavedChanges();
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0x3300ACB2), width: 2),
                            ),
                            child: Image.network(member.imageUrl,
                                fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            member.name,
                            style: TextStyle(
                              color: const Color(0xFF1E293B),
                              fontSize: ResponsiveHelper.sp(context, 15),
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.add_circle_outline_rounded,
                              color: AppColors.primary, size: 22),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationPreview() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00ACB2), Color(0xFF00A389)],
                            ),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.notifications_active_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nhắc nhở sức khỏe',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 13,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Bây giờ',
                                style: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: ResponsiveHelper.sp(context, 11),
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFF94A3B8), size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 15,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_timeStr \u00B7 $_selectedFrequency',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gửi đến: ${_recipients.map((r) => r.name).join(", ")}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════ CARD WRAPPER ═══════════════════════
class _CardWrapper extends StatelessWidget {
  final Widget child;
  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1A00ACB2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ═══════════════════════ RECIPIENT MODEL ═══════════════════════
class _Recipient {
  final String name;
  final String imageUrl;
  const _Recipient({required this.name, required this.imageUrl});
}
