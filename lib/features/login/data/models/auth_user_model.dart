import 'package:family_guard/features/login/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({required super.id, required super.email});

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  factory AuthUserModel.fromEntity(AuthUser entity) {
    return AuthUserModel(id: entity.id, email: entity.email);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}
