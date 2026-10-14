import 'package:family_guard/features/calling/presentation/screens/call_flow_models.dart';
import 'package:family_guard/features/tracking/presentation/screens/member_tracking/member_tracking_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InAppCallScreen extends StatelessWidget {
  const InAppCallScreen({super.key, required this.args});

  final InAppCallArgs args;

  static InAppCallArgs fromRoute(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    return routeArgs is InAppCallArgs
        ? routeArgs
        : const InAppCallArgs(
            name: 'Xôi',
            avatarUrl:
                'https://images.unsplash.com/photo-1596870230751-ebdfce98ec42?w=400&q=80',
            role: MemberRole.child,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF01ADB2), Color(0xFF00696C)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: -96,
                top: -96,
                child: _blurOrb(const Color(0x3376F5FA)),
              ),
              Positioned(
                right: -96,
                bottom: -96,
                child: _blurOrb(const Color(0x33E2844C)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        splashRadius: 20,
                        icon: const Icon(
                          Icons.shield_outlined,
                          color: Color(0x26003536),
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'KẾT NỐI ĐƯỢC BẢO VỆ',
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.4,
                              height: 1.33,
                            ),
                          ),
                          const SizedBox(height: 44),
                          Container(
                            width: 176,
                            height: 176,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [Color(0xFF76F5FA), Color(0x80FFFFFF)],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x4D01ADB2),
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  args.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
                                          size: 56,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            args.name,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2844C),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 15,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              args.roleLabel,
                              style: GoogleFonts.beVietnamPro(
                                color: const Color(0xFF592400),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.35,
                                height: 1.43,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _statusDot(Colors.white),
                              const SizedBox(width: 6),
                              _statusDot(Colors.white.withValues(alpha: 0.6)),
                              const SizedBox(width: 6),
                              _statusDot(Colors.white.withValues(alpha: 0.3)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Đang gọi ...',
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(48),
                          topRight: Radius.circular(48),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _glassCallButton(icon: Icons.mic_off_rounded),
                          _glassCallButton(icon: Icons.volume_up_rounded),
                          _glassCallButton(icon: Icons.videocam_off_rounded),
                          GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFFBA1A1A),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x66BA1A1A),
                                    blurRadius: 32,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.call_end_rounded,
                                color: Colors.white,
                                size: 28,
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
        ),
      ),
    );
  }

  Widget _statusDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _glassCallButton({required IconData icon}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _blurOrb(Color color) {
    return Container(
      width: 256,
      height: 256,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
