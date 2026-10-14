import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/data/models/relationship_user_model.dart';

class RelationshipModel extends Relationship {
  const RelationshipModel({
    required super.id,
    required super.uid,
    required super.relationId,
    required super.relationType,
    super.reverseRelationType,
    required super.processing,
    super.createdAt,
    super.relationUser,
  });

  factory RelationshipModel.fromJson(Map<String, dynamic> json) {
    return RelationshipModel(
      id: _nullableInt(json['id']) ?? 0,
      uid: json['uid']?.toString() ?? '',
      relationId: json['relation_id']?.toString() ?? '',
      relationType: json['relation_type']?.toString() ?? '',
      reverseRelationType: _nullableString(json['reverse_relation_type']),
      processing: json['processing']?.toString() ?? '',
      createdAt: _nullableDateTime(json['created_at']),
      relationUser: _parseRelationUser(json['relation_user']),
    );
  }

  static RelationshipUserModel? _parseRelationUser(Object? value) {
    if (value is Map<String, dynamic>) {
      return RelationshipUserModel.fromJson(value);
    }
    if (value is Map) {
      return RelationshipUserModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }
    return text;
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
}
