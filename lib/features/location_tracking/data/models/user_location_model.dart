import 'package:family_guard/features/location_tracking/domain/entities/user_location.dart';

class UserLocationModel extends UserLocation {
  const UserLocationModel({
    required super.uid,
    super.name,
    super.role,
    super.userType,
    super.avata,
    super.phone,
    super.email,
    super.latitude,
    super.longitude,
    super.accuracy,
    super.speed,
    super.address,
    super.street,
    super.ward,
    super.district,
    super.city,
    super.country,
    super.placeName,
    super.updatedAt,
    super.createdAt,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString(),
      role: json['role']?.toString(),
      userType: json['user_type']?.toString(),
      avata: json['avata']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      accuracy: _toDouble(json['accuracy']),
      speed: _toDouble(json['speed']),
      address: json['address']?.toString(),
      street: json['street']?.toString(),
      ward: json['ward']?.toString(),
      district: json['district']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      placeName: json['place_name']?.toString(),
      updatedAt: _toDateTime(json['updated_at']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  static double? _toDouble(Object? value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
