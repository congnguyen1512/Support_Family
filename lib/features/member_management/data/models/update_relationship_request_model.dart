class UpdateRelationshipRequestModel {
  const UpdateRelationshipRequestModel({
    required this.relationType,
    required this.reverseRelationType,
  });

  final String relationType;
  final String reverseRelationType;

  Map<String, dynamic> toJson() {
    return {
      'relation_type': relationType,
      'reverse_relation_type': reverseRelationType,
    };
  }
}
