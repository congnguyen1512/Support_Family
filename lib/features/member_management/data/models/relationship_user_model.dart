import 'package:family_guard/features/member_management/domain/entities/relationship_user.dart';

class RelationshipUserModel extends RelationshipUser {
  const RelationshipUserModel({
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

  factory RelationshipUserModel.fromJson(Map<String, dynamic> json) {
    return RelationshipUserModel(
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
