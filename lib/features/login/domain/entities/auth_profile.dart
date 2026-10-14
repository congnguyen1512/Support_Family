class AuthProfile {
  const AuthProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.birthday,
    this.sex,
    this.address,
    this.role,
    this.userType,
    this.avata,
    this.age,
    this.homeType,
  });

  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? birthday;
  final String? sex;
  final String? address;
  final String? role;
  final String? userType;
  final String? avata;
  final int? age;
  final String? homeType;

  AuthProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? birthday,
    String? sex,
    String? address,
    String? role,
    String? userType,
    String? avata,
    int? age,
    String? homeType,
  }) {
    return AuthProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      sex: sex ?? this.sex,
      address: address ?? this.address,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      avata: avata ?? this.avata,
      age: age ?? this.age,
      homeType: homeType ?? this.homeType,
    );
  }
}
