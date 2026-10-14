import 'package:family_guard/features/member_management/data/datasources/member_management_remote_data_source.dart';
import 'package:family_guard/features/member_management/data/models/invite_relationship_request_model.dart';
import 'package:family_guard/features/member_management/data/models/update_relationship_request_model.dart';
import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/entities/search_user.dart';
import 'package:family_guard/features/member_management/domain/repositories/member_management_repository.dart';

class MemberManagementRepositoryImpl implements MemberManagementRepository {
  MemberManagementRepositoryImpl({
    required MemberManagementRemoteDataSource remote,
  }) : _remote = remote;

  final MemberManagementRemoteDataSource _remote;

  @override
  Future<Relationship> deleteRelationship(int id) {
    return _remote.deleteRelationship(id);
  }

  @override
  Future<List<Relationship>> getRelationships() {
    return _remote.getRelationships();
  }

  @override
  Future<Relationship> inviteRelationship({
    required String targetUid,
    required String relationType,
    required String reverseRelationType,
  }) {
    return _remote.inviteRelationship(
      InviteRelationshipRequestModel(
        targetUid: targetUid,
        relationType: relationType,
        reverseRelationType: reverseRelationType,
      ),
    );
  }

  @override
  Future<List<SearchUser>> searchUsers(String keyword) {
    return _remote.searchUsers(keyword);
  }

  @override
  Future<Relationship> updateRelationship({
    required int id,
    required String relationType,
    required String reverseRelationType,
  }) {
    return _remote.updateRelationship(
      id,
      UpdateRelationshipRequestModel(
        relationType: relationType,
        reverseRelationType: reverseRelationType,
      ),
    );
  }
}
