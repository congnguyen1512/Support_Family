import 'package:family_guard/features/member_management/domain/entities/relationship_user.dart';

class Relationship {
  const Relationship({
    required this.id,
    required this.uid,
    required this.relationId,
    required this.relationType,
    this.reverseRelationType,
    required this.processing,
    this.createdAt,
    this.relationUser,
  });

  final int id;
  final String uid;
  final String relationId;
  final String relationType;
  final String? reverseRelationType;
  final String processing;
  final DateTime? createdAt;
  final RelationshipUser? relationUser;

  Relationship copyWith({
    int? id,
    String? uid,
    String? relationId,
    String? relationType,
    String? reverseRelationType,
    String? processing,
    DateTime? createdAt,
    RelationshipUser? relationUser,
  }) {
    return Relationship(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      relationId: relationId ?? this.relationId,
      relationType: relationType ?? this.relationType,
      reverseRelationType: reverseRelationType ?? this.reverseRelationType,
      processing: processing ?? this.processing,
      createdAt: createdAt ?? this.createdAt,
      relationUser: relationUser ?? this.relationUser,
    );
  }
}
