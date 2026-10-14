import 'package:family_guard/features/login/data/models/auth_profile_model.dart';
import 'package:family_guard/features/login/data/models/auth_user_model.dart';
import 'package:family_guard/features/login/domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
    required super.user,
    required super.profile,
    required super.homeType,
    super.age,
  });

  factory AuthSessionModel.fromLoginResponse(Map<String, dynamic> json) {
    final userJson = json['user'];
    final profileJson = json['profile'];

    return AuthSessionModel(
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      expiresAt: _nullableInt(json['expires_at']),
      user: AuthUserModel.fromJson(
        userJson is Map<String, dynamic>
            ? userJson
            : (userJson is Map
                  ? Map<String, dynamic>.from(userJson)
                  : const {}),
      ),
      profile: AuthProfileModel.fromJson(
        profileJson is Map<String, dynamic>
            ? profileJson
            : (profileJson is Map
                  ? Map<String, dynamic>.from(profileJson)
                  : const {}),
        fallbackHomeType: json['home_type']?.toString(),
        fallbackAge: _nullableInt(json['age']),
      ),
      homeType: json['home_type']?.toString() ?? 'adult',
      age: _nullableInt(json['age']),
    );
  }

  factory AuthSessionModel.fromStoredJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final profileJson = json['profile'];

    return AuthSessionModel(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      expiresAt: _nullableInt(json['expiresAt']),
      user: AuthUserModel.fromJson(
        userJson is Map<String, dynamic>
            ? userJson
            : (userJson is Map
                  ? Map<String, dynamic>.from(userJson)
                  : const {}),
      ),
      profile: AuthProfileModel.fromJson(
        profileJson is Map<String, dynamic>
            ? profileJson
            : (profileJson is Map
                  ? Map<String, dynamic>.from(profileJson)
                  : const {}),
        fallbackHomeType: json['homeType']?.toString(),
        fallbackAge: _nullableInt(json['age']),
      ),
      homeType: json['homeType']?.toString() ?? 'adult',
      age: _nullableInt(json['age']),
    );
  }

  factory AuthSessionModel.fromEntity(AuthSession entity) {
    return AuthSessionModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      expiresAt: entity.expiresAt,
      user: AuthUserModel.fromEntity(entity.user),
      profile: AuthProfileModel.fromEntity(entity.profile),
      homeType: entity.homeType,
      age: entity.age,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt,
      'user': AuthUserModel.fromEntity(user).toJson(),
      'profile': AuthProfileModel.fromEntity(profile).toJson(),
      'homeType': homeType,
      'age': age,
    };
  }

  static int? _nullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }
}
