import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/routes/app_route_observer.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:family_guard/core/widgets/app_flow_bottom_nav.dart';
import 'package:family_guard/features/profile_security/domain/entities/profile.dart';
import 'package:family_guard/features/profile_security/presentation/cubit/profile_cubit.dart';
import 'package:family_guard/features/profile_security/presentation/screens/edit_emergency_contact_name_screen.dart';
import 'package:family_guard/features/profile_security/presentation/screens/edit_emergency_contact_phone_screen.dart';
import 'package:family_guard/features/profile_security/presentation/screens/edit_emergency_contact_relationship_screen.dart';
import 'package:family_guard/features/profile_security/presentation/screens/edit_personal_email_screen.dart';
import 'package:family_guard/features/profile_security/presentation/screens/edit_personal_name_screen.dart';
import 'package:family_guard/features/profile_security/presentation/screens/edit_personal_phone_screen.dart';
import 'package:family_guard/features/profile_security/presentation/screens/edit_personal_role_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({
    super.key,
    this.showBackButton = true,
    this.homeRouteName = AppRoutes.home,
    this.trackingRouteName = AppRoutes.tracking,
    this.settingsRouteName = AppRoutes.settings,
    this.thirdTab = AppBottomMenuThirdTab.notifications,
    this.thirdTabRouteName,
  });

  final bool showBackButton;
  final String homeRouteName;
  final String trackingRouteName;
  final String settingsRouteName;
  final AppBottomMenuThirdTab thirdTab;
  final String? thirdTabRouteName;

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen>
    with RouteAware {
  String name = 'Nguyen Thi Loan';
  String email = 'loan@email.com';
  String phone = '0123 456 789';
  String role = 'Người chăm sóc';
  String avatarUrl = '';
  String emergencyName = 'Le Van Huy';
  String emergencyRelation = 'Chong';
  String emergencyPhone = '0123 456 789';
  DateTime? createdAt;
  String? _lastErrorMessage;
  String? _lastSuccessMessage;
  late final ProfileCubit _profileCubit;
  late final ImagePicker _imagePicker;
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _profileCubit = ProfileCubit(
      getProfileUseCase: AppDependencies.instance.getProfileUseCase,
      updateProfileUseCase: AppDependencies.instance.updateProfileUseCase,
      uploadAvatarUseCase: AppDependencies.instance.uploadAvatarUseCase,
    )..addListener(_handleProfileStateChanged);
    _profileCubit.loadProfile();
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
    _profileCubit.removeListener(_handleProfileStateChanged);
    _profileCubit.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _profileCubit.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = _profileCubit.state.isSaving;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBackHeaderBar(
                    title: 'Thong tin ca nhan',
                    onBack: () => Navigator.maybePop(context),
                    showLeading: widget.showBackButton,
                    padding: EdgeInsets.zero,
                    titleFontSize: 20,
                  ),
                  const SizedBox(height: 16),
                  _AvatarEditor(
                    avatarUrl: avatarUrl,
                    isSaving: isSaving,
                    onTap: _changeAvatar,
                  ),
                  const SizedBox(height: 24),
                  _InfoCard(
                    name: name,
                    email: email,
                    phone: phone,
                    role: role,
                    onTapName: _editName,
                    onTapEmail: _editEmail,
                    onTapPhone: _editPhone,
                    onTapRole: _editRole,
                  ),
                  const SizedBox(height: 24),
                  _EmergencyContactSection(
                    name: emergencyName,
                    relationship: emergencyRelation,
                    phone: emergencyPhone,
                    onTapName: () => _editLocalOnly(
                      EditEmergencyContactNameScreen(
                        initialValue: emergencyName,
                      ),
                      (value) => emergencyName = value,
                    ),
                    onTapRelationship: () => _editLocalOnly(
                      EditEmergencyContactRelationshipScreen(
                        initialValue: emergencyRelation,
                      ),
                      (value) => emergencyRelation = value,
                    ),
                    onTapPhone: () => _editLocalOnly(
                      EditEmergencyContactPhoneScreen(
                        initialValue: emergencyPhone,
                      ),
                      (value) => emergencyPhone = value,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _MetaInfo(createdAt: createdAt),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppFlowBottomNav(
                current: AppNavTab.settings,
                homeRouteName: widget.homeRouteName,
                trackingRouteName: widget.trackingRouteName,
                settingsRouteName: widget.settingsRouteName,
                thirdTab: widget.thirdTab,
                thirdTabRouteName: widget.thirdTabRouteName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProfileStateChanged() {
    final state = _profileCubit.state;
    final profile = state.profile;

    if (profile != null && mounted) {
      setState(() {
        name = _readableValue(profile.name, fallback: name);
        email = _readableValue(profile.email, fallback: email);
        phone = _readableValue(profile.phone, fallback: phone);
        role = _roleLabelFromApi(profile.role) ?? role;
        avatarUrl = profile.avata ?? avatarUrl;
        createdAt = profile.createdAt ?? createdAt;
      });
    }

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
  }

  Future<void> _editName() async {
    await _editProfileField(
      screen: EditPersonalNameScreen(initialValue: name),
      currentValue: name,
      onLocalSaved: (value) => name = value,
      onRemoteSaved: _profileCubit.updateName,
    );
  }

  Future<void> _editEmail() async {
    await _editProfileField(
      screen: EditPersonalEmailScreen(initialValue: email),
      currentValue: email,
      onLocalSaved: (value) => email = value,
      onRemoteSaved: _profileCubit.updateEmail,
    );
  }

  Future<void> _editPhone() async {
    await _editProfileField(
      screen: EditPersonalPhoneScreen(initialValue: phone),
      currentValue: phone,
      onLocalSaved: (value) => phone = value,
      onRemoteSaved: _profileCubit.updatePhone,
    );
  }

  Future<void> _editRole() async {
    final result = await _openEditScreen(
      EditPersonalRoleScreen(initialValue: role),
    );
    if (result == null || result.isEmpty || result == role) {
      return;
    }

    final previous = role;
    setState(() {
      role = result;
    });

    final updated = await _profileCubit.updateRole(
      _roleApiValueFromLabel(result),
    );
    if (updated == null && mounted) {
      setState(() {
        role = previous;
      });
    }
  }

  Future<void> _changeAvatar() async {
    if (_profileCubit.state.isSaving) {
      return;
    }

    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (pickedFile == null) {
      return;
    }

    final mimeType = _mimeTypeFromFileName(pickedFile.name);
    if (mimeType == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Chi ho tro anh JPG, PNG, WEBP hoac GIF.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final fileName = pickedFile.name.trim().isEmpty
        ? 'avatar.jpg'
        : pickedFile.name.trim();
    final bytes = await pickedFile.readAsBytes();
    if (!mounted) {
      return;
    }

    await _profileCubit.uploadAvatar(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  Future<void> _editProfileField({
    required Widget screen,
    required String currentValue,
    required ValueChanged<String> onLocalSaved,
    required Future<Profile?> Function(String value) onRemoteSaved,
  }) async {
    final result = await _openEditScreen(screen);
    if (result == null || result.isEmpty || result == currentValue) {
      return;
    }

    final previous = currentValue;
    setState(() {
      onLocalSaved(result);
    });

    final updated = await onRemoteSaved(result);
    if (updated == null && mounted) {
      setState(() {
        onLocalSaved(previous);
      });
    }
  }

  Future<void> _editLocalOnly(
    Widget screen,
    ValueChanged<String> onSaved,
  ) async {
    final result = await _openEditScreen(screen);
    if (result != null && result.isNotEmpty) {
      setState(() => onSaved(result));
    }
  }

  Future<String?> _openEditScreen(Widget screen) {
    return Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => screen));
  }

  String _readableValue(String? value, {required String fallback}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return fallback;
    }
    return trimmed;
  }

  String _roleApiValueFromLabel(String value) {
    switch (value.trim()) {
      case 'Người được chăm sóc':
        return 'nguoiduocchamsoc';
      case 'Người chăm sóc':
      default:
        return 'nguoichamsoc';
    }
  }

  String? _roleLabelFromApi(String? value) {
    switch (value?.trim()) {
      case 'nguoiduocchamsoc':
        return 'Người được chăm sóc';
      case 'nguoichamsoc':
        return 'Người chăm sóc';
      default:
        return null;
    }
  }

  String? _mimeTypeFromFileName(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) {
      return 'image/jpeg';
    }

    switch (parts.last.trim().toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return null;
    }
  }
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({
    required this.avatarUrl,
    required this.onTap,
    required this.isSaving,
  });

  final String avatarUrl;
  final VoidCallback onTap;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl.trim().isNotEmpty;

    return Center(
      child: InkWell(
        onTap: isSaving ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasAvatar)
                          Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: const Color(0xFFE5E7EB)),
                          )
                        else
                          Container(
                            color: const Color(0xFFE5E7EB),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person_rounded,
                              size: 42,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        if (isSaving)
                          Container(
                            color: const Color(0x660F172A),
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
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
                      color: const Color(0xFF0F766E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              isSaving ? 'Dang tai anh...' : 'Thay doi anh',
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFF0F766E),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.onTapName,
    required this.onTapEmail,
    required this.onTapPhone,
    required this.onTapRole,
  });

  final String name;
  final String email;
  final String phone;
  final String role;
  final VoidCallback onTapName;
  final VoidCallback onTapEmail;
  final VoidCallback onTapPhone;
  final VoidCallback onTapRole;

  @override
  Widget build(BuildContext context) {
    return _InfoSurface(
      child: Column(
        children: [
          _DataRow(label: 'Ho va ten', value: name, onTap: onTapName),
          const _RowDivider(),
          _DataRow(
            label: 'Email',
            value: email,
            faded: true,
            onTap: onTapEmail,
          ),
          const _RowDivider(),
          _DataRow(label: 'Dien thoai', value: phone, onTap: onTapPhone),
          const _RowDivider(),
          _RoleRow(value: role, onTap: onTapRole),
        ],
      ),
    );
  }
}

class _EmergencyContactSection extends StatelessWidget {
  const _EmergencyContactSection({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.onTapName,
    required this.onTapRelationship,
    required this.onTapPhone,
  });

  final String name;
  final String relationship;
  final String phone;
  final VoidCallback onTapName;
  final VoidCallback onTapRelationship;
  final VoidCallback onTapPhone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'LIEN HE KHAN CAP',
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF638888),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.325,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _InfoSurface(
          child: Column(
            children: [
              _DataRow(label: 'Ten', value: name, onTap: onTapName),
              const _RowDivider(),
              _DataRow(
                label: 'Quan he',
                value: relationship,
                onTap: onTapRelationship,
              ),
              const _RowDivider(),
              _DataRow(label: 'Dien thoai', value: phone, onTap: onTapPhone),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.createdAt});

  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final createdText = createdAt == null
        ? 'Tai khoan tao ngay 27/10/2025'
        : 'Tai khoan tao ngay ${_formatDate(createdAt!)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            createdText,
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF638888),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          Text(
            'Da lien ket voi 4 thanh vien',
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF638888),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.faded = false,
  });

  final String label;
  final String value;
  final bool faded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
        child: Row(
          children: [
            SizedBox(
              width: 106,
              child: Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF111818),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: GoogleFonts.beVietnamPro(
                  color: faded
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 106,
              child: Text(
                'Vai tro',
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF111818),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                value,
                style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFF4B5563),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
  }
}

class _InfoSurface extends StatelessWidget {
  const _InfoSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
