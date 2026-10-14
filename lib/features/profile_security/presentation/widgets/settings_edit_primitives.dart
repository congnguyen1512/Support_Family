import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kSettingsShellBackground = Color(0xFFF0F8F7);
const Color kSettingsAccent = Color(0xFF17E8E8);
const Color kSettingsTitle = Color(0xFF111818);
const Color kSettingsSubtitle = Color(0xFF638888);
const Color kSettingsDivider = Color(0xFFF3F4F6);

class SettingsEditScaffold extends StatelessWidget {
  const SettingsEditScaffold({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.onCancel,
    required this.onSave,
    this.description,
    required this.children,
  });

  final String appBarTitle;
  final String title;
  final String? description;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSettingsShellBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EditActionBar(
                appBarTitle: appBarTitle,
                onCancel: onCancel,
                onSave: onSave,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.beVietnamPro(
                  color: kSettingsTitle,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.85,
                  height: 1.25,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: GoogleFonts.beVietnamPro(
                    color: kSettingsSubtitle,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsEditTextScreen extends StatefulWidget {
  const SettingsEditTextScreen({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.initialValue,
    this.description,
    this.keyboardType,
  });

  final String appBarTitle;
  final String title;
  final String initialValue;
  final String? description;
  final TextInputType? keyboardType;

  @override
  State<SettingsEditTextScreen> createState() => _SettingsEditTextScreenState();
}

class _SettingsEditTextScreenState extends State<SettingsEditTextScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue)
      ..addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTextChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
  }

  void _handleSave() {
    final value = _controller.text.trim();
    Navigator.of(context).pop(value.isEmpty ? widget.initialValue : value);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsEditScaffold(
      appBarTitle: widget.appBarTitle,
      title: widget.title,
      description: widget.description,
      onCancel: () => Navigator.of(context).pop(),
      onSave: _handleSave,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: widget.keyboardType,
            cursorColor: Colors.red,
            style: GoogleFonts.beVietnamPro(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: widget.initialValue,
              hintStyle: GoogleFonts.beVietnamPro(
                color: const Color(0xFF94A3B8),
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _controller.clear,
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: Color(0xFF9CA3AF),
                        size: 16,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsChoiceScreen extends StatefulWidget {
  const SettingsChoiceScreen({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.options,
    required this.initialSelected,
    this.description,
  });

  final String appBarTitle;
  final String title;
  final String? description;
  final List<String> options;
  final String initialSelected;

  @override
  State<SettingsChoiceScreen> createState() => _SettingsChoiceScreenState();
}

class _SettingsChoiceScreenState extends State<SettingsChoiceScreen> {
  late String _selected = widget.initialSelected;

  @override
  Widget build(BuildContext context) {
    return SettingsEditScaffold(
      appBarTitle: widget.appBarTitle,
      title: widget.title,
      description: widget.description,
      onCancel: () => Navigator.of(context).pop(),
      onSave: () => Navigator.of(context).pop(_selected),
      children: [
        SettingsSurfaceCard(
          borderRadius: 20,
          child: Column(
            children: List.generate(widget.options.length, (index) {
              final option = widget.options[index];
              final isSelected = option == _selected;
              return Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _selected = option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: GoogleFonts.beVietnamPro(
                                color: option == 'Thêm...'
                                    ? const Color(0xFF566060)
                                    : kSettingsTitle,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF00ACB2),
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (index < widget.options.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kSettingsDivider,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class SettingsSurfaceCard extends StatelessWidget {
  const SettingsSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SettingsPasswordFieldRow extends StatelessWidget {
  const SettingsPasswordFieldRow({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 106,
            child: Text(
              label,
              style: GoogleFonts.beVietnamPro(
                color: kSettingsTitle,
                fontSize: 17,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: true,
              textAlign: TextAlign.right,
              cursorColor: kSettingsAccent,
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF6B7280),
                fontSize: 17,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '***************',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditActionBar extends StatelessWidget {
  const _EditActionBar({
    required this.appBarTitle,
    required this.onCancel,
    required this.onSave,
  });

  final String appBarTitle;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: kSettingsAccent,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.chevron_left_rounded, size: 18),
              label: Text(
                'Hủy',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ),
          Text(
            appBarTitle,
            style: GoogleFonts.beVietnamPro(
              color: kSettingsTitle,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSave,
              style: TextButton.styleFrom(
                foregroundColor: kSettingsAccent,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lưu',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
