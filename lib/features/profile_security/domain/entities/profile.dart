class Profile {
  const Profile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.birthday,
    this.sex,
    this.address,
    this.role,
    this.avata,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? birthday;
  final String? sex;
  final String? address;
  final String? role;
  final String? avata;
  final DateTime? createdAt;

  Profile copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? birthday,
    String? sex,
    String? address,
    String? role,
    String? avata,
    DateTime? createdAt,
  }) {
    return Profile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      sex: sex ?? this.sex,
      address: address ?? this.address,
      role: role ?? this.role,
      avata: avata ?? this.avata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
