import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/home/domain/entities/quick_contact.dart';

abstract class QuickContactRemoteDataSource {
  Future<QuickContact?> getQuickContact();
  Future<QuickContact> saveQuickContact(QuickContact contact);
  Future<void> deleteQuickContact();
}

class QuickContactRemoteDataSourceImpl implements QuickContactRemoteDataSource {
  QuickContactRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<QuickContact?> getQuickContact() async {
    final response = await _apiClient.get(ApiEndpoints.quickContacts);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        return QuickContact.fromJson(data);
      }
    }
    return null;
  }

  @override
  Future<QuickContact> saveQuickContact(QuickContact contact) async {
    final response = await _apiClient.post(
      ApiEndpoints.quickContacts,
      body: contact.toJson(),
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        return QuickContact.fromJson(data);
      }
    }
    return contact;
  }

  @override
  Future<void> deleteQuickContact() async {
    await _apiClient.delete(ApiEndpoints.quickContacts);
  }
}
