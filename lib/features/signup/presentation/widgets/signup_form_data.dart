class SignupFormData {
  const SignupFormData({
    this.fullName = '',
    this.age = '',
    this.gender = '',
    this.address = '',
    this.email = '',
    this.phone = '',
    this.password = '',
  });

  final String fullName;
  final String age;
  final String gender;
  final String address;
  final String email;
  final String phone;
  final String password;

  SignupFormData copyWith({
    String? fullName,
    String? age,
    String? gender,
    String? address,
    String? email,
    String? phone,
    String? password,
  }) {
    return SignupFormData(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}
