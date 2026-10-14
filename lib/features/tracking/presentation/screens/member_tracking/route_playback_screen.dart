import 'dart:math' as math;

import 'package:family_guard/core/constants/app_colors.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class RoutePlaybackScreen extends StatefulWidget {
  const RoutePlaybackScreen({super.key, required this.args});

  final MemberTrackingArgs args;

  static MemberTrackingArgs fromRoute(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    return routeArgs is MemberTrackingArgs
        ? routeArgs
        : const MemberTrackingArgs.adultFallback();
  }

  @override
  State<RoutePlaybackScreen> createState() => _RoutePlaybackScreenState();
}

class _RoutePlaybackScreenState extends State<RoutePlaybackScreen>
    with SingleTickerProviderStateMixin {
  static const double _defaultSpeed = 2;
  static const double _basePlaybackSeconds = 18;

  final Distance _distance = const Distance();
  late final AnimationController _controller;
  late double _progress;
  double _speed = _defaultSpeed;

  bool get _isPlaying => _controller.isAnimating;

  @override
  void initState() {
    super.initState();
    _progress = _progressFromTimeLabel(
      widget.args.timeLabel,
      widget.args.playbackStartLabel,
      widget.args.playbackEndLabel,
    );
    _controller = AnimationController(vsync: this, value: _progress)
      ..addListener(() {
        setState(() => _progress = _controller.value);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPoint = _interpolatePoint(widget.args.routeHistory, _progress);
    final currentTimeLabel = _timeLabelForProgress(
      _progress,
      widget.args.playbackStartLabel,
      widget.args.playbackEndLabel,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlaybackTopBar(
                    onBack: () => Navigator.maybePop(context),
                    onPickDate: _handlePickDate,
                  ),
                  const SizedBox(height: 17),
                  _PlaybackMapCard(
                    args: widget.args,
                    currentPoint: currentPoint,
                    currentTimeLabel: currentTimeLabel,
                    onLocateTap: () => Navigator.popUntil(
                      context,
                      (route) =>
                          route.settings.name == AppRoutes.tracking ||
                          route.isFirst,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PlaybackControlsCard(
                    progress: _progress,
                    isPlaying: _isPlaying,
                    speed: _speed,
                    startLabel: widget.args.playbackStartLabel,
                    endLabel: widget.args.playbackEndLabel,
                    onPrevious: _jumpBackward,
                    onPlayPause: _togglePlayback,
                    onNext: _jumpForward,
                    onChanged: _handleSliderChanged,
                    onSpeedSelected: _selectSpeed,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Tổng quan',
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF191C1E),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.52,
                    children: [
                      _SummaryTile(
                        label: 'TỔNG QUÃNG ĐƯỜNG',
                        value: widget.args.totalDistanceLabel,
                      ),
                      _SummaryTile(
                        label: 'TỔNG THỜI GIAN',
                        value: widget.args.totalDurationLabel,
                      ),
                      _SummaryTile(
                        label: 'DỪNG NGHỈ',
                        value: '${widget.args.stopCount}',
                      ),
                      _SummaryTile(
                        label: 'TỐC ĐỘ TB',
                        value: widget.args.averageSpeedLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lịch trình',
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF191C1E),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Timeline(items: widget.args.timelineItems),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(
                        context,
                        (route) =>
                            route.settings.name == AppRoutes.tracking ||
                            route.isFirst,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006A6A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                        textStyle: GoogleFonts.beVietnamPro(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.56,
                        ),
                      ),
                      child: const Text('Xem vị trí hiện tại'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _handlePickDate,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF006A6A),
                        textStyle: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      child: const Text('Chọn ngày khác'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _controller.stop();
      setState(() {});
      return;
    }

    final remaining = 1 - _progress;
    if (remaining <= 0) {
      _controller.value = 0;
      _progress = 0;
    }

    final durationMs = math.max(
      1,
      ((1 - _controller.value) * _basePlaybackSeconds * 1000 / _speed).round(),
    );

    _controller.animateTo(
      1,
      duration: Duration(milliseconds: durationMs),
      curve: Curves.linear,
    );
    setState(() {});
  }

  void _jumpBackward() {
    _controller.stop();
    final next = (_progress - 0.15).clamp(0.0, 1.0);
    _controller.value = next;
    setState(() => _progress = next);
  }

  void _jumpForward() {
    _controller.stop();
    final next = (_progress + 0.15).clamp(0.0, 1.0);
    _controller.value = next;
    setState(() => _progress = next);
  }

  void _handleSliderChanged(double value) {
    _controller.stop();
    _controller.value = value;
    setState(() => _progress = value);
  }

  void _selectSpeed(double value) {
    final wasPlaying = _isPlaying;
    _controller.stop();
    setState(() => _speed = value);
    if (wasPlaying) {
      _togglePlayback();
    }
  }

  Future<void> _handlePickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chọn ${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.year}',
        ),
      ),
    );
  }

  double _progressFromTimeLabel(String current, String start, String end) {
    final startMinutes = _parseTimeLabel(start);
    final endMinutes = _parseTimeLabel(end);
    final currentMinutes = _parseTimeLabel(current);

    if (startMinutes == null || endMinutes == null || currentMinutes == null) {
      return 0.32;
    }

    final total = endMinutes - startMinutes;
    if (total <= 0) {
      return 0.32;
    }

    return ((currentMinutes - startMinutes) / total).clamp(0.0, 1.0);
  }

  String _timeLabelForProgress(double progress, String start, String end) {
    final startMinutes = _parseTimeLabel(start);
    final endMinutes = _parseTimeLabel(end);
    if (startMinutes == null ||
        endMinutes == null ||
        endMinutes <= startMinutes) {
      return widget.args.timeLabel;
    }

    final totalMinutes = endMinutes - startMinutes;
    final currentMinutes = startMinutes + (totalMinutes * progress).round();
    return _formatMinutes(currentMinutes);
  }

  int? _parseTimeLabel(String label) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)$').firstMatch(label);
    if (match == null) {
      return null;
    }

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final suffix = match.group(3)!;

    if (suffix == 'AM') {
      if (hour == 12) {
        hour = 0;
      }
    } else if (hour != 12) {
      hour += 12;
    }

    return hour * 60 + minute;
  }

  String _formatMinutes(int totalMinutes) {
    final hour24 = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    final suffix = hour24 >= 12 ? 'PM' : 'AM';
    var hour12 = hour24 % 12;
    if (hour12 == 0) {
      hour12 = 12;
    }

    return '${hour12.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} $suffix';
  }

  LatLng _interpolatePoint(List<LatLng> points, double progress) {
    if (points.isEmpty) {
      return widget.args.mapCenter;
    }
    if (points.length == 1) {
      return points.first;
    }

    final segmentLengths = <double>[];
    var totalLength = 0.0;

    for (var index = 0; index < points.length - 1; index++) {
      final length = _distance.as(
        LengthUnit.Meter,
        points[index],
        points[index + 1],
      );
      segmentLengths.add(length);
      totalLength += length;
    }

    if (totalLength == 0) {
      return points.last;
    }

    final target = totalLength * progress.clamp(0.0, 1.0);
    var traversed = 0.0;

    for (var index = 0; index < segmentLengths.length; index++) {
      final nextTraversed = traversed + segmentLengths[index];
      if (target <= nextTraversed || index == segmentLengths.length - 1) {
        final begin = points[index];
        final end = points[index + 1];
        final localDistance = segmentLengths[index] == 0
            ? 0.0
            : (target - traversed) / segmentLengths[index];
        return LatLng(
          begin.latitude + (end.latitude - begin.latitude) * localDistance,
          begin.longitude + (end.longitude - begin.longitude) * localDistance,
        );
      }
      traversed = nextTraversed;
    }

    return points.last;
  }
}

