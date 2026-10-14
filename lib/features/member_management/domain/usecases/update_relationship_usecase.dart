import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/repositories/member_management_repository.dart';

class UpdateRelationshipUseCase {
  UpdateRelationshipUseCase(this._repository);

  final MemberManagementRepository _repository;

  Future<Relationship> call({
    required int id,
    required String relationType,
    required String reverseRelationType,
  }) {
    return _repository.updateRelationship(
      id: id,
      relationType: relationType,
      reverseRelationType: reverseRelationType,
    );
  }
}
