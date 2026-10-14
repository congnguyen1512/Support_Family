import 'package:flutter/material.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/theme/legacy_app_text_styles.dart';
import 'package:family_guard/core/theme/app_dimens.dart';
import 'package:family_guard/core/theme/app_shadows.dart';
import 'package:family_guard/features/reminder/domain/entities/reminder_type.dart';

import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/features/reminder/data/datasources/reminder_remote_data_source.dart';

/// Screen 3: Tạo lịch nhắc mới (Create New Reminder)
/// Cho phép người dùng tạo lịch nhắc nhở mới với:
/// - Chọn loại nhắc nhở (Thuốc, Ăn uống, Sức khỏe, Khác)
/// - Nhập tiêu đề
/// - Chọn thời gian
/// - Chọn tần suất lặp lại
/// - Ghi âm giọng nói
class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  // Danh sách loại nhắc nhở
  static const List<ReminderType> _reminderTypes = [
    ReminderType(
      id: 'medicine',
      label: 'Thuốc',
      icon: Icons.medication_outlined,
      iconColor: Color(0xFFE84C6F),
      backgroundColor: AppColors.reminderPink,
    ),
    ReminderType(
      id: 'food',
      label: 'Ăn uống',
      icon: Icons.restaurant_outlined,
      iconColor: Color(0xFFF5A623),
      backgroundColor: AppColors.reminderYellow,
    ),
    ReminderType(
      id: 'health',
      label: 'Sức khỏe',
      icon: Icons.favorite_outline,
      iconColor: Color(0xFF42A5F5),
      backgroundColor: AppColors.reminderBlue,
    ),
    ReminderType(
      id: 'other',
      label: 'Khác',
      icon: Icons.grid_view_rounded,
      iconColor: AppColors.primary,
      backgroundColor: AppColors.iconBgTeal,
    ),
  ];

  final ReminderRemoteDataSource _dataSource = ReminderRemoteDataSourceImpl();
  String _selectedTypeId = 'other';
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String _selectedRepeat = 'Mỗi ngày';
  String? _targetMemberId;
  String? _targetMemberName;
  bool _isSubmitting = false;
  bool _didInitArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitArgs) {
      _didInitArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _targetMemberId = args['memberId']?.toString();
        _targetMemberName = args['memberName']?.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacing24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimens.spacing16),

                      // Reminder type selector
                      _buildReminderTypeSection(),

                      const SizedBox(height: AppDimens.spacing24),

                      // Title input
                      _buildTitleInput(),

                      const SizedBox(height: AppDimens.spacing24),

                      // Time picker
                      _buildTimePicker(context),

                      const SizedBox(height: AppDimens.spacing24),

                      // Repeat selector
                      _buildRepeatSelector(),

                      const SizedBox(height: AppDimens.spacing24),

                      // Voice recording section
                      _buildVoiceRecordingSection(),

                      const SizedBox(height: AppDimens.spacing24),
                    ],
                  ),
                ),
              ),

              // Submit button - pinned to bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.spacing24, AppDimens.spacing12,
                  AppDimens.spacing24, AppDimens.spacing24,
                ),
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header: nút quay lại + tiêu đề căn giữa
  Widget _buildHeader(BuildContext context) {
    return AppBackHeaderBar(
      title: _targetMemberName != null && _targetMemberName!.isNotEmpty
          ? 'Lịch nhắc cho $_targetMemberName'
          : 'Tạo lịch nhắc mới',
    );
  }

  /// Section: Chọn loại nhắc nhở (2x2 grid)
  Widget _buildReminderTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại nhắc nhở',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppDimens.spacing12),
        Row(
          children: _reminderTypes.map((type) {
            final isSelected = type.id == _selectedTypeId;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != _reminderTypes.last ? 12 : 0,
                ),
                child: _buildReminderTypeCard(type, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Card cho từng loại nhắc nhở
  Widget _buildReminderTypeCard(ReminderType type, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeId = type.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedCardBg : AppColors.surface,
          borderRadius: AppDimens.borderRadiusLarge,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? AppShadows.small : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: type.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                type.icon,
                color: type.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: AppDimens.spacing8),
            // Label
            Text(
              type.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primaryDark : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Input: Tiêu đề nhắc nhở
  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiêu đề',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppDimens.spacing8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: AppDimens.borderRadiusLarge,
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: TextField(
            controller: _titleController,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập tiêu đề nhắc nhở',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spacing16,
                vertical: AppDimens.spacing14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Row: Chọn thời gian
  Widget _buildTimePicker(BuildContext context) {
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời gian',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppDimens.spacing8),
        GestureDetector(
          onTap: () => _pickTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacing16,
              vertical: AppDimens.spacing14,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: AppDimens.borderRadiusLarge,
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: AppDimens.iconMedium,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimens.spacing12),
                Text(
                  timeStr,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: AppDimens.iconMedium,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Row: Chọn tần suất lặp lại
  Widget _buildRepeatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lặp lại',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppDimens.spacing8),
        GestureDetector(
          onTap: _showRepeatOptions,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacing16,
              vertical: AppDimens.spacing14,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: AppDimens.borderRadiusLarge,
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppDimens.iconMedium,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimens.spacing12),
                Text(
                  _selectedRepeat,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: AppDimens.iconMedium,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  /// Section: Ghi âm giọng nói
  Widget _buildVoiceRecordingSection() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.voiceRecording),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.selectedCardBg,
          borderRadius: AppDimens.borderRadiusXLarge,
        ),
        child: Column(
          children: [
            // Mic button
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_none_rounded,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimens.spacing12),
            // Description text
            Text(
              'Nhấn để ghi âm nhắc nhở bằng giọng nói',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Button: Tạo lịch nhắc (primary, full-width)
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeightXLarge,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _onSubmit,
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text('Tạo lịch nhắc'),
      ),
    );
  }

  // ── Actions ──
  Future<void> _pickTime(BuildContext context) async {
    final picked = await TimePickerBottomSheet.show(
      context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showRepeatOptions() {
    Navigator.pushNamed(context, AppRoutes.repeatFrequency).then((result) {
      if (result != null && result is Map) {
        setState(() {
          _selectedRepeat = result['mode'] as String? ?? _selectedRepeat;
        });
      }
    });
  }

  Future<void> _onSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tiêu đề nhắc nhở'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimens.borderRadiusMedium,
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final timeStr =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      String scheduleType = 'daily';
      if (_selectedRepeat.contains('tuần') || _selectedRepeat.contains('Hàng tuần')) {
        scheduleType = 'weekly';
      } else if (_selectedRepeat.contains('lần') || _selectedRepeat.contains('Một lần')) {
        scheduleType = 'once';
      } else if (_selectedRepeat.contains('chỉnh') || _selectedRepeat.contains('Tùy chỉnh')) {
        scheduleType = 'custom';
      }

      await _dataSource.createReminder(
        title: title,
        reminderTime: timeStr,
        category: _selectedTypeId,
        scheduleType: scheduleType,
        memberUid: _targetMemberId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã tạo lịch nhắc thành công'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimens.borderRadiusMedium,
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tạo lịch nhắc: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimens.borderRadiusMedium,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Gradient Background phổ biến trong Figma design
/// Sử dụng cho toàn bộ screen có gradient teal background
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ?? const [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Custom Time Picker Bottom Sheet - Dựa trên Figma frame "Chọn thời gian"
/// Hiển thị 3 scroll wheels: Giờ, Phút, AM/PM
/// Trả về TimeOfDay khi người dùng xác nhận
class TimePickerBottomSheet extends StatefulWidget {
  final TimeOfDay initialTime;

  const TimePickerBottomSheet({
    super.key,
    required this.initialTime,
  });

  /// Hiển thị bottom sheet và trả về TimeOfDay đã chọn (hoặc null nếu hủy)
  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimePickerBottomSheet(initialTime: initialTime),
    );
  }

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  late int _selectedHour; // 1-12
  late int _selectedMinute; // 0-59
  late int _selectedPeriod; // 0=AM, 1=PM

  // Kích thước mỗi item trong wheel
  static const double _itemExtent = 44.0;

  @override
  void initState() {
    super.initState();
    // Chuyển từ 24h → 12h AM/PM
    final h24 = widget.initialTime.hour;
    _selectedPeriod = h24 >= 12 ? 1 : 0;
    _selectedHour = h24 % 12 == 0 ? 12 : h24 % 12;
    _selectedMinute = widget.initialTime.minute;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _periodController = FixedExtentScrollController(initialItem: _selectedPeriod);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusRound),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.handleBar,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCircle),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spacing24,
                vertical: AppDimens.spacing16,
              ),
              child: Text(
                'Chọn thời gian',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Scroll wheels
            SizedBox(
              height: 240,
              child: Stack(
                children: [
                  // Selection highlight band
                  Center(
                    child: Container(
                      height: 56,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimens.spacing24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppDimens.borderRadiusXLarge,
                        border: Border.all(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  // Wheels row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.spacing40,
                    ),
                    child: Row(
                      children: [
                        // Hour wheel (1–12)
                        Expanded(
                          child: _buildWheel(
                            controller: _hourController,
                            itemCount: 12,
                            labelBuilder: (i) =>
                                (i + 1).toString().padLeft(2, '0'),
                            onChanged: (i) =>
                                setState(() => _selectedHour = i + 1),
                            selectedIndex: _selectedHour - 1,
                          ),
                        ),

                        // Minute wheel (0–59)
                        Expanded(
                          child: _buildWheel(
                            controller: _minuteController,
                            itemCount: 60,
                            labelBuilder: (i) => i.toString().padLeft(2, '0'),
                            onChanged: (i) =>
                                setState(() => _selectedMinute = i),
                            selectedIndex: _selectedMinute,
                          ),
                        ),

                        // AM/PM wheel
                        Expanded(
                          child: _buildWheel(
                            controller: _periodController,
                            itemCount: 2,
                            labelBuilder: (i) => i == 0 ? 'AM' : 'PM',
                            onChanged: (i) =>
                                setState(() => _selectedPeriod = i),
                            selectedIndex: _selectedPeriod,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top fade gradient
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.surface,
                              AppColors.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom fade gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.surface,
                              AppColors.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.spacing24,
                AppDimens.spacing16,
                AppDimens.spacing24,
                AppDimens.spacing40,
              ),
              child: Column(
                children: [
                  // Xác nhận button
                  SizedBox(
                    width: double.infinity,
                    height: AppDimens.buttonHeightXLarge,
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      child: const Text('Xác nhận'),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacing12),
                  // Hủy bỏ text button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Hủy bỏ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single scroll wheel column
  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
    required ValueChanged<int> onChanged,
    required int selectedIndex,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.005,
      diameterRatio: 1.5,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final isSelected = index == selectedIndex;
          // Distance from selected — for opacity gradient
          final distance = (index - selectedIndex).abs();
          final isFar = distance >= 2;

          return Center(
            child: Text(
              labelBuilder(index),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSelected ? 24 : (isFar ? 18 : 20),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : (isFar ? AppColors.handleBar : AppColors.textHint),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onConfirm() {
    // Chuyển lại sang 24h
    int hour24 = _selectedHour % 12;
    if (_selectedPeriod == 1) hour24 += 12;
    final result = TimeOfDay(hour: hour24, minute: _selectedMinute);
    Navigator.pop(context, result);
  }
}
