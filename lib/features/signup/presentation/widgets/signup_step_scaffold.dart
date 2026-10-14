import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupStepScaffold extends StatelessWidget {
  const SignupStepScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepIndex,
    required this.buttonText,
    required this.child,
    this.onPrimaryPressed,
  });

  final String title;
  final String subtitle;
  final int stepIndex;
  final String buttonText;
  final Widget child;
  final VoidCallback? onPrimaryPressed;

  static const _bg = Color(0xFFEFF3F4);
  static const _titleColor = Color(0xFF0F172A);
  static const _subColor = Color(0xFF475569);
  static const _accent = Color(0xFF07A9B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(onBack: () => Navigator.maybePop(context)),
                    const SizedBox(height: 26),
                    Center(
                      child: Text(
                        title,
                        style: GoogleFonts.publicSans(
                          color: _titleColor,
                          fontSize: 48 / 2,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: SizedBox(
                        width: 320,
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.publicSans(
                            color: _subColor,
                            fontSize: 17 / 2,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _StepIndicator(current: stepIndex),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEFF3F4),
                border: Border(top: BorderSide(color: Color(0xFFD6E7EA))),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onPrimaryPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.publicSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 26),
          ),
        ),
        Text(
          'Đăng ký',
          style: GoogleFonts.publicSans(
            color: const Color(0xFF0D8E96),
            fontSize: 40 / 2,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = current == index;
        return Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF07A9B0) : const Color(0xFFA8DEE3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
