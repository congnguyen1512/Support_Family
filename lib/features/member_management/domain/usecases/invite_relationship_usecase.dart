import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/repositories/member_management_repository.dart';

class InviteRelationshipUseCase {
  InviteRelationshipUseCase(this._repository);

  final MemberManagementRepository _repository;

  Future<Relationship> call({
    required String targetUid,
    required String relationType,
    required String reverseRelationType,
  }) {
    return _repository.inviteRelationship(
      targetUid: targetUid,
      relationType: relationType,
      reverseRelationType: reverseRelationType,
    );
  }
}
