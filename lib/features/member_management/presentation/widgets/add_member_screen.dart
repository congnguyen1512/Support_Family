import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/features/member_management/presentation/cubit/member_management_cubit.dart';
import 'package:family_guard/features/member_management/presentation/models/member_management_demo_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _AddMemberTab { phone, email }

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key, this.args = const AddMemberFlowArgs()});

  final AddMemberFlowArgs args;

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  static const List<String> _relationshipOptions = [
    'Chồng',
    'Vợ',
    'Bố',
    'Mẹ',
    'Con',
    'Ông',
    'Bà',
    'Anh',
    'Chị',
    'Em',
    'Cô',
    'Chú',
    'Bác',
    'Cháu',
    'Người thân khác',
  ];

  final _controller = TextEditingController();
  final _inputFocusNode = FocusNode();
  final Set<String> _addedMemberIds = <String>{};
  late _AddMemberTab _tab;
  late final MemberManagementCubit _cubit;
  String _lastSearchQuery = '';
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    _cubit = MemberManagementCubit(
      getRelationshipsUseCase: AppDependencies.instance.getRelationshipsUseCase,
      searchUsersUseCase: AppDependencies.instance.searchUsersUseCase,
      inviteRelationshipUseCase:
          AppDependencies.instance.inviteRelationshipUseCase,
      updateRelationshipUseCase:
          AppDependencies.instance.updateRelationshipUseCase,
      deleteRelationshipUseCase:
          AppDependencies.instance.deleteRelationshipUseCase,
      realtimeClient: AppDependencies.instance.realtimeClient,
    )..addListener(_handleCubitChanged);
    _tab = widget.args.initialMode == AddMemberEntryMode.email
        ? _AddMemberTab.email
        : _AddMemberTab.phone;
    _controller.text = widget.args.prefilledValue;
    _controller.addListener(_handleQueryChanged);
    _handleQueryChanged();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleQueryChanged);
    _cubit.removeListener(_handleCubitChanged);
    _cubit.dispose();
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.args.isEditing;
  bool get _isPhoneTab => _tab == _AddMemberTab.phone;
  String get _query => _controller.text.trim();

  bool get _isValidQuery {
    if (_query.isEmpty) {
      return false;
    }
    return _isPhoneTab ? _isValidPhone(_query) : _isValidEmail(_query);
  }

  List<MemberManagementMember> get _matchedMembers {
    if (!_isValidQuery) {
      return const [];
    }
    final mode = _isPhoneTab
        ? AddMemberEntryMode.phone
        : AddMemberEntryMode.email;
    return _cubit.state.searchResults
        .map((user) => MemberManagementMember.fromSearchUser(user, mode: mode))
        .toList();
  }

  void _handleQueryChanged() {
    final query = _query;
    if (!_isValidQuery) {
      _lastSearchQuery = '';
      _cubit.clearSearchResults();
    } else if (query != _lastSearchQuery) {
      _lastSearchQuery = query;
      _cubit.searchMembers(query);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleCubitChanged() {
    final errorMessage = _cubit.state.errorMessage;
    if (errorMessage != null &&
        errorMessage.isNotEmpty &&
        errorMessage != _lastErrorMessage &&
        mounted) {
      _lastErrorMessage = errorMessage;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Chỉnh sửa thành viên' : 'Thêm thành viên';
    final hintText = _isPhoneTab ? '0123 456 789' : 'example@family.com';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _TopAppBar(title: title),
              Padding(
                padding: const EdgeInsets.fromLTRB(31, 18, 31, 0),
                child: Column(
                  children: [
                    _SegmentedMode(tab: _tab, onTabChanged: _handleTabChanged),
                    const SizedBox(height: 30),
                    _SearchInput(
                      hintText: hintText,
                      focusNode: _inputFocusNode,
                      controller: _controller,
                      keyboardType: _isPhoneTab
                          ? TextInputType.phone
                          : TextInputType.emailAddress,
                      onSubmit: _handlePrimaryAction,
                    ),
                    const SizedBox(height: 34),
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: _PrimaryActionButton(
                          label: 'Lưu thay đổi',
                          onTap: _handlePrimaryAction,
                        ),
                      )
                    else
                      _SearchResultSection(
                        query: _query,
                        isPhoneTab: _isPhoneTab,
                        isValidQuery: _isValidQuery,
                        isSearching: _cubit.state.isSearching,
                        members: _matchedMembers,
                        addedMemberIds: _addedMemberIds,
                        onAddMember: _handleAddMember,
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

  void _handlePrimaryAction() {
    if (_isEditing) {
      final member = widget.args.member;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              member == null
                  ? 'Đã lưu thay đổi'
                  : 'Đã lưu thay đổi cho ${member.name}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      Navigator.maybePop(context);
      return;
    }

    if (_query.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _tab == _AddMemberTab.phone
                  ? 'Nhập số điện thoại để tìm thành viên'
                  : 'Nhập email để tìm thành viên',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (!_isValidQuery) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _isPhoneTab
                  ? 'Số điện thoại chưa đúng định dạng.'
                  : 'Email chưa đúng định dạng.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (_matchedMembers.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy người dùng phù hợp.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _handleAddMember(MemberManagementMember member) {
    _showRelationshipConfirmDialog(member);
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value.trim());
  }

  bool _isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('84') && digits.length == 11) {
      return true;
    }
    return digits.startsWith('0') && digits.length == 10;
  }

  void _handleTabChanged(_AddMemberTab tab) {
    if (_tab == tab) {
      return;
    }

    final wasFocused = _inputFocusNode.hasFocus;
    if (wasFocused) {
      _inputFocusNode.unfocus();
    }

    setState(() {
      _tab = tab;
    });
    _lastSearchQuery = '';
    _handleQueryChanged();

    if (wasFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _inputFocusNode.requestFocus();
        }
      });
    }
  }

  Future<void> _showRelationshipConfirmDialog(
    MemberManagementMember member,
  ) async {
    final relation = await showDialog<String>(
      context: context,
      barrierColor: const Color(0x990F172A),
      builder: (context) =>
          _RelationshipConfirmDialog(relationshipOptions: _relationshipOptions),
    );

    if (!mounted || relation == null) {
      return;
    }

    final created = await _cubit.inviteMember(
      targetUid: member.id,
      relationType: relation,
    );
    if (!mounted || created == null) {
      return;
    }

    setState(() {
      _addedMemberIds.add(member.id);
    });

    final goToMemberList = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x990F172A),
      builder: (context) => const _InviteSuccessDialog(),
    );

    if (!mounted || goToMemberList != true) {
      return;
    }

    Navigator.of(context).pop(true);
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(24, 0, 14, 0),
      decoration: const BoxDecoration(
        color: Color(0xB3F8FAFC),
        border: Border(bottom: BorderSide(color: Color(0x80E2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x80E2E8F0),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF0D9488),
            ),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF0D9488),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 28 / 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedMode extends StatelessWidget {
  const _SegmentedMode({required this.tab, required this.onTabChanged});

  final _AddMemberTab tab;
  final ValueChanged<_AddMemberTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Số điện thoại',
              isSelected: tab == _AddMemberTab.phone,
              onTap: () => onTabChanged(_AddMemberTab.phone),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SegmentButton(
              label: 'Email',
              isSelected: tab == _AddMemberTab.email,
              onTap: () => onTabChanged(_AddMemberTab.email),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.beVietnamPro(
              color: isSelected
                  ? const Color(0xFF00696C)
                  : const Color(0xFF3C4949),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.hintText,
    required this.focusNode,
    required this.controller,
    required this.keyboardType,
    required this.onSubmit,
  });

  final String hintText;
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E9E9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF9AA7A6)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: ValueKey<TextInputType>(keyboardType),
              focusNode: focusNode,
              controller: controller,
              textInputAction: TextInputAction.search,
              keyboardType: keyboardType,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              onSubmitted: (_) => onSubmit(),
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF3C4949),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                hintText: hintText,
                hintStyle: GoogleFonts.beVietnamPro(
                  color: const Color(0x803C4949),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultSection extends StatelessWidget {
  const _SearchResultSection({
    required this.query,
    required this.isPhoneTab,
    required this.isValidQuery,
    required this.isSearching,
    required this.members,
    required this.addedMemberIds,
    required this.onAddMember,
  });

  final String query;
  final bool isPhoneTab;
  final bool isValidQuery;
  final bool isSearching;
  final List<MemberManagementMember> members;
  final Set<String> addedMemberIds;
  final ValueChanged<MemberManagementMember> onAddMember;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!isValidQuery) {
      return _ResultHintText(
        text: isPhoneTab
            ? 'Nhập đúng định dạng số điện thoại để tìm kiếm.'
            : 'Nhập đúng định dạng email để tìm kiếm.',
      );
    }

    if (isSearching) {
      return const _ResultHintText(text: 'Đang tìm kiếm người dùng...');
    }

    if (members.isEmpty) {
      return const _ResultHintText(text: 'Không tìm thấy người dùng phù hợp.');
    }

    return Column(
      children: members
          .map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SearchResultCard(
                member: member,
                isAdded: addedMemberIds.contains(member.id),
                onAddTap: () => onAddMember(member),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ResultHintText extends StatelessWidget {
  const _ResultHintText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: GoogleFonts.beVietnamPro(
          color: const Color(0xFF64748B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.member,
    required this.isAdded,
    required this.onAddTap,
  });

  final MemberManagementMember member;
  final bool isAdded;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              member.avatarUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56,
                height: 56,
                color: const Color(0xFFE2E8F0),
                alignment: Alignment.center,
                child: const Icon(Icons.person, color: Color(0xFF64748B)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              member.name,
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF171D1D),
                fontSize: 34 / 1.9,
                fontWeight: FontWeight.w700,
                height: 28 / 18,
              ),
            ),
          ),
          _PrimaryActionButton(
            label: isAdded
                ? 'Đã thêm'
                : (member.invitationPending ? 'Đã mời' : 'Thêm'),
            onTap: (isAdded || member.invitationPending) ? null : onAddTap,
            height: 40,
            horizontalPadding: 18,
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onTap,
    this.height = 64,
    this.horizontalPadding = 24,
  });

  final String label;
  final VoidCallback? onTap;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF01ADB2),
          disabledBackgroundColor: const Color(0xFF9AC7C9),
          foregroundColor: Colors.white,
          shadowColor: const Color(0x4D01ADB2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        ),
        child: Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: height >= 56 ? 24 : 24 / 1.45,
            fontWeight: FontWeight.w700,
            height: height >= 56 ? 28 / 24 : 20 / (24 / 1.45),
          ),
        ),
      ),
    );
  }
}

class _RelationshipConfirmDialog extends StatefulWidget {
  const _RelationshipConfirmDialog({required this.relationshipOptions});

  final List<String> relationshipOptions;

  @override
  State<_RelationshipConfirmDialog> createState() =>
      _RelationshipConfirmDialogState();
}

class _RelationshipConfirmDialogState
    extends State<_RelationshipConfirmDialog> {
  String? _selectedRelation;

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

class _InviteSuccessDialog extends StatelessWidget {
  const _InviteSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 342),
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
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
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0x1A19A7A8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: Color(0xFF19A7A8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gửi lời mời thành công',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF0F172A),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 32 / 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn đã gửi lời mời tới thành công.\nLời mời có hiệu lực trong 24h.',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF475569),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 26 / 16,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF19A7A8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: const Color(0x3319A7A8),
                ),
                child: Text(
                  'Xong',
                  style: GoogleFonts.beVietnamPro(
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
