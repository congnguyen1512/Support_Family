import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/repositories/member_management_repository.dart';

class GetRelationshipsUseCase {
  GetRelationshipsUseCase(this._repository);

  final MemberManagementRepository _repository;

  Future<List<Relationship>> call() {
    return _repository.getRelationships();
  }
}
