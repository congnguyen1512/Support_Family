import 'package:family_guard/core/constants/app_colors.dart';
import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/notification/popup_error.dart';
import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:family_guard/features/calling/presentation/widgets/call_bottom_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';

class AdultMemberDetailScreen extends StatelessWidget {
  const AdultMemberDetailScreen({super.key, required this.args});

  final MemberTrackingArgs args;

  static MemberTrackingArgs fromRoute(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    return routeArgs is MemberTrackingArgs
        ? routeArgs
        : const MemberTrackingArgs.adultFallback();
  }

  @override
  Widget build(BuildContext context) {
    return _MemberDetailScaffold(
      args: args,
      onCallTap: () => showRoleCallOptionsSheet(
        context,
        target: CallTargetArgs(
          name: args.name,
          avatarUrl: args.avatarUrl,
          role: args.role,
        ),
      ),
    );
  }
}

class _MemberDetailScaffold extends StatefulWidget {
  const _MemberDetailScaffold({required this.args, required this.onCallTap});

  final MemberTrackingArgs args;
  final VoidCallback onCallTap;

  @override
  State<_MemberDetailScaffold> createState() => _MemberDetailScaffoldState();
}

class _MemberDetailScaffoldState extends State<_MemberDetailScaffold> {
  static const List<String> _defaultRelationshipOptions = [
    'Chồng',
    'Vợ',
    'Bố',
    'Mẹ',
    'Anh',
    'Chị',
    'Em',
    'Con',
    'Ông',
    'Bà',
    'Cô',
    'Chú',
    'Bác',
  ];

  late String _relationship;

  List<String> get _relationshipOptions {
    if (_defaultRelationshipOptions.contains(_relationship)) {
      return _defaultRelationshipOptions;
    }

    return [_relationship, ..._defaultRelationshipOptions];
  }

  @override
  void initState() {
    super.initState();
    _relationship = widget.args.relationship;
  }

  Future<void> _showRelationshipDialog() async {
    final selectedRelationship = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _RelationshipEditDialog(
        initialValue: _relationship,
        relationshipOptions: _relationshipOptions,
      ),
    );

    if (!mounted || selectedRelationship == null) {
      return;
    }

    setState(() {
      _relationship = selectedRelationship;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 24),
              child: Column(
                children: [
                  _TopBar(
                    onBack: () => Navigator.maybePop(context),
                    onEdit: _showRelationshipDialog,
                  ),
                  const SizedBox(height: 10),
                  _ProfileCard(
                    args: args,
                    onViewLocation: () => Navigator.maybePop(context),
                    onCallTap: widget.onCallTap,
                  ),
                  const SizedBox(height: 30),
                  _InfoSectionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Thông tin cá nhân',
                    child: Column(
                      children: [
                        _DetailRow(label: 'Tên', value: args.name),
                        _DetailRow(label: 'SĐT', value: args.phoneNumber),
                        _DetailRow(
                          label: 'Quan hệ',
                          value: _relationship,
                          hasDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _LocationHistoryCard(
                    args: args,
                    onReviewTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.routePlayback,
                      arguments: args,
                    ),
                    onLocateTap: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(height: 30),
                  _InfoSectionCard(
                    icon: Icons.smartphone_rounded,
                    title: 'Thông tin thiết bị',
                    child: _DeviceInfoContent(args: args),
                  ),
                  const SizedBox(height: 30),
                  _DeleteButton(
                    onTap: () => showPopupError(
                      context,
                      title: 'Chưa thể xóa thành viên',
                      message:
                          'Luồng xóa thành viên chưa được kết nối ở màn này.',
                      actionLabel: 'Đã hiểu',
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onEdit});

  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              splashRadius: 20,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.brand,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.args,
    required this.onViewLocation,
    required this.onCallTap,
  });

  final MemberTrackingArgs args;
  final VoidCallback onViewLocation;
  final VoidCallback onCallTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 128,
                height: 128,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x3319A7A8), width: 4),
                ),
                child: ClipOval(
                  child: Image.network(
                    args.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF2F4F6),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF94A3B8),
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                args.name,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF191C1E),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 1.33,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8E9EA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  args.roleLabel.toUpperCase(),
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF3C6A6B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF006A6A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                args.status,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF3D4949),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onViewLocation,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      textStyle: GoogleFonts.beVietnamPro(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    child: const Text('Xem Vị Trí'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _RoundActionButton(icon: Icons.call_outlined, onTap: onCallTap),
              const SizedBox(width: 16),
              const _RoundActionButton(icon: Icons.chat_bubble_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFE6E8EA),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF006A6A), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF191C1E),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.hasDivider = true,
  });

  final String label;
  final String value;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: hasDivider
            ? const Border(bottom: BorderSide(color: Color(0x1ABCC9C9)))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF3D4949),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF191C1E),
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

