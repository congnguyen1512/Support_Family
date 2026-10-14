import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:family_guard/core/utils/responsive/responsive.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// ============================================================
/// NOTIFICATION PREVIEW SCREEN – Xem trước thông báo
/// Redesigned: phone mockup thật, notification animation,
/// lock screen / notification bar / in-app tabs,
/// functional sound + complete actions
/// ============================================================
class NotificationPreviewScreen extends StatefulWidget {
  const NotificationPreviewScreen({super.key});

  @override
  State<NotificationPreviewScreen> createState() =>
      _NotificationPreviewScreenState();
}

class _NotificationPreviewScreenState extends State<NotificationPreviewScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────
  int _tabIndex = 0; // 0=Lock Screen, 1=Notification Bar, 2=In App
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isPlayingSound = false;
  bool _isCompleted = false;

  // ── Animation ──────────────────────────────────────────────────
  late final AnimationController _notifSlideCtrl;
  late final Animation<Offset> _notifSlide;
  late final AnimationController _completeFadeCtrl;
  late final Animation<double> _completeFade;

  // ── Clock ──────────────────────────────────────────────────────
  late Timer _clockTimer;
  String _timeStr = '';
  String _dateStr = '';

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateClock());

    _notifSlideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _notifSlide = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _notifSlideCtrl, curve: Curves.easeOutBack));

    _completeFadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _completeFade =
        Tween<double>(begin: 1.0, end: 0.0).animate(_completeFadeCtrl);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _notifSlideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _notifSlideCtrl.dispose();
    _completeFadeCtrl.dispose();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
      final months = [
        '', 'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6',
        'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12'
      ];
      _dateStr =
          '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month]}';
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.horizontalPadding(context),
                8,
                ResponsiveHelper.horizontalPadding(context),
                16,
              ),
              child: Column(children: [
                // Phone mockup
                _buildPhoneMockup(),
                const SizedBox(height: 20),
                // Info
                _buildScheduleInfo(),
                const SizedBox(height: 16),
                // Preview tabs
                _buildPreviewTabs(),
                const SizedBox(height: 16),
                // Toggles
                _buildToggles(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
          _buildBottomButton(),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return const AppBackHeaderBar(
      title: 'Xem trước thông báo',
    );
  }
  // ── Phone Mockup ──────────────────────────────────────────────
  Widget _buildPhoneMockup() {
    return LayoutBuilder(builder: (context, constraints) {
      final phoneW = min(constraints.maxWidth * 0.72, 300.0);
      final phoneH = phoneW * 2.05;
      final bezelW = max(phoneW * 0.02, 3.0);
      final outerR = phoneW * 0.12;
      final innerR = outerR - bezelW;

      return Center(
        child: SizedBox(
          width: phoneW + bezelW * 2 + 24,
          height: phoneH + bezelW * 2 + 16,
          child: Stack(children: [
            // ── Side buttons ────────────────────────────────────
            // Power button (right)
            Positioned(
              right: 0,
              top: phoneH * 0.28,
              child: Container(
                width: 4, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3B39),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Volume up (left)
            Positioned(
              left: 0,
              top: phoneH * 0.22,
              child: Container(
                width: 4, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3B39),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Volume down (left)
            Positioned(
              left: 0,
              top: phoneH * 0.30,
              child: Container(
                width: 4, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3B39),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Phone body ─────────────────────────────────────
            Center(
              child: Container(
                width: phoneW + bezelW * 2,
                height: phoneH + bezelW * 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1D1A),
                  borderRadius: BorderRadius.circular(outerR),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 40,
                        offset: Offset(0, 20),
                        spreadRadius: -8),
                    BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4)),
                  ],
                  // Glossy bezel effect
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D3B39), Color(0xFF0C1D1A), Color(0xFF1A2E2B)],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(bezelW),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(innerR),
                    ),
                    child: Stack(children: [
                      // ── Wallpaper ─────────────────────────────
                      _buildWallpaper(),

                      // ── Status bar ────────────────────────────
                      _buildStatusBar(phoneW),

                      // ── Screen content by tab ─────────────────
                      if (_tabIndex == 0) _buildLockScreenContent(phoneW, phoneH),
                      if (_tabIndex == 1) _buildNotificationBarContent(phoneW, phoneH),
                      if (_tabIndex == 2) _buildInAppContent(phoneW, phoneH),

                      // ── Home indicator ────────────────────────
                      Positioned(
                        bottom: 8,
                        left: 0, right: 0,
                        child: Center(
                          child: Container(
                            width: phoneW * 0.35, height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(120),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),

            // ── Dynamic Island ──────────────────────────────────
            Positioned(
              top: bezelW + 6,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  width: phoneW * 0.28,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1D1A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  // ── Wallpaper (gradient, no external images) ──────────────────
  Widget _buildWallpaper() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A4A),
              Color(0xFF0D2B3E),
              Color(0xFF14344A),
              Color(0xFF1B4050),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: CustomPaint(painter: _WallpaperAccentPainter()),
      ),
    );
  }

  // ── Status bar ────────────────────────────────────────────────
  Widget _buildStatusBar(double phoneW) {
    final scale = (phoneW / 300).clamp(0.6, 1.0);
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20 * scale, 34, 20 * scale, 6),
        child: Row(children: [
          Text(_timeStr,
              style: TextStyle(
                fontFamily: 'Lexend', fontSize: 13 * scale,
                fontWeight: FontWeight.w600, color: Colors.white,
              )),
          const Spacer(),
          // Signal
          Icon(Icons.signal_cellular_alt_rounded,
              size: 14 * scale, color: Colors.white),
          SizedBox(width: 4 * scale),
          // WiFi
          Icon(Icons.wifi_rounded, size: 14 * scale, color: Colors.white),
          SizedBox(width: 4 * scale),
          // Battery
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 20 * scale, height: 10 * scale,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 2 * scale, height: 5 * scale,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB 0: LOCK SCREEN
  // ══════════════════════════════════════════════════════════════════
  Widget _buildLockScreenContent(double phoneW, double phoneH) {
    final scale = (phoneW / 300).clamp(0.55, 1.0);
    return Stack(children: [
      // Clock + date
      Positioned(
        top: phoneH * 0.12,
        left: 0, right: 0,
        child: Column(children: [
          Text(_timeStr,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 56 * scale,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 1.0,
                letterSpacing: 2,
              )),
          const SizedBox(height: 4),
          Text(_dateStr,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w400,
                color: Colors.white.withAlpha(200),
              )),
        ]),
      ),

      // Notification
      Positioned(
        top: phoneH * 0.32,
        left: 10, right: 10,
        child: SlideTransition(
          position: _notifSlide,
          child: FadeTransition(
            opacity: _completeFade,
            child: _buildNotificationBubble(scale),
          ),
        ),
      ),

      // Completed overlay
      if (_isCompleted)
        Positioned(
          top: phoneH * 0.32,
          left: 10, right: 10,
          child: _buildCompletedBadge(scale),
        ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB 1: NOTIFICATION BAR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildNotificationBarContent(double phoneW, double phoneH) {
    final scale = (phoneW / 300).clamp(0.55, 1.0);
    return Stack(children: [
      // Pull-down shade
      Positioned.fill(
        child: Container(
          color: const Color(0xFF0D2B3E).withAlpha(220),
        ),
      ),

      // Date + clear
      Positioned(
        top: 54 * scale,
        left: 14, right: 14,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_dateStr,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            Text('Xóa tất cả',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 11 * scale,
                  color: Colors.white.withAlpha(160),
                )),
          ],
        ),
      ),

      // Notification
      Positioned(
        top: 86 * scale,
        left: 10, right: 10,
        child: SlideTransition(
          position: _notifSlide,
          child: FadeTransition(
            opacity: _completeFade,
            child: _buildNotificationBubble(scale),
          ),
        ),
      ),

      if (_isCompleted)
        Positioned(
          top: 86 * scale,
          left: 10, right: 10,
          child: _buildCompletedBadge(scale),
        ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB 2: IN APP
  // ══════════════════════════════════════════════════════════════════
  Widget _buildInAppContent(double phoneW, double phoneH) {
    final scale = (phoneW / 300).clamp(0.55, 1.0);
    return Stack(children: [
      // Simulated app background
      Positioned.fill(
        child: Container(
          color: AppColors.background.withAlpha(230),
        ),
      ),

      // App header bar
      Positioned(
        top: 44 * scale,
        left: 0, right: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
          color: Colors.white,
          child: Row(children: [
            Icon(Icons.favorite_rounded,
                size: 20 * scale, color: const Color(0xFF00ACB2)),
            SizedBox(width: 8 * scale),
            Text('Support Family',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF006D5B),
                )),
          ]),
        ),
      ),

      // In-app notification banner
      Positioned(
        top: 86 * scale,
        left: 8, right: 8,
        child: SlideTransition(
          position: _notifSlide,
          child: FadeTransition(
            opacity: _completeFade,
            child: _buildInAppBanner(scale),
          ),
        ),
      ),

      if (_isCompleted)
        Positioned(
          top: 86 * scale,
          left: 8, right: 8,
          child: _buildCompletedBadge(scale),
        ),
    ]);
  }

  // ── Notification bubble (iOS style) ───────────────────────────
  Widget _buildNotificationBubble(double scale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(18 * scale),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // App header row
        Row(children: [
          Container(
            width: 22 * scale, height: 22 * scale,
            decoration: BoxDecoration(
              color: AppColors.kPrimaryLight,
              borderRadius: BorderRadius.circular(6 * scale),
            ),
            child: Icon(Icons.favorite_rounded,
                size: 13 * scale, color: const Color(0xFF00ACB2)),
          ),
          SizedBox(width: 6 * scale),
          Text('SUPPORT FAMILY',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 10 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              )),
          const Spacer(),
          Text('bây giờ',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 10 * scale,
                color: const Color(0xFF9CA3AF),
              )),
        ]),
        SizedBox(height: 8 * scale),

        // Notification content
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38 * scale, height: 38 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(Icons.medication_rounded,
                size: 20 * scale, color: const Color(0xFFFF8FAB)),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uống thuốc huyết áp',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0C1D1A),
                    )),
                SizedBox(height: 2 * scale),
                Text('Đã đến giờ uống thuốc, bà nhớ uống nhé!',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 11 * scale,
                      color: const Color(0xFF6B7280),
                    )),
              ],
            ),
          ),
        ]),
        SizedBox(height: 10 * scale),

        // Action buttons
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: _handlePlaySound,
              child: Container(
                height: 34 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF00ACB2),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPlayingSound
                          ? Icons.pause_rounded
                          : Icons.volume_up_rounded,
                      size: 15 * scale, color: Colors.white,
                    ),
                    SizedBox(width: 4 * scale),
                    Text(
                      _isPlayingSound ? 'Đang phát...' : 'Phát âm thanh',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: GestureDetector(
              onTap: _handleComplete,
              child: Container(
                height: 34 * scale,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF00ACB2), width: 1.5),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Center(
                  child: Text('Hoàn thành',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00ACB2),
                      )),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── In-app banner (slightly different style) ──────────────────
  Widget _buildInAppBanner(double scale) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x1900ACB2)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1400ACB2), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44 * scale, height: 44 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Icon(Icons.medication_rounded,
                size: 24 * scale, color: const Color(0xFFFF8FAB)),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uống thuốc huyết áp',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0C1D1A),
                    )),
                SizedBox(height: 2 * scale),
                Text('Đã đến giờ uống thuốc, bà nhớ uống nhé!',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12 * scale,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    )),
              ],
            ),
          ),
        ]),
        SizedBox(height: 12 * scale),

        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: _handlePlaySound,
              child: Container(
                height: 38 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF00ACB2),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPlayingSound
                          ? Icons.pause_rounded
                          : Icons.volume_up_rounded,
                      size: 16 * scale, color: Colors.white,
                    ),
                    SizedBox(width: 4 * scale),
                    Text(
                      _isPlayingSound ? 'Đang phát...' : 'Phát âm thanh',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: GestureDetector(
              onTap: _handleComplete,
              child: Container(
                height: 38 * scale,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF00ACB2), width: 1.5),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Center(
                  child: Text('Hoàn thành',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00ACB2),
                      )),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── Completed badge ───────────────────────────────────────────
  Widget _buildCompletedBadge(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: 20 * scale, horizontal: 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 36 * scale, height: 36 * scale,
          decoration: const BoxDecoration(
            color: AppColors.kPrimaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded,
              size: 22 * scale, color: const Color(0xFF00ACB2)),
        ),
        SizedBox(width: 10 * scale),
        Text('Đã hoàn thành!',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00ACB2),
            )),
      ]),
    );
  }

  // ── Schedule info ─────────────────────────────────────────────
  Widget _buildScheduleInfo() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('LỊCH NHẮC NHỞ',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: ResponsiveHelper.sp(context, 11),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF45A191),
            letterSpacing: 1.4,
          )),
      const SizedBox(height: 4),
      Text.rich(
        TextSpan(children: [
          TextSpan(
            text: 'Thông báo sẽ xuất hiện lúc ',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: ResponsiveHelper.sp(context, 14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0C1D1A),
            ),
          ),
          TextSpan(
            text: '08:00',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: ResponsiveHelper.sp(context, 14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00ACB2),
            ),
          ),
        ]),
        textAlign: TextAlign.center,
      ),
    ]);
  }

  // ── Preview tabs ──────────────────────────────────────────────
  Widget _buildPreviewTabs() {
    final tabs = ['Lock Screen', 'Notification Bar', 'In App'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_tabIndex != i) {
                  setState(() {
                    _tabIndex = i;
                    _isCompleted = false;
                    _isPlayingSound = false;
                  });
                  _completeFadeCtrl.reset();
                  _notifSlideCtrl.forward(from: 0);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? const [
                          BoxShadow(
                              color: Color(0x1400ACB2),
                              blurRadius: 6,
                              offset: Offset(0, 2)),
                        ]
                      : null,
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: ResponsiveHelper.sp(context, 12),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF006D5B)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Toggles ───────────────────────────────────────────────────
  Widget _buildToggles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1900ACB2)),
      ),
      child: Column(children: [
        _toggleRow(
          icon: Icons.volume_up_rounded,
          label: 'Kèm âm thanh',
          value: _soundEnabled,
          onChanged: (v) => setState(() => _soundEnabled = v),
        ),
        const Divider(height: 20, color: Color(0xFFF1F5F9)),
        _toggleRow(
          icon: Icons.vibration_rounded,
          label: 'Rung',
          value: _vibrationEnabled,
          onChanged: (v) => setState(() => _vibrationEnabled = v),
        ),
      ]),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.kPrimaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF00ACB2)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(label,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: ResponsiveHelper.sp(context, 14),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            )),
      ),
      GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48, height: 28,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: value ? const Color(0xFF00ACB2) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Bottom button ─────────────────────────────────────────────
  Widget _buildBottomButton() {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x1900ACB2))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: const Text('Đã lưu cài đặt thông báo',
                    style: TextStyle(fontFamily: 'Lexend', color: Colors.white)),
                backgroundColor: const Color(0xFF00ACB2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ));
            Navigator.pop(context);
          },
          child: const Text('Lưu và Quay lại'),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════════
  void _handlePlaySound() {
    if (_isCompleted) return;
    setState(() => _isPlayingSound = !_isPlayingSound);
    if (_isPlayingSound) {
      // Simulate sound playing for 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlayingSound) {
          setState(() => _isPlayingSound = false);
        }
      });
    }
  }

  void _handleComplete() {
    if (_isCompleted) return;
    setState(() => _isPlayingSound = false);
    _completeFadeCtrl.forward().then((_) {
      if (mounted) setState(() => _isCompleted = true);
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// WALLPAPER ACCENT PAINTER – subtle circles/orbs over gradient
// ═══════════════════════════════════════════════════════════════════
class _WallpaperAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Large blurry orb top-right
    paint.color = const Color(0xFF00ACB2).withAlpha(18);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.15),
      size.width * 0.5,
      paint,
    );

    // Medium orb bottom-left
    paint.color = const Color(0xFF006D5B).withAlpha(15);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.75),
      size.width * 0.4,
      paint,
    );

    // Small accent orb center
    paint.color = const Color(0xFF00ACB2).withAlpha(10);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.25,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}


