import 'package:family_guard/features/member_management/domain/entities/search_user.dart';

class SearchUserModel extends SearchUser {
  const SearchUserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phone,
    super.role,
    super.avata,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: _nullableString(json['phone']),
      role: _nullableString(json['role']),
      avata: _nullableString(json['avata']),
    );
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }
}