class _LocationHistoryCard extends StatelessWidget {
  const _LocationHistoryCard({
    required this.args,
    required this.onReviewTap,
    required this.onLocateTap,
  });

  final MemberTrackingArgs args;
  final VoidCallback onReviewTap;
  final VoidCallback onLocateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 22,
                color: Color(0xFF006A6A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lịch sử di chuyển',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF191C1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onReviewTap,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF006A6A),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.history_rounded, size: 16),
                label: Text(
                  'Xem lại',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AbsorbPointer(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: args.mapCenter,
                          initialZoom: 15.5,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.familyguard.app',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: args.routeHistory,
                                color: const Color(0xFF26C6C9),
                                strokeWidth: 5,
                                borderColor: Colors.white,
                                borderStrokeWidth: 1.5,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: args.routeHistory.last,
                                width: 28,
                                height: 28,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF14B8C0),
                                      width: 5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x0D006A6A),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 9,
                      ),
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
                        args.timeLabel,
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
                          color: const Color(0xFF006A6A),
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
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceInfoContent extends StatelessWidget {
  const _DeviceInfoContent({required this.args});

  final MemberTrackingArgs args;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'PIN',
                value: '${args.battery}%',
                icon: Icons.battery_charging_full_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricTile(
                label: 'Kết nối',
                value: args.connectionLabel,
                icon: Icons.wifi_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: _DeviceLabelValue(
                  label: 'Thiết bị',
                  value: args.deviceName,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                child: _DeviceLabelValue(
                  label: 'Lần cuối hoạt động',
                  value: args.lastActive,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
              letterSpacing: 0.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: const Color(0xFF006A6A), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF191C1E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceLabelValue extends StatelessWidget {
  const _DeviceLabelValue({
    required this.label,
    required this.value,
    required this.crossAxisAlignment,
    required this.textAlign,
  });

  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: GoogleFonts.beVietnamPro(
            color: const Color(0xFF3D4949),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: textAlign,
          style: GoogleFonts.beVietnamPro(
            color: const Color(0xFF191C1E),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _RelationshipEditDialog extends StatefulWidget {
  const _RelationshipEditDialog({
    required this.initialValue,
    required this.relationshipOptions,
  });

  final String initialValue;
  final List<String> relationshipOptions;

  @override
  State<_RelationshipEditDialog> createState() => _RelationshipEditDialogState();
}

class _RelationshipEditDialogState extends State<_RelationshipEditDialog> {
  late String? _selectedRelation;

  @override
  void initState() {
    super.initState();
    _selectedRelation = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 354),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 50,
              offset: Offset(0, 18),
              spreadRadius: -12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Xác nhận',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 28 / 20,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quan hệ với bạn là:',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _RelationshipDropdown(
              value: _selectedRelation,
              options: widget.relationshipOptions,
              onChanged: (value) {
                setState(() {
                  _selectedRelation = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Xác nhận thành viên trong gia đình của bạn',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 22.75 / 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedRelation == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedRelation),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF4DD1C4),
                  disabledBackgroundColor: const Color(0xFFB4DFDB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                  ),
                ),
                child: Text(
                  'Xác nhận',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                  foregroundColor: const Color(0xFF334155),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                  ),
                ),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelationshipDropdown extends StatelessWidget {
  const _RelationshipDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFE3E9E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1C000000)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            'Lựa chọn mối quan hệ',
            style: GoogleFonts.beVietnamPro(
              color: const Color(0x80171D1D),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6B7280),
            size: 24,
          ),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: const Color(0xFFE3E9E9),
          style: GoogleFonts.beVietnamPro(
            color: const Color(0xFF171D1D),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0x80B8E9EA),
          foregroundColor: const Color(0xFF95491C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
          ),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        child: const Text('Xóa Thành Viên'),
      ),
    );
  }
}
