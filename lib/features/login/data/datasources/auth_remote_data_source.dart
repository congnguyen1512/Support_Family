import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/login/data/models/auth_profile_model.dart';
import 'package:family_guard/features/login/data/models/auth_session_model.dart';
import 'package:family_guard/features/login/data/models/login_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<AuthProfileModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<AuthProfileModel> getMe() async {
    final response = await _apiClient.get(ApiEndpoints.authMe);
    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return AuthProfileModel.fromJson(json);
  }

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      requiresAuth: false,
      body: LoginRequestModel(email: email.trim(), password: password).toJson(),
    );

    final json = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);
    return AuthSessionModel.fromLoginResponse(json);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.authLogout);
  }
}
