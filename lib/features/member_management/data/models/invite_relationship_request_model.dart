class InviteRelationshipRequestModel {
  const InviteRelationshipRequestModel({
    required this.targetUid,
    required this.relationType,
    required this.reverseRelationType,
  });

  final String targetUid;
  final String relationType;
  final String reverseRelationType;

  Map<String, dynamic> toJson() {
    return {
      'target_uid': targetUid,
      'relation_type': relationType,
      'reverse_relation_type': reverseRelationType,
    };
  }
}
