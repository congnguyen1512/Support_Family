import 'package:family_guard/features/profile_security/domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phone,
    super.birthday,
    super.sex,
    super.address,
    super.role,
    super.avata,
    super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: _nullableString(json['phone']),
      birthday: _nullableString(json['birthday']),
      sex: _nullableString(json['sex']),
      address: _nullableString(json['address']),
      role: _nullableString(json['role']),
      avata: _nullableString(json['avata']),
      createdAt: _nullableDateTime(json['created_at']),
    );
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }

  static DateTime? _nullableDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
