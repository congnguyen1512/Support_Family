class UserLocation {
  const UserLocation({
    required this.uid,
    this.name,
    this.role,
    this.userType,
    this.avata,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.speed,
    this.address,
    this.street,
    this.ward,
    this.district,
    this.city,
    this.country,
    this.placeName,
    this.updatedAt,
    this.createdAt,
  });

  final String uid;
  final String? name;
  final String? role;
  final String? userType;
  final String? avata;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? speed;
  final String? address;
  final String? street;
  final String? ward;
  final String? district;
  final String? city;
  final String? country;
  final String? placeName;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  bool get hasLocation => latitude != null && longitude != null;

  String? get formattedAddress {
    final direct = _normalize(address);
    if (direct != null) {
      return direct;
    }

    final built = <String>[];
    for (final part in [street, ward, placeName, district, city, country]) {
      final value = _normalize(part);
      if (value != null && !built.contains(value)) {
        built.add(value);
      }
    }
    if (built.isEmpty) {
      return null;
    }
    return built.join(', ');
  }

  String? get coordinateLabel {
    if (!hasLocation) {
      return null;
    }
    return '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
  }

  String get addressOrCoordinates => formattedAddress ?? coordinateLabel ?? 'Chua co vi tri';

  UserLocation copyWith({
    String? uid,
    String? name,
    String? role,
    String? userType,
    String? avata,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    String? address,
    String? street,
    String? ward,
    String? district,
    String? city,
    String? country,
    String? placeName,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return UserLocation(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      avata: avata ?? this.avata,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      address: address ?? this.address,
      street: street ?? this.street,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      country: country ?? this.country,
      placeName: placeName ?? this.placeName,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String? _normalize(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
