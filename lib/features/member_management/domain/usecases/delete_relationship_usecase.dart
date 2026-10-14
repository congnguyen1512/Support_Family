import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/repositories/member_management_repository.dart';

class DeleteRelationshipUseCase {
  DeleteRelationshipUseCase(this._repository);

  final MemberManagementRepository _repository;

  Future<Relationship> call(int id) {
    return _repository.deleteRelationship(id);
  }
}