class _PlaybackTopBar extends StatelessWidget {
  const _PlaybackTopBar({required this.onBack, required this.onPickDate});

  final VoidCallback onBack;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            splashRadius: 20,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onPickDate,
            splashRadius: 20,
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF191C1E),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackMapCard extends StatelessWidget {
  const _PlaybackMapCard({
    required this.args,
    required this.currentPoint,
    required this.currentTimeLabel,
    required this.onLocateTap,
  });

  final MemberTrackingArgs args;
  final LatLng currentPoint;
  final String currentTimeLabel;
  final VoidCallback onLocateTap;

  @override
  Widget build(BuildContext context) {
    final startPoint = args.routeHistory.isNotEmpty
        ? args.routeHistory.first
        : args.mapCenter;

    return Container(
      height: 437,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: args.mapCenter,
                initialZoom: 14.8,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.familyguard.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: args.routeHistory,
                      color: const Color(0xFF43CDD0),
                      strokeWidth: 5,
                      borderColor: Colors.white.withValues(alpha: 0.7),
                      borderStrokeWidth: 1.2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: startPoint,
                      width: 36,
                      height: 36,
                      child: _MapDot(
                        borderColor: Colors.white,
                        fillColor: const Color(0xFF43CDD0),
                        outerColor: const Color(0x3343CDD0),
                      ),
                    ),
                    Marker(
                      point: currentPoint,
                      width: 32,
                      height: 32,
                      child: _MapDot(
                        borderColor: Colors.white,
                        fillColor: Colors.white,
                        ringColor: const Color(0xFF16B8BE),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                currentTimeLabel,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF006A6A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: InkWell(
              onTap: onLocateTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  const _MapDot({
    required this.borderColor,
    required this.fillColor,
    this.outerColor,
    this.ringColor,
  });

  final Color borderColor;
  final Color fillColor;
  final Color? outerColor;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(shape: BoxShape.circle, color: outerColor),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: ringColor ?? borderColor,
                width: ringColor == null ? 3 : 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaybackControlsCard extends StatelessWidget {
  const _PlaybackControlsCard({
    required this.progress,
    required this.isPlaying,
    required this.speed,
    required this.startLabel,
    required this.endLabel,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onChanged,
    required this.onSpeedSelected,
  });

  final double progress;
  final bool isPlaying;
  final double speed;
  final String startLabel;
  final String endLabel;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onSpeedSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlIconButton(
                icon: Icons.skip_previous_rounded,
                onTap: onPrevious,
              ),
              const SizedBox(width: 32),
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB8E9EA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFF4A6060),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              _ControlIconButton(icon: Icons.skip_next_rounded, onTap: onNext),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: const Color(0xFFE6E8EA),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              thumbColor: AppColors.primary,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(value: progress, onChanged: onChanged),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Text(
                  startLabel,
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF3D4949),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  endLabel,
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF3D4949),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SpeedChip(
                label: '1x',
                selected: speed == 1,
                onTap: () => onSpeedSelected(1),
              ),
              const SizedBox(width: 12),
              _SpeedChip(
                label: '2x',
                selected: speed == 2,
                onTap: () => onSpeedSelected(2),
              ),
              const SizedBox(width: 12),
              _SpeedChip(
                label: '5x',
                selected: speed == 5,
                onTap: () => onSpeedSelected(5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlIconButton extends StatelessWidget {
  const _ControlIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      splashRadius: 20,
      icon: Icon(icon, color: const Color(0xFF3D4949), size: 24),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  const _SpeedChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFBCC9C9),
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.beVietnamPro(
            color: selected ? Colors.white : const Color(0xFF3D4949),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF3D4949),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              height: 1.5,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF006A6A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});

  final List<TrackingTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return _TimelineRow(
          item: item,
          showConnector: index < items.length - 1,
        );
      }),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.showConnector});

  final TrackingTimelineItem item;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final connectorHeight = item.highlighted ? 64.0 : 44.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _TimelineDot(highlighted: item.highlighted),
                if (showConnector)
                  Container(
                    width: 2,
                    height: connectorHeight,
                    color: const Color(0x4DBCC9C9),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _TimelineCard(item: item)),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.highlighted});

  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0x3319A7A8) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: highlighted
              ? const Color(0xFF006A6A)
              : const Color(0xFFBCC9C9),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: highlighted ? 10 : 8,
          height: highlighted ? 10 : 8,
          decoration: BoxDecoration(
            color: highlighted
                ? const Color(0xFF006A6A)
                : const Color(0xFFBCC9C9),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.item});

  final TrackingTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = item.highlighted;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isHighlighted ? 13 : 0,
        vertical: isHighlighted ? 13 : 0,
      ),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0x1A19A7A8) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(color: const Color(0x1A006A6A))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.timeLabel,
            style: GoogleFonts.beVietnamPro(
              color: isHighlighted
                  ? const Color(0xFF006A6A)
                  : const Color(0xFF3D4949),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: GoogleFonts.beVietnamPro(
              color: isHighlighted
                  ? const Color(0xFF003536)
                  : const Color(0xFF191C1E),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
