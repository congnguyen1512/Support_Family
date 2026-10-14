import 'package:family_guard/features/notification/domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.content,
    required super.processing,
    required super.uid,
    required super.relationshipId,
    super.fallLatitude,
    super.fallLongitude,
    super.senderName,
    super.senderRelation,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _nullableInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      processing: json['processing']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      relationshipId: _nullableInt(json['relationship_id']),
      fallLatitude: _nullableDouble(json['fall_latitude']),
      fallLongitude: _nullableDouble(json['fall_longitude']),
      senderName: json['sender_name']?.toString(),
      senderRelation: json['sender_relation']?.toString(),
      createdAt: _nullableDateTime(json['created_at']),
    );
  }

  static int? _nullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString());
  }

  static DateTime? _nullableDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static double? _nullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }
}
