class RegisterRequestModel {
  const RegisterRequestModel({
    required this.fullName,
    this.email,
    this.phone,
    required this.password,
    this.birthday,
    this.gender,
    this.address,
    this.role,
  });

  final String fullName;
  final String? email;
  final String? phone;
  final String password;
  final String? birthday;
  final String? gender;
  final String? address;
  final String? role;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      'password': password,
      if (birthday != null && birthday!.isNotEmpty) 'birthday': birthday,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (role != null && role!.isNotEmpty) 'role': role,
    };
  }
}
