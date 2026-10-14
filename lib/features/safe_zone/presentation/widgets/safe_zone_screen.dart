import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:flutter/material.dart';
import 'package:family_guard/features/safe_zone/presentation/widgets/safe_zone_active_screen.dart';

class SafeZoneScreen extends StatelessWidget {
  SafeZoneScreen({super.key});

  final List<Map<String, dynamic>> members = [
    {
      'id': 'm1',
      'name': 'Nguyễn Văn A',
      'role': 'Người cao tuổi',
      'avatar': 'A',
      'activeZones': 2,
      'color': const Color(0xFF80CBC4),
    },
    {
      'id': 'm2',
      'name': 'Trần Thị B',
      'role': 'Người cao tuổi',
      'avatar': 'B',
      'activeZones': 1,
      'color': const Color(0xFFFFCC80),
    },
    {
      'id': 'm3',
      'name': 'Lê Văn C',
      'role': 'Người chăm sóc',
      'avatar': 'C',
      'activeZones': 3,
      'color': const Color(0xFFCE93D8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72 + topInset),
        child: SafeArea(
          bottom: false,
          child: AppBackHeaderBar(
            title: 'Vùng an toàn',
            onBack: () => Navigator.pop(context),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Chọn thành viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xFF00ACB2).withValues(alpha: 0.15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: member['color'] as Color,
                          child: Text(
                            member['avatar'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      member['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['role'] as String,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.shield,
                              size: 12,
                              color: Color(0xFF00ACB2),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${member["activeZones"]} vùng an toàn đang bật',
                              style: const TextStyle(
                                color: Color(0xFF00ACB2),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF00ACB2),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SafeZoneMemberScreen(member: member),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


