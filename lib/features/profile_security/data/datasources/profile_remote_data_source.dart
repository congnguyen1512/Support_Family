import 'dart:convert';
import 'dart:typed_data';

import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/profile_security/data/models/profile_model.dart';
import 'package:family_guard/features/profile_security/data/models/update_profile_request_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(UpdateProfileRequestModel request);
  Future<ProfileModel> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<ProfileModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return ProfileModel.fromJson(json);
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequestModel request) async {
    final response = await _apiClient.patch(
      ApiEndpoints.me,
      body: request.toJson(),
    );
    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return ProfileModel.fromJson(json);
  }

  @override
  Future<ProfileModel> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.meAvatar,
      body: {
        'fileName': fileName,
        'mimeType': mimeType,
        'base64Data': base64Encode(bytes),
      },
    );
    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return ProfileModel.fromJson(json);
  }
}
