enum SafeZoneEventType { enter, leave }

/// Mot luot vao/roi vung an toan do BE tu dong ghi nhan
/// (GET /safe-zones/events).
class SafeZoneEventModel {
  const SafeZoneEventModel({
    required this.id,
    required this.memberUid,
    required this.type,
    required this.occurredAt,
    required this.zoneName,
    this.safeZoneId,
    this.zoneLatitude,
    this.zoneLongitude,
    this.zoneRadiusMeters,
    this.latitude,
    this.longitude,
    this.distanceMeters,
    this.address,
    this.stayStartedAt,
    this.stayEndedAt,
    this.stayDuration,
    this.isOngoing = false,
  });

  final int id;
  final int? safeZoneId;
  final String memberUid;
  final SafeZoneEventType type;
  final DateTime occurredAt;
  final String zoneName;
  final double? zoneLatitude;
  final double? zoneLongitude;
  final double? zoneRadiusMeters;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
  final String? address;
  final DateTime? stayStartedAt;
  final DateTime? stayEndedAt;
  final Duration? stayDuration;
  final bool isOngoing;

  bool get isEnter => type == SafeZoneEventType.enter;

  bool get hasEventPoint => latitude != null && longitude != null;

  bool get hasZoneGeometry =>
      zoneLatitude != null && zoneLongitude != null && zoneRadiusMeters != null;

  factory SafeZoneEventModel.fromJson(Map<String, dynamic> json) {
    final staySeconds = _toInt(json['stay_duration_seconds']);
    final rawAddress = json['address']?.toString().trim();
    final rawZoneName = json['zone_name']?.toString().trim();

    return SafeZoneEventModel(
      id: _toInt(json['id']) ?? 0,
      safeZoneId: _toInt(json['safe_zone_id']),
      memberUid: (json['member_uid'] ?? json['uid'] ?? '').toString(),
      type: json['event_type']?.toString() == 'leave'
          ? SafeZoneEventType.leave
          : SafeZoneEventType.enter,
      occurredAt: _toDate(json['occurred_at']) ?? DateTime.now(),
      zoneName: (rawZoneName == null || rawZoneName.isEmpty)
          ? 'Vùng an toàn'
          : rawZoneName,
      zoneLatitude: _toDouble(json['zone_latitude']),
      zoneLongitude: _toDouble(json['zone_longitude']),
      zoneRadiusMeters: _toDouble(json['zone_radius_meters']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      distanceMeters: _toDouble(json['distance_meters']),
      address: (rawAddress == null || rawAddress.isEmpty) ? null : rawAddress,
      stayStartedAt: _toDate(json['stay_started_at']),
      stayEndedAt: _toDate(json['stay_ended_at']),
      stayDuration: staySeconds == null ? null : Duration(seconds: staySeconds),
      isOngoing: json['is_ongoing'] == true,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.toLocal();
  }
}
