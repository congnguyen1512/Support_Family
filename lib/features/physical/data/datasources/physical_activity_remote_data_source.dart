import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/physical/data/models/physical_activity_model.dart';
import 'package:family_guard/features/physical/data/models/physical_metrics_model.dart';

abstract class PhysicalActivityRemoteDataSource {
  Future<List<PhysicalActivityModel>> getActivities({String? memberUid});
  Future<PhysicalActivityModel> getActivity(int id);
  Future<PhysicalActivityModel> createActivity({
    required String name,
    required String activityTime,
    String? memberUid,
    String activityType = 'walking',
    int durationMin = 30,
    List<int> repeatDays = const [1, 2, 3, 4, 5],
    bool enabled = true,
  });
  Future<PhysicalActivityModel> updateActivity(
    int id, {
    String? name,
    String? activityType,
    int? durationMin,
    String? activityTime,
    List<int>? repeatDays,
    bool? enabled,
    String? memberUid,
  });
  Future<void> toggleActivity(int id, bool enabled);
  Future<void> deleteActivity(int id);

  Future<PhysicalMetricsModel> getMetrics({String? memberUid, String? date});
  Future<PhysicalMetricsModel> updateMetrics({
    String? memberUid,
    String? date,
    int? steps,
    int? stepsGoal,
    int? calories,
    int? caloriesGoal,
    int? activeMinutes,
    int? minutesGoal,
  });
}

class PhysicalActivityRemoteDataSourceImpl
    implements PhysicalActivityRemoteDataSource {
  PhysicalActivityRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? AppDependencies.instance.apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<PhysicalActivityModel>> getActivities({String? memberUid}) async {
    final query = <String, String>{};
    if (memberUid != null && memberUid.trim().isNotEmpty) {
      query['member_uid'] = memberUid.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.physicalActivities,
      queryParameters: query.isNotEmpty ? query : null,
    );

    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) =>
              PhysicalActivityModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return const <PhysicalActivityModel>[];
  }

  @override
  Future<PhysicalActivityModel> getActivity(int id) async {
    final response = await _apiClient.get(ApiEndpoints.physicalActivityById(id));
    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return PhysicalActivityModel.fromJson(map);
  }

  @override
  Future<PhysicalActivityModel> createActivity({
    required String name,
    required String activityTime,
    String? memberUid,
    String activityType = 'walking',
    int durationMin = 30,
    List<int> repeatDays = const [1, 2, 3, 4, 5],
    bool enabled = true,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'activity_time': activityTime.trim(),
      'activity_type': activityType,
      'duration_min': durationMin,
      'repeat_days': repeatDays,
      'enabled': enabled,
    };

    if (memberUid != null && memberUid.trim().isNotEmpty) {
      body['member_uid'] = memberUid.trim();
    }

    final response = await _apiClient.post(
      ApiEndpoints.physicalActivities,
      body: body,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return PhysicalActivityModel.fromJson(map);
  }

  @override
  Future<PhysicalActivityModel> updateActivity(
    int id, {
    String? name,
    String? activityType,
    int? durationMin,
    String? activityTime,
    List<int>? repeatDays,
    bool? enabled,
    String? memberUid,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (activityType != null) body['activity_type'] = activityType;
    if (durationMin != null) body['duration_min'] = durationMin;
    if (activityTime != null) body['activity_time'] = activityTime.trim();
    if (repeatDays != null) body['repeat_days'] = repeatDays;
    if (enabled != null) body['enabled'] = enabled;
    if (memberUid != null) body['member_uid'] = memberUid.trim();

    final response = await _apiClient.patch(
      ApiEndpoints.physicalActivityById(id),
      body: body,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return PhysicalActivityModel.fromJson(map);
  }

  @override
  Future<void> toggleActivity(int id, bool enabled) async {
    await _apiClient.patch(
      ApiEndpoints.physicalActivityToggle(id),
      body: {'enabled': enabled},
    );
  }

  @override
  Future<void> deleteActivity(int id) async {
    await _apiClient.delete(ApiEndpoints.physicalActivityById(id));
  }

  @override
  Future<PhysicalMetricsModel> getMetrics({String? memberUid, String? date}) async {
    final query = <String, String>{};
    if (memberUid != null && memberUid.trim().isNotEmpty) {
      query['member_uid'] = memberUid.trim();
    }
    if (date != null && date.trim().isNotEmpty) {
      query['date'] = date.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.physicalMetrics,
      queryParameters: query.isNotEmpty ? query : null,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return PhysicalMetricsModel.fromJson(map);
  }

  @override
  Future<PhysicalMetricsModel> updateMetrics({
    String? memberUid,
    String? date,
    int? steps,
    int? stepsGoal,
    int? calories,
    int? caloriesGoal,
    int? activeMinutes,
    int? minutesGoal,
  }) async {
    final body = <String, dynamic>{};
    if (memberUid != null) body['member_uid'] = memberUid.trim();
    if (date != null) body['metric_date'] = date.trim();
    if (steps != null) body['steps'] = steps;
    if (stepsGoal != null) body['steps_goal'] = stepsGoal;
    if (calories != null) body['calories'] = calories;
    if (caloriesGoal != null) body['calories_goal'] = caloriesGoal;
    if (activeMinutes != null) body['active_minutes'] = activeMinutes;
    if (minutesGoal != null) body['minutes_goal'] = minutesGoal;

    final response = await _apiClient.post(
      ApiEndpoints.physicalMetrics,
      body: body,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return PhysicalMetricsModel.fromJson(map);
  }
}
