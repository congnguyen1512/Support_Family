import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/tracking/data/models/health_activity_log_model.dart';
import 'package:family_guard/features/tracking/data/models/health_report_model.dart';

abstract class HealthTrackingRemoteDataSource {
  Future<HealthReportModel> getReport({String? memberUid, String period = 'month'});
  Future<List<HealthActivityLogModel>> getLogs({String? memberUid});
  Future<HealthActivityLogModel> createLog({
    required String title,
    String? memberUid,
    String category = 'medicine',
    String status = 'completed',
    String detail = '',
    DateTime? scheduledAt,
    DateTime? completedAt,
  });
  Future<void> deleteLog(int id);
}

class HealthTrackingRemoteDataSourceImpl
    implements HealthTrackingRemoteDataSource {
  HealthTrackingRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? AppDependencies.instance.apiClient;

  final ApiClient _apiClient;

  @override
  Future<HealthReportModel> getReport({
    String? memberUid,
    String period = 'month',
  }) async {
    final query = <String, String>{
      'period': period,
    };
    if (memberUid != null && memberUid.trim().isNotEmpty) {
      query['member_uid'] = memberUid.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.healthReport,
      queryParameters: query,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return HealthReportModel.fromJson(map);
  }

  @override
  Future<List<HealthActivityLogModel>> getLogs({String? memberUid}) async {
    final query = <String, String>{};
    if (memberUid != null && memberUid.trim().isNotEmpty) {
      query['member_uid'] = memberUid.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.healthLogs,
      queryParameters: query.isNotEmpty ? query : null,
    );

    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) =>
              HealthActivityLogModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return const <HealthActivityLogModel>[];
  }

  @override
  Future<HealthActivityLogModel> createLog({
    required String title,
    String? memberUid,
    String category = 'medicine',
    String status = 'completed',
    String detail = '',
    DateTime? scheduledAt,
    DateTime? completedAt,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'category': category,
      'status': status,
      'detail': detail.trim(),
    };

    if (memberUid != null && memberUid.trim().isNotEmpty) {
      body['member_uid'] = memberUid.trim();
    }
    if (scheduledAt != null) {
      body['scheduled_at'] = scheduledAt.toIso8601String();
    }
    if (completedAt != null) {
      body['completed_at'] = completedAt.toIso8601String();
    }

    final response = await _apiClient.post(
      ApiEndpoints.healthLogs,
      body: body,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return HealthActivityLogModel.fromJson(map);
  }

  @override
  Future<void> deleteLog(int id) async {
    await _apiClient.delete(ApiEndpoints.healthLogById(id));
  }
}
