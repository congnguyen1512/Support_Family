import 'package:flutter/material.dart';
import 'package:family_guard/core/routes/app_routes.dart';
import 'package:family_guard/core/theme/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';

/// ============================================================
/// EMPTY SAFE ZONE SCREEN - Chưa có vùng an toàn
/// Được dịch và sửa lỗi từ Figma Dev Mode export
/// ============================================================
class SafeZoneEmptyScreen extends StatelessWidget {
  const SafeZoneEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppBackHeaderBar(title: 'Vùng an toàn'),
      body: Column(
        children: [

          // ── Body: empty state ──────────────────────────────────
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Nội dung chính – canh giữa màn hình
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Illustration card ────────────────────────
                    Container(
                      width: 280,
                      padding: const EdgeInsets.symmetric(vertical: 44),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          center: Alignment(0.50, 0.50),
                          radius: 0.71,
                          colors: [Color(0x1900ACB2), Color(0x0000ACB2)],
                        ),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Card trắng chứa map illustration
                            Container(
                              width: 192,
                              height: 192,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0x3300ACB2),
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x19000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 8),
                                    spreadRadius: -6,
                                  ),
                                  BoxShadow(
                                    color: Color(0x19000000),
                                    blurRadius: 25,
                                    offset: Offset(0, 20),
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Vòng tròn xanh nhạt bên trong
                                  Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: const Color(0x3300ACB2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Color(0xFF00ACB2),
                                      size: 48,
                                    ),
                                  ),
                                  // Badge chấm xanh (avatar placeholder)
                                  Positioned(
                                    top: 16,
                                    right: 54,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00ACB2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 6,
                                            offset: Offset(0, 4),
                                            spreadRadius: -4,
                                          ),
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 15,
                                            offset: Offset(0, 10),
                                            spreadRadius: -3,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Chấm trang trí nhỏ (trái)
                            Positioned(
                              left: -40,
                              top: 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0x4C00ACB2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Chấm trang trí lớn hơn (phải dưới)
                            Positioned(
                              right: -56,
                              bottom: -16,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0x3300ACB2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Tiêu đề empty state ──────────────────────
                    const Text(
                      'Chưa có vùng an toàn nào',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF00ACB2),
                        fontSize: 24,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 11),

                    // ── Mô tả ────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Hãy tạo vùng an toàn đầu tiên để bắt đầu theo\ndõi người thân của bạn và nhận thông báo kịp\nthời.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                          height: 1.63,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Nút "Thêm vùng an toàn ngay" ─────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.safeZoneAdd);
                        },
                        icon: const Icon(Icons.add_location_alt_rounded, size: 20),
                        label: const Text('Thêm vùng an toàn ngay'),
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


