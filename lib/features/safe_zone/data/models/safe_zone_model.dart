import 'package:family_guard/features/safe_zone/domain/entities/safe_zone.dart';

class SafeZoneModel extends SafeZone {
  SafeZoneModel({
    required super.id,
    super.ownerUid,
    super.targetUid,
    required super.name,
    super.address,
    required super.latitude,
    required super.longitude,
    required super.radius,
    super.zoneType,
    required super.isActive,
    super.timeBasedEnabled,
    super.timeSlots,
    super.alertConfig,
    super.recipientIds,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SafeZoneModel.fromJson(Map<String, dynamic> json) {
    final latitude = _toDouble(json['center_latitude']) ?? _toDouble(json['latitude']) ?? 0;
    final longitude = _toDouble(json['center_longitude']) ?? _toDouble(json['longitude']) ?? 0;
    final radius = _toDouble(json['radius_meters']) ?? _toDouble(json['radius']) ?? 0;
    final name = json['name']?.toString().trim() ?? 'Vung an toan';
    final targetUid = json['target_uid']?.toString();
    final address =
        json['address']?.toString().trim().isNotEmpty == true
        ? json['address'].toString().trim()
        : '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

    return SafeZoneModel(
      id: json['id']?.toString() ?? '',
      ownerUid: json['owner_uid']?.toString(),
      targetUid: targetUid,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      zoneType: _inferZoneType(name),
      isActive: json['is_active'] != false,
      recipientIds: targetUid == null || targetUid.isEmpty ? const [] : [targetUid],
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'target_uid': targetUid,
      'name': name,
      'center_latitude': latitude,
      'center_longitude': longitude,
      'radius_meters': radius.round(),
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'center_latitude': latitude,
      'center_longitude': longitude,
      'radius_meters': radius.round(),
      'is_active': isActive,
    };
  }

  static SafeZoneType _inferZoneType(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('nha')) {
      return SafeZoneType.home;
    }
    if (normalized.contains('truong')) {
      return SafeZoneType.school;
    }
    if (normalized.contains('benh')) {
      return SafeZoneType.hospital;
    }
    return SafeZoneType.custom;
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
