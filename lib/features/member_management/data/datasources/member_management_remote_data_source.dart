import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/member_management/data/models/invite_relationship_request_model.dart';
import 'package:family_guard/features/member_management/data/models/relationship_model.dart';
import 'package:family_guard/features/member_management/data/models/search_user_model.dart';
import 'package:family_guard/features/member_management/data/models/update_relationship_request_model.dart';

abstract class MemberManagementRemoteDataSource {
  Future<List<RelationshipModel>> getRelationships();
  Future<List<SearchUserModel>> searchUsers(String keyword);
  Future<RelationshipModel> inviteRelationship(
    InviteRelationshipRequestModel request,
  );
  Future<RelationshipModel> updateRelationship(
    int id,
    UpdateRelationshipRequestModel request,
  );
  Future<RelationshipModel> deleteRelationship(int id);
}

class MemberManagementRemoteDataSourceImpl
    implements MemberManagementRemoteDataSource {
  MemberManagementRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<RelationshipModel> deleteRelationship(int id) async {
    final response = await _apiClient.delete(ApiEndpoints.relationshipById(id));
    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return RelationshipModel.fromJson(json);
  }

  @override
  Future<List<RelationshipModel>> getRelationships() async {
    final response = await _apiClient.get(ApiEndpoints.relationships);
    final items = response is List ? response : const [];
    return items
        .whereType<Map>()
        .map(
          (item) => RelationshipModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<RelationshipModel> inviteRelationship(
    InviteRelationshipRequestModel request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.relationshipsInvite,
      body: request.toJson(),
    );
    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    final relationshipJson = json['relationship'];
    return RelationshipModel.fromJson(
      relationshipJson is Map<String, dynamic>
          ? relationshipJson
          : Map<String, dynamic>.from(relationshipJson as Map),
    );
  }

  @override
  Future<List<SearchUserModel>> searchUsers(String keyword) async {
    final response = await _apiClient.get(
      ApiEndpoints.usersSearch,
      queryParameters: {'q': keyword},
    );
    final items = response is List ? response : const [];
    return items
        .whereType<Map>()
        .map(
          (item) => SearchUserModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<RelationshipModel> updateRelationship(
    int id,
    UpdateRelationshipRequestModel request,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.relationshipById(id),
      body: request.toJson(),
    );
    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return RelationshipModel.fromJson(json);
  }
}
