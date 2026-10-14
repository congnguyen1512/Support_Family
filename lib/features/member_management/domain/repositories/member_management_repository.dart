import 'package:family_guard/features/member_management/domain/entities/relationship.dart';
import 'package:family_guard/features/member_management/domain/entities/search_user.dart';

abstract class MemberManagementRepository {
  Future<List<Relationship>> getRelationships();
  Future<List<SearchUser>> searchUsers(String keyword);
  Future<Relationship> inviteRelationship({
    required String targetUid,
    required String relationType,
    required String reverseRelationType,
  });
  Future<Relationship> updateRelationship({
    required int id,
    required String relationType,
    required String reverseRelationType,
  });
  Future<Relationship> deleteRelationship(int id);
}
