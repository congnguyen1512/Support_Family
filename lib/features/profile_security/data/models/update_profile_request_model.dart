import 'package:family_guard/features/profile_security/domain/entities/update_profile_request.dart';

class UpdateProfileRequestModel extends UpdateProfileRequest {
  const UpdateProfileRequestModel({
    super.name,
    super.email,
    super.phone,
    super.birthday,
    super.sex,
    super.address,
    super.role,
    super.avata,
  });

  factory UpdateProfileRequestModel.fromEntity(UpdateProfileRequest entity) {
    return UpdateProfileRequestModel(
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      birthday: entity.birthday,
      sex: entity.sex,
      address: entity.address,
      role: entity.role,
      avata: entity.avata,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    void write(String key, String? value) {
      if (value != null) {
        json[key] = value;
      }
    }

    write('name', name);
    write('email', email);
    write('phone', phone);
    write('birthday', birthday);
    write('sex', sex);
    write('address', address);
    write('role', role);
    write('avata', avata);

    return json;
  }
}
