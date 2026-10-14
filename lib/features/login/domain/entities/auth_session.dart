import 'package:family_guard/core/constants/app_routes.dart';
import 'package:family_guard/features/login/domain/entities/auth_profile.dart';
import 'package:family_guard/features/login/domain/entities/auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
    required this.profile,
    required this.homeType,
    this.age,
  });

  final String accessToken;
  final String refreshToken;
  final int? expiresAt;
  final AuthUser user;
  final AuthProfile profile;
  final String homeType;
  final int? age;

  String get userId => user.id;
  String get email => user.email;

  String get homeRoute {
    switch (homeType) {
      case 'child':
        return AppRoutes.kidHome;
      case 'elderly':
        return AppRoutes.seniorHome;
      case 'adult':
      default:
        return AppRoutes.home;
    }
  }

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresAt,
    AuthUser? user,
    AuthProfile? profile,
    String? homeType,
    int? age,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      homeType: homeType ?? this.homeType,
      age: age ?? this.age,
    );
  }
}
