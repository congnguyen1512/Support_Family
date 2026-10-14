import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getThreads() async {
    final response = await _apiClient.get(ApiEndpoints.chatThreads);
    return _asMapList(response);
  }

  Future<List<Map<String, dynamic>>> getMessages(String peerUid) async {
    final response = await _apiClient.get(ApiEndpoints.chatByPeer(peerUid));
    return _asMapList(response);
  }

  Future<Map<String, dynamic>> sendMessage(String peerUid, String content) async {
    final response = await _apiClient.post(
      ApiEndpoints.chatByPeer(peerUid),
      body: {'content': content},
    );
    return _asMap(response);
  }

  Future<void> updatePresence(String? activePeerUid) async {
    await _apiClient.post(
      ApiEndpoints.chatPresence,
      body: {'active_peer_uid': activePeerUid},
    );
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    final items = value is List ? value : const [];
    return items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    return value is Map<String, dynamic>
        ? value
        : Map<String, dynamic>.from(value as Map);
  }
}
