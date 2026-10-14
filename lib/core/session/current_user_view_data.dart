import 'package:family_guard/features/login/domain/entities/auth_session.dart';

class CurrentUserViewData {
  const CurrentUserViewData({
    required this.fullName,
    required this.shortName,
    required this.initials,
    required this.avatarUrl,
    required this.age,
  });

  final String fullName;
  final String shortName;
  final String initials;
  final String avatarUrl;
  final int? age;

  String get ageLabel => age == null ? '' : '$age tuổi';

  factory CurrentUserViewData.fromSession(AuthSession? session) {
    final fullName = _resolveFullName(session);
    final shortName = _resolveShortName(fullName);
    return CurrentUserViewData(
      fullName: fullName,
      shortName: shortName,
      initials: _resolveInitials(shortName, fullName),
      avatarUrl: session?.profile.avata?.trim() ?? '',
      age: session?.profile.age ?? session?.age ?? _resolveAge(session),
    );
  }

  static String _resolveFullName(AuthSession? session) {
    final name = session?.profile.name.trim() ?? '';
    if (name.isNotEmpty) {
      return name;
    }

    final email = session?.profile.email.trim() ?? '';
    if (email.isNotEmpty) {
      return email;
    }

    return 'Bạn';
  }

  static String _resolveShortName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return fullName;
    }
    return parts.last;
  }

  static String _resolveInitials(String shortName, String fullName) {
    final source = shortName.trim().isNotEmpty ? shortName : fullName;
    if (source.isEmpty) {
      return 'U';
    }
    return String.fromCharCode(source.runes.first).toUpperCase();
  }

  static int? _resolveAge(AuthSession? session) {
    final birthday = session?.profile.birthday?.trim();
    if (birthday == null || birthday.isEmpty) {
      return null;
    }

    final birthDate = DateTime.tryParse(birthday);
    if (birthDate == null) {
      return null;
    }

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
