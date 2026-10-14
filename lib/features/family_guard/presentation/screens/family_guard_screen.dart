import 'package:flutter/material.dart';

class FamilyGuardScreen extends StatefulWidget {
  const FamilyGuardScreen({super.key});

  @override
  State<FamilyGuardScreen> createState() => _FamilyGuardScreenState();
}

class _FamilyGuardScreenState extends State<FamilyGuardScreen> {
  final Color _primary = const Color(0xFF87E4DB);
  final Color _textDark = const Color(0xFF374151);
  final Color _muted = const Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildMapCard(),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'Thông tin nhanh',
                          rows: const [
                            _InfoRow(icon: Icons.access_time, label: 'Thời gian dùng hôm nay', value: '2h 30p'),
                            _InfoRow(icon: Icons.play_circle_fill, label: 'Ứng dụng dùng nhiều nhất', value: 'Youtube'),
                            _InfoRow(icon: Icons.wifi, label: 'Kết nối', value: 'Wifi'),
                            _InfoRow(icon: Icons.battery_full, label: 'Pin điện thoại', value: '85%'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          title: 'Lịch sử di chuyển',
                          rows: const [
                            _InfoRow(icon: Icons.logout, label: 'Rời khỏi nhà', value: '5:30'),
                            _InfoRow(icon: Icons.park_outlined, label: 'Đến công viên', value: '6:00'),
                            _InfoRow(icon: Icons.logout, label: 'Rời khỏi công viên', value: '7:30'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          title: 'Khu vực an toàn',
                          rows: const [
                            _InfoRow(icon: Icons.home_filled, label: 'Nhà', value: 'Đang trong vùng'),
                            _InfoRow(icon: Icons.park, label: 'Công viên', value: 'Ngoài vùng'),
                            _InfoRow(icon: Icons.local_cafe, label: 'Cà phê gần nhà', value: 'Ngoài vùng'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      color: _primary.withValues(alpha: 0.35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _circleButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=256&q=80',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFE5E7EB),
                  child: const Icon(Icons.person, color: Colors.grey, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Như Quỳnh (Mẹ)',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF04B8BA),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Đang ở nhà',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(width: 1, height: 14, color: _muted.withValues(alpha: 0.4)),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Cập nhật 1 phút trước',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _circleButton(icon: Icons.more_horiz, onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 220,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFE0F2F1),
                    child: const Center(
                      child: Icon(Icons.map, color: Colors.teal, size: 40),
                    ),
                  ),
                ),
              ),
              Positioned(top: 36, left: 48, child: _mapPin(color: Colors.blue.shade400)),
              Positioned(top: 60, right: 52, child: _mapPin(color: Colors.blue.shade400)),
              Positioned(bottom: 60, left: 140, child: _mapPin(color: Colors.blue.shade400)),
              Positioned(bottom: 64, left: 180, child: _mapPin(color: Colors.orange.shade600, withAvatar: true)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.map, color: Colors.black87, size: 18),
                          label: Text(
                            'Xem trên bản đồ',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 30, color: Colors.black.withValues(alpha: 0.25)),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.videocam, color: Colors.black87, size: 18),
                          label: Text(
                            'Theo dõi trực tiếp',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<_InfoRow> rows}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  _InfoRowTile(row: rows[i], textColor: _textDark, muted: _muted),
                  if (i != rows.length - 1)
                    const Divider(color: Color(0xFFF0F0F0), height: 18, thickness: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final actions = [
      _BottomAction(icon: Icons.warning_rounded, label: 'Cảnh báo'),
      _BottomAction(icon: Icons.phone_in_talk, label: 'Gọi ngay'),
      _BottomAction(icon: Icons.lock_outline, label: 'Khóa thiết bị'),
      _BottomAction(icon: Icons.sos, label: 'SOS khẩn'),
    ];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(item.icon, color: _textDark, size: 26),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: _textDark),
      ),
    );
  }

  Widget _mapPin({required Color color, bool withAvatar = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.location_on, color: color, size: 34),
        if (withAvatar)
          const CircleAvatar(
            radius: 10,
            backgroundImage: NetworkImage('https://placehold.co/80x80/png'),
          ),
      ],
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
}

class _InfoRowTile extends StatelessWidget {
  const _InfoRowTile({required this.row, required this.textColor, required this.muted});
  final _InfoRow row;
  final Color textColor;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(row.icon, color: muted, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            row.label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ),
        Text(
          row.value,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BottomAction {
  const _BottomAction({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
