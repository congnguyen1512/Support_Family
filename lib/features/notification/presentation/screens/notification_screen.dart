// ignore_for_file: unused_element, unused_element_parameter, unused_field

import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_route_observer.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:family_guard/features/notification/domain/entities/app_notification.dart';
import 'package:family_guard/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:family_guard/features/tracking/presentation/widgets/senior_fall_alert_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
    this.homeRouteName = AppRoutes.home,
    this.trackingRouteName = AppRoutes.tracking,
    this.notificationsRouteName = AppRoutes.notifications,
    this.settingsRouteName = AppRoutes.settings,
    this.showBottomNav = true,
  });

  final String homeRouteName;
  final String trackingRouteName;
  final String notificationsRouteName;
  final String settingsRouteName;
  final bool showBottomNav;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with RouteAware {
  _NotificationFilter selectedFilter = _NotificationFilter.all;
  late final NotificationCubit _cubit;
  String? _lastErrorMessage;
  String? _lastSuccessMessage;
  bool _showMemberConfirmation = true;
  ModalRoute<dynamic>? _route;

  void _handleMemberConfirmation(bool accepted) {
    setState(() => _showMemberConfirmation = false);
    final message = accepted
        ? 'Đã xác nhận thêm người thân vào nhóm gia đình.'
        : 'Đã hủy yêu cầu xác nhận người thân.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  void initState() {
    super.initState();
    _cubit = NotificationCubit(
      getNotificationsUseCase: AppDependencies.instance.getNotificationsUseCase,
      respondNotificationUseCase:
          AppDependencies.instance.respondNotificationUseCase,
      realtimeClient: AppDependencies.instance.realtimeClient,
    )..addListener(_handleCubitChanged);
    _cubit.loadNotifications();
    _cubit.startRealtime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _route) {
      if (_route is PageRoute) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _cubit.removeListener(_handleCubitChanged);
    _cubit.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _cubit.loadNotifications(showLoader: false);
  }

  void _handleCubitChanged() {
    final state = _cubit.state;

    if (state.errorMessage != null &&
        state.errorMessage!.isNotEmpty &&
        state.errorMessage != _lastErrorMessage &&
        mounted) {
      _lastErrorMessage = state.errorMessage;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    if (state.successMessage != null &&
        state.successMessage!.isNotEmpty &&
        state.successMessage != _lastSuccessMessage &&
        mounted) {
      _lastSuccessMessage = state.successMessage;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _respondToNotification({
    required int notificationId,
    required bool accepted,
  }) async {
    if (accepted) {
      await _cubit.confirmNotification(notificationId);
      return;
    }

    await _cubit.cancelNotification(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(
                  settingsRouteName: widget.settingsRouteName,
                  showBackButton: !widget.showBottomNav,
                  onBack: () => Navigator.maybePop(context),
                ),
                const SizedBox(height: 10),
                _FilterBar(
                  selectedFilter: selectedFilter,
                  onSelected: (filter) =>
                      setState(() => selectedFilter = filter),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      widget.showBottomNav ? 110 : 20,
                    ),
                    children: _buildNotificationItems(context),
                  ),
                ),
              ],
            ),
            if (widget.showBottomNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppFlowBottomNav(
                  current: AppNavTab.notifications,
                  homeRouteName: widget.homeRouteName,
                  trackingRouteName: widget.trackingRouteName,
                  settingsRouteName: widget.settingsRouteName,
                  thirdTabRouteName: widget.notificationsRouteName,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildApiNotificationItems() {
    final items = <Widget>[];
    final notifications = _cubit.state.notifications;

    if (_cubit.state.isLoading && notifications.isEmpty) {
      return const [
        SizedBox(height: 12),
        Center(child: CircularProgressIndicator()),
      ];
    }

    for (final notification in notifications) {
      final isActionable = _isActionableNotification(notification);
      final isFallAlert = _isFallAlertNotification(notification);
      items.add(const SizedBox(height: 12));
      items.add(
        isFallAlert
            ? _SeniorFallMapCard(
                title: _buildNotificationTitle(notification),
                content: _buildNotificationContent(notification),
                timeLabel: _formatNotificationTime(notification.createdAt),
                onOpenMapTap: () => _openFallAlertMap(notification.id),
              )
            : _ApiMemberConfirmationCard(
                title: _buildNotificationTitle(notification),
                content: _buildNotificationContent(notification),
                timeLabel: _formatNotificationTime(notification.createdAt),
                showActions: isActionable && notification.processing != 'done',
                onConfirm: () => _respondToNotification(
                  notificationId: notification.id,
                  accepted: true,
                ),
                onCancel: () => _respondToNotification(
                  notificationId: notification.id,
                  accepted: false,
                ),
              ),
      );
    }

    return items;
  }

  bool _isActionableNotification(AppNotification notification) {
    final senderName = (notification.senderName ?? '').trim();
    final senderRelation = (notification.senderRelation ?? '').trim();
    return senderName.isNotEmpty || senderRelation.isNotEmpty;
  }

  bool _isFallAlertNotification(AppNotification notification) {
    final title = notification.title.toLowerCase();
    final content = notification.content.toLowerCase();
    return title.contains('té ngã') || content.contains('té ngã');
  }

  Future<void> _openFallAlertMap(int notificationId) async {
    AppNotification? notification;
    for (final item in _cubit.state.notifications) {
      if (item.id == notificationId) {
        notification = item;
        break;
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeniorFallAlertMapScreen(
          fallLatitude: notification?.fallLatitude,
          fallLongitude: notification?.fallLongitude,
          seniorLabel: notification == null
              ? null
              : ((notification.senderName ?? '').trim().isNotEmpty
                    ? notification.senderName!.trim()
                    : _buildNotificationTitle(notification)),
        ),
      ),
    );
  }

  String _buildNotificationTitle(AppNotification notification) {
    if (_isFallAlertNotification(notification)) {
      final title = notification.title.trim();
      return title.isEmpty ? 'Cảnh báo té ngã' : title;
    }

    if (_isActionableNotification(notification)) {
      return 'Xác nhận mối quan hệ';
    }

    final title = notification.title.trim();
    return title.isEmpty ? 'Thông báo' : title;
  }

  String _buildNotificationContent(AppNotification notification) {
    if (_isFallAlertNotification(notification)) {
      final content = notification.content.trim();
      return content.isNotEmpty
          ? content
          : 'Phạm Thị Thư(mechong_condau) vừa được phát hiện té ngã. Vui lòng kiểm tra ngay vị trí hiện tại.';
    }

    final senderName = (notification.senderName ?? '').trim();
    final senderRelation = (notification.senderRelation ?? '').trim();
    if (senderName.isNotEmpty && senderRelation.isNotEmpty) {
      return 'Bạn có một lời mời xác nhận mối quan hệ từ $senderName($senderRelation). Xác nhận ngay?';
    }

    if (senderName.isNotEmpty) {
      return 'Bạn có một lời mời xác nhận mối quan hệ từ $senderName. Xác nhận ngay?';
    }

    final content = notification.content.trim();
    if (content.isNotEmpty) {
      return content;
    }

    return 'Bạn có một lời mời xác nhận mối quan hệ mới. Xác nhận ngay?';
  }

  String _formatNotificationTime(DateTime? value) {
    if (value == null) {
      return 'Vừa xong';
    }

    final local = value.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    }
    if (difference.inDays < 1) {
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }

  List<Widget> _buildNotificationItems(BuildContext context) {
    return [
      const _DateDivider(label: 'Hôm nay'),
      ..._buildApiNotificationItems(),
    ];
  }
}

enum _NotificationFilter { all, emergency, activity, mood }

class _Header extends StatelessWidget {
  const _Header({
    required this.settingsRouteName,
    this.showBackButton = false,
    this.onBack,
  });

  final String settingsRouteName;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(24, 8, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showBackButton)
            IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF334155),
                size: 20,
              ),
              tooltip: 'Quay lại',
            ),
          Expanded(
            child: Text(
              'Thông báo',
              style: GoogleFonts.inter(
                color: const Color(0xFF0F172A),
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.75,
                height: 1,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, settingsRouteName),
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF334155),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selectedFilter, required this.onSelected});

  final _NotificationFilter selectedFilter;
  final ValueChanged<_NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = [
      _FilterItem(
        label: 'Tất cả',
        icon: Icons.check,
        filter: _NotificationFilter.all,
        activeColor: Color(0xFF17E8E8),
        borderColor: Color(0xFF17E8E8),
        iconColor: Color(0xFF0F172A),
      ),
      _FilterItem(
        label: 'Khẩn cấp',
        icon: Icons.warning_amber_rounded,
        filter: _NotificationFilter.emergency,
        activeColor: Color(0xFFFEE2E2),
        borderColor: Color(0xFFFECACA),
        iconColor: Color(0xFFEF4444),
      ),
      _FilterItem(
        label: 'Hoạt động',
        icon: Icons.show_chart_rounded,
        filter: _NotificationFilter.activity,
        activeColor: Color(0xFFE2F6F8),
        borderColor: Color(0xFFE2E8F0),
        iconColor: Color(0xFF64748B),
      ),
      _FilterItem(
        label: 'Mood',
        icon: Icons.sentiment_satisfied_alt_outlined,
        filter: _NotificationFilter.mood,
        activeColor: Color(0xFFFEFCE8),
        borderColor: Color(0xFFFEF08A),
        iconColor: Color(0xFFA16207),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final filter = filters[index];
          final isActive = selectedFilter == filter.filter;
          final bgColor = isActive ? filter.activeColor : Colors.white;
          final borderColor = isActive
              ? Colors.transparent
              : filter.borderColor;

          return Padding(
            padding: EdgeInsets.only(
              right: index == filters.length - 1 ? 0 : 11,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onSelected(filter.filter),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(filter.icon, size: 18, color: filter.iconColor),
                    const SizedBox(width: 6),
                    Text(
                      filter.label,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF334155),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterItem {
  const _FilterItem({
    required this.label,
    required this.icon,
    required this.filter,
    required this.activeColor,
    required this.borderColor,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final _NotificationFilter filter;
  final Color activeColor;
  final Color borderColor;
  final Color iconColor;
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
      ],
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.onDetailTap});

  final VoidCallback onDetailTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFEE2E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -12,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF17E8E8),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x9917E8E8), blurRadius: 8),
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Phát hiện té ngã',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFEF4444),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '10:32 AM',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Camera phòng khách phát hiện có\nngười ngã ở phòng khách.',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF475569),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: onDetailTap,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Chi tiết',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Bỏ qua',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.onCheckTap});

  final VoidCallback onCheckTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFEE2E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF6B6B),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Cảnh báo',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFEF4444),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '2:10 PM',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Xôi đã phát đi cảnh báo khẩn cấp. Hãy\nkiểm tra ngay!!!',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onCheckTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kiểm tra',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeniorFallMapCard extends StatelessWidget {
  const _SeniorFallMapCard({
    this.title = 'Bà nội có thể đang bị té',
    this.content =
        'Tín hiệu té ngã đang được theo dõi theo thời gian thực. Mở bản đồ để xem vị trí hiện tại của bà.',
    this.timeLabel = 'Vừa xong',
    required this.onOpenMapTap,
  });

  final String title;
  final String content;
  final String timeLabel;
  final VoidCallback onOpenMapTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFECACA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.personal_injury_rounded,
              color: Color(0xFFDC2626),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFDC2626),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        timeLabel,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFB91C1C),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7F1D1D),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onOpenMapTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Xem vị trí',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeZoneCard extends StatelessWidget {
  const _SafeZoneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -12,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF17E8E8),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x9917E8E8), blurRadius: 8),
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x1A17E8E8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF00ACB1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Rời khỏi khu vực an toàn',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '11:45 AM',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Xôi đã rời khỏi khu vực an toàn "Trường\nhọc".\nHiện đang di chuyển với tốc độ 15 km/\ngiờ.',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF475569),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.map_outlined,
                              size: 28,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Xem vị trí',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.onCheckTap});

  final VoidCallback onCheckTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFEF9C3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              color: Color(0xFFA16207),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Thông báo tâm trạng',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '2:10 PM',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Xôi cho biết anh cảm thấy "lo lắng" suốt\n3 ngày liên tiếp.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onCheckTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kiểm tra',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA16207),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Color(0xFFA16207),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OlderNotificationCard extends StatelessWidget {
  const _OlderNotificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.battery_1_bar_rounded,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Pin yếu',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hôm qua',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pin điện thoại của Xôi còn dưới 15%.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiMemberConfirmationCard extends StatelessWidget {
  const _ApiMemberConfirmationCard({
    required this.title,
    required this.content,
    required this.timeLabel,
    this.showActions = true,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;
  final String content;
  final String timeLabel;
  final bool showActions;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFB),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFCCFBF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF0EA5A8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      timeLabel,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                if (showActions) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onConfirm,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00ACB2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Xác nhận',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: onCancel,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Hủy',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberConfirmationCard extends StatelessWidget {
  const _MemberConfirmationCard({
    required this.title,
    required this.content,
    required this.timeLabel,
    this.showActions = true,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;
  final String content;
  final String timeLabel;
  final bool showActions;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFB),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFCCFBF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF0EA5A8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Xác nhận người thân',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Vừa xong',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Nguyễn Thị Loan(Mẹ) vừa gửi yêu cầu tham gia nhóm gia đình để chia sẻ vị trí và trạng thái an toàn.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onConfirm,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00ACB2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Xác nhận',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: onCancel,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Hủy',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF334155),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
