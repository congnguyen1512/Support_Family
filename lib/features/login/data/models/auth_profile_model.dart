import 'package:family_guard/features/login/domain/entities/auth_profile.dart';

class AuthProfileModel extends AuthProfile {
  const AuthProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phone,
    super.birthday,
    super.sex,
    super.address,
    super.role,
    super.userType,
    super.avata,
    super.age,
    super.homeType,
  });

  factory AuthProfileModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackHomeType,
    int? fallbackAge,
  }) {
    return AuthProfileModel(
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: _nullableString(json['phone']),
      birthday: _nullableString(json['birthday']),
      sex: _nullableString(json['sex']),
      address: _nullableString(json['address']),
      role: _nullableString(json['role']),
      userType:
          _nullableString(json['user_type']) ??
          _nullableString(json['userType']),
      avata: _nullableString(json['avata']),
      age: _nullableInt(json['age']) ?? fallbackAge,
      homeType:
          _nullableString(json['home_type']) ??
          _nullableString(json['homeType']) ??
          fallbackHomeType,
    );
  }

  factory AuthProfileModel.fromEntity(AuthProfile entity) {
    return AuthProfileModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      birthday: entity.birthday,
      sex: entity.sex,
      address: entity.address,
      role: entity.role,
      userType: entity.userType,
      avata: entity.avata,
      age: entity.age,
      homeType: entity.homeType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'birthday': birthday,
      'sex': sex,
      'address': address,
      'role': role,
      'userType': userType,
      'avata': avata,
      'age': age,
      'homeType': homeType,
    };
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }

  static int? _nullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }
}
