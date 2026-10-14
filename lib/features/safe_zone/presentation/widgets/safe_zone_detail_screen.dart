import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafeZoneDetailScreen extends StatefulWidget {
  const SafeZoneDetailScreen({super.key});

  @override
  State<SafeZoneDetailScreen> createState() => _SafeZoneDetailScreenState();
}

class _SafeZoneDetailScreenState extends State<SafeZoneDetailScreen> {
  double _radius = 100;
  bool _alwaysActive = true;
  bool _instantNotifications = true;

  final List<_Member> _members = [
    _Member(name: 'Trần Như Kha', role: 'Người lớn', avatarColor: Color(0xFFFED7AA), selected: false),
    _Member(name: 'Bố Xôi', role: 'Người lớn', avatarColor: Color(0xFFDBEAFE), selected: false),
    _Member(name: 'Xôi', role: 'Trẻ em', avatarColor: Color(0xFFE0E7FF), selected: false),
    _Member(name: 'Bà Nội', role: 'Người già', avatarColor: Color(0xFFDCFCE7), selected: true),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFCCEFF0),
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => Navigator.maybePop(context)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MapRadiusCard(
                        radius: _radius,
                        onChanged: (value) => setState(() => _radius = value),
                      ),
                      const SizedBox(height: 24),
                      const _MembersHeading(),
                      const SizedBox(height: 16),
                      _MembersCard(
                        members: _members,
                        onToggle: (index) {
                          setState(() {
                            _members[index] = _members[index].copyWith(selected: !_members[index].selected);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _GhostButton(
                        icon: Icons.person_add_alt_1_rounded,
                        label: 'Thêm thành viên',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 24),
                      const _SectionLabel('LỊCH HOẠT ĐỘNG'),
                      const SizedBox(height: 12),
                      _ScheduleCard(
                        alwaysActive: _alwaysActive,
                        onAlwaysActiveChanged: (value) => setState(() => _alwaysActive = value),
                      ),
                      const SizedBox(height: 20),
                      const _SectionLabel('TRẠNG THÁI'),
                      const SizedBox(height: 12),
                      const _StatusCard(),
                      const SizedBox(height: 20),
                      const _SectionLabel('CÀI ĐẶT NÂNG CAO'),
                      const SizedBox(height: 12),
                      _AdvancedCard(
                        instantNotifications: _instantNotifications,
                        onNotificationsChanged: (value) => setState(() => _instantNotifications = value),
                      ),
                      const SizedBox(height: 20),
                      _DangerButton(
                        icon: Icons.delete_outline,
                        label: 'Xóa Vùng An Toàn',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: const Color(0xFFCCEFF0).withValues(alpha: 0.92),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Nhà Bà Nội',
                    style: TextStyle(
                      color: Color(0xFF111818),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.chevron_left_rounded, color: Color(0xFF17E8E8), size: 20),
                          SizedBox(width: 2),
                          Text(
                            'Vùng An ...',
                            style: TextStyle(
                              color: Color(0xFF17E8E8),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: const Color(0xFF17E8E8),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapRadiusCard extends StatelessWidget {
  const _MapRadiusCard({required this.radius, required this.onChanged});

  final double radius;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    // Map 50m..2000m to a visual diameter range suitable for this preview card.
    final normalized = ((radius - 50) / 1950).clamp(0.0, 1.0);
    final circleSize = lerpDouble(110, 220, normalized)!;

    return Container(
      decoration: _surfaceDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: 256,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE5E7EB), Color(0xFFD1FAE5)],
                      ),
                    ),
                    child: CustomPaint(painter: _MapGridPainter()),
                  ),
                ),
                SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x3317E8E8),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x8017E8E8), width: 2),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -12,
                        top: (circleSize / 2) - 12,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF17E8E8), width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 15,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF0F9AA0)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.location_on_rounded, size: 32, color: Color(0xFF00ACB1)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Bán Kính',
                      style: TextStyle(
                        color: Color(0xFF111818),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${radius.round()}m',
                      style: const TextStyle(
                        color: Color(0xFF17E8E8),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    activeTrackColor: const Color(0xFF17E8E8),
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    thumbColor: Colors.white,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    value: radius,
                    min: 50,
                    max: 2000,
                    onChanged: onChanged,
                  ),
                ),
                const Row(
                  children: [
                    Text(
                      '50m',
                      style: TextStyle(
                        color: Color(0xFF638888),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '2000m',
                      style: TextStyle(
                        color: Color(0xFF638888),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
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

class _MembersHeading extends StatelessWidget {
  const _MembersHeading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thành Viên Được Chỉ Định',
            style: TextStyle(
              color: Color(0xFF111818),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Chọn các thành viên gia đình được giám sát bởi khu vực này.',
            style: TextStyle(
              color: Color(0xFF638888),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.members, required this.onToggle});

  final List<_Member> members;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _surfaceDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++) ...[
            _MemberTile(member: members[i], onTap: () => onToggle(i)),
            if (i != members.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.onTap});

  final _Member member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final roleColor = switch (member.role) {
      'Trẻ em' => const Color(0xFF2563EB),
      'Người già' => const Color(0xFF16A34A),
      _ => const Color(0xFF638888),
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: member.avatarColor,
              child: Text(
                member.name.substring(0, 1),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      color: Color(0xFF111818),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      member.role.toUpperCase(),
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: member.selected ? const Color(0xFF17E8E8) : Colors.transparent,
                border: Border.all(
                  color: member.selected ? const Color(0xFF17E8E8) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: member.selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.alwaysActive, required this.onAlwaysActiveChanged});

  final bool alwaysActive;
  final ValueChanged<bool> onAlwaysActiveChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SwitchRow(
            title: 'Luôn Hoạt Động',
            value: alwaysActive,
            onChanged: onAlwaysActiveChanged,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: const Row(
              children: [
                _TimeChip(label: 'TỪ', value: '8:00 AM'),
                Spacer(),
                Icon(Icons.arrow_forward_rounded, color: Color(0xFF638888), size: 16),
                Spacer(),
                _TimeChip(label: 'ĐẾN', value: '4:00 PM', alignRight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.value, this.alignRight = false});

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF638888),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111818),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, size: 20, color: Color(0xFF16A34A)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng Thái',
                  style: TextStyle(
                    color: Color(0xFF111818),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tất cả thành viên đều trong vùng an toàn',
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ADE80).withValues(alpha: 0.7),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedCard extends StatelessWidget {
  const _AdvancedCard({
    required this.instantNotifications,
    required this.onNotificationsChanged,
  });

  final bool instantNotifications;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _surfaceDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _SwitchRow(
              title: 'Thông báo ngay lập tức',
              value: instantNotifications,
              onChanged: onNotificationsChanged,
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Thời gian lặp lại',
                  style: TextStyle(
                    color: Color(0xFF111818),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  '5 phút',
                  style: TextStyle(
                    color: Color(0xFF638888),
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF638888)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.value, required this.onChanged});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111818),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFF17E8E8),
          inactiveTrackColor: const Color(0xFFE5E7EB),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF638888),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.65,
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x1A17E8E8)),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 30, offset: Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: const Color(0xFF17E8E8)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF17E8E8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 30, offset: Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _surfaceDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 30,
        offset: Offset(0, 8),
      ),
    ],
  );
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x22000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const step = 28.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Member {
  const _Member({
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.selected,
  });

  final String name;
  final String role;
  final Color avatarColor;
  final bool selected;

  _Member copyWith({
    String? name,
    String? role,
    Color? avatarColor,
    bool? selected,
  }) {
    return _Member(
      name: name ?? this.name,
      role: role ?? this.role,
      avatarColor: avatarColor ?? this.avatarColor,
      selected: selected ?? this.selected,
    );
  }
}
