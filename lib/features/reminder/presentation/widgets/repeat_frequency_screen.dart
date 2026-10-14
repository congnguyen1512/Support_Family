import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/theme/legacy_app_text_styles.dart';
import 'package:family_guard/core/theme/app_dimens.dart';
import 'package:family_guard/core/theme/app_shadows.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// Screen: Tần suất lặp lại (Repeat Frequency)
/// Cho phép người dùng cấu hình:
/// - Loại lặp lại: Hàng ngày / Hàng tuần / Tùy chỉnh
/// - Chọn ngày trong tuần (T2–CN)
/// - Bật/tắt giới hạn khung giờ
/// - Chọn khung giờ hoạt động (08:00 – 22:00)
class RepeatFrequencyScreen extends StatefulWidget {
  /// Repeat mode ban đầu (index 0=Hàng ngày, 1=Hàng tuần, 2=Tùy chỉnh)
  final int initialModeIndex;

  /// Các ngày đã chọn ban đầu (0=T2 … 6=CN)
  final Set<int> initialSelectedDays;

  const RepeatFrequencyScreen({
    super.key,
    this.initialModeIndex = 0,
    this.initialSelectedDays = const {0, 2, 4}, // T2, T4, T6
  });

  @override
  State<RepeatFrequencyScreen> createState() => _RepeatFrequencyScreenState();
}

class _RepeatFrequencyScreenState extends State<RepeatFrequencyScreen> {
  static const List<String> _modes = ['Hàng ngày', 'Hàng tuần', 'Tùy chỉnh'];
  static const List<String> _dayLabels = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  late int _selectedMode;
  late Set<int> _selectedDays;
  bool _timeLimitEnabled = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialModeIndex;
    _selectedDays = Set.from(widget.initialSelectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header (frosted white bar)
          _buildHeader(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppDimens.spacing16,
                AppDimens.spacing24,
                AppDimens.spacing16,
                AppDimens.spacing24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mode tabs
                  _buildModeTabs(),

                  const SizedBox(height: AppDimens.spacing32),

                  // Day-of-week selector
                  _buildDaySelector(),

                  const SizedBox(height: AppDimens.spacing32),

                  // Time range card
                  _buildTimeRangeCard(),

                  const SizedBox(height: AppDimens.spacing32),

                  // Info tip
                  _buildInfoTip(),
                ],
              ),
            ),
          ),

          // Bottom save button
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(BuildContext context) {
    return const AppBackHeaderBar(
      title: 'Tần suất lặp lại',
    );
  }

  // ── Mode tabs (Hàng ngày / Hàng tuần / Tùy chỉnh) ──

  Widget _buildModeTabs() {
    return SizedBox(
      height: 40,
      child: Row(
        children: List.generate(_modes.length, (i) {
          final isActive = i == _selectedMode;
          return Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                right: i < _modes.length - 1 ? AppDimens.spacing8 : 0,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMode = i;
                    if (i == 0) {
                      _selectedDays = {0, 1, 2, 3, 4, 5, 6};
                    } else if (i == 1) {
                      _selectedDays = {0, 1, 2, 3, 4};
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.spacing16,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.tealTint,
                    borderRadius: BorderRadius.circular(AppDimens.radiusCircle),
                    border: isActive
                        ? null
                        : Border.all(color: AppColors.borderPrimary),
                    boxShadow: isActive ? AppShadows.small : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _modes[i],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isActive ? Colors.white : AppColors.textDark,
                      fontWeight: isActive ? FontWeight.w400 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Day-of-week selector ──

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn ngày trong tuần',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimens.spacing16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(_dayLabels.length, (i) {
            final isSelected = _selectedDays.contains(i);
            return Padding(
              padding: EdgeInsets.only(
                right: i < _dayLabels.length - 1 ? AppDimens.spacing8 : 0,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(i);
                    } else {
                      _selectedDays.add(i);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.tealTint),
                    boxShadow: isSelected ? AppShadows.small : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _dayLabels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.sp(context, 14),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : AppColors.tealMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Time Range card ──

  Widget _buildTimeRangeCard() {
    final timeRangeStr =
        '${_formatTime(_startTime)} - ${_formatTime(_endTime)}';

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.spacing16,
        AppDimens.spacing16,
        AppDimens.spacing16,
        AppDimens.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.borderRadiusRound,
        border: Border.all(color: AppColors.tealTint),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          // Toggle row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chỉ hoạt động trong khoảng',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đặt giới hạn thời gian nhận thông báo',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tealMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle switch
              GestureDetector(
                onTap: () =>
                    setState(() => _timeLimitEnabled = !_timeLimitEnabled),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _timeLimitEnabled
                        ? AppColors.primary
                        : AppColors.handleBar,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCircle),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _timeLimitEnabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_timeLimitEnabled) ...[
            const SizedBox(height: AppDimens.spacing16),
            // Divider
            Container(
              height: 1,
              color: AppColors.tealTint,
            ),
            const SizedBox(height: AppDimens.spacing16),

            // Time range display
            GestureDetector(
              onTap: _pickTimeRange,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppDimens.spacing8),
                    decoration: BoxDecoration(
                      color: AppColors.tealTint,
                      borderRadius: AppDimens.borderRadiusXLarge,
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.spacing12),
                  Text(
                    timeRangeStr,
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.all(AppDimens.spacing8),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: AppDimens.iconMedium,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Info tip ──

  Widget _buildInfoTip() {
    return Container(
      padding: EdgeInsets.all(AppDimens.spacing16),
      decoration: BoxDecoration(
        color: AppColors.tealTint.withValues(alpha: 0.3),
        borderRadius: AppDimens.borderRadiusRound,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 22,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppDimens.spacing12),
          Expanded(
            child: Text(
              'Các lời nhắc sẽ được gửi định kỳ vào các ngày đã chọn trong khung giờ này.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.7),
                height: 1.63,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom save button ──

  Widget _buildBottomBar() {
    return Container(
      padding: AppDimens.paddingAll16,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        border: const Border(
          top: BorderSide(color: AppColors.tealTint),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: AppDimens.buttonHeightXLarge,
          child: ElevatedButton(
            onPressed: _onSave,
            child: const Text('Lưu thay đổi'),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTimeRange() async {
    final start = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'Chọn giờ bắt đầu',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: _endTime,
      helpText: 'Chọn giờ kết thúc',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (end == null || !mounted) return;

    setState(() {
      _startTime = start;
      _endTime = end;
    });
  }

  void _onSave() {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn ít nhất 1 ngày'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu tần suất lặp lại'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, {
      'mode': _modes[_selectedMode],
      'days': _selectedDays.toList()..sort(),
      'timeLimitEnabled': _timeLimitEnabled,
      'startTime': _startTime,
      'endTime': _endTime,
    });
  }
}


