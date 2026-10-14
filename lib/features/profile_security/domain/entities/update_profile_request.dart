class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.name,
    this.email,
    this.phone,
    this.birthday,
    this.sex,
    this.address,
    this.role,
    this.avata,
  });

  final String? name;
  final String? email;
  final String? phone;
  final String? birthday;
  final String? sex;
  final String? address;
  final String? role;
  final String? avata;

  bool get hasChanges =>
      name != null ||
      email != null ||
      phone != null ||
      birthday != null ||
      sex != null ||
      address != null ||
      role != null ||
      avata != null;
}
