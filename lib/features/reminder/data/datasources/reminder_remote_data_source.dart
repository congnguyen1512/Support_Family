import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/reminder/data/models/reminder_model.dart';

abstract class ReminderRemoteDataSource {
  Future<List<ReminderModel>> getReminders({String? memberUid});
  Future<ReminderModel> getReminder(int id);
  Future<ReminderModel> createReminder({
    required String title,
    required String reminderTime,
    String? memberUid,
    String? subtitle,
    String category = 'other',
    String scheduleType = 'daily',
    String? scheduleDate,
    List<int> weekdays = const [],
    bool isActive = true,
    String? voiceUrl,
  });
  Future<ReminderModel> updateReminder(
    int id, {
    String? title,
    String? subtitle,
    String? category,
    String? reminderTime,
    String? scheduleType,
    String? scheduleDate,
    List<int>? weekdays,
    bool? isActive,
    String? voiceUrl,
  });
  Future<void> toggleReminder(int id, bool isActive);
  Future<void> deleteReminder(int id);
  Future<void> bulkDeleteReminders(List<int> ids);
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  ReminderRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? AppDependencies.instance.apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ReminderModel>> getReminders({String? memberUid}) async {
    final query = <String, String>{};
    if (memberUid != null && memberUid.trim().isNotEmpty) {
      query['member_uid'] = memberUid.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.reminders,
      queryParameters: query.isNotEmpty ? query : null,
    );

    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => ReminderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return const <ReminderModel>[];
  }

  @override
  Future<ReminderModel> getReminder(int id) async {
    final response = await _apiClient.get(ApiEndpoints.reminderById(id));
    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return ReminderModel.fromJson(map);
  }

  @override
  Future<ReminderModel> createReminder({
    required String title,
    required String reminderTime,
    String? memberUid,
    String? subtitle,
    String category = 'other',
    String scheduleType = 'daily',
    String? scheduleDate,
    List<int> weekdays = const [],
    bool isActive = true,
    String? voiceUrl,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'reminder_time': reminderTime.trim(),
      'category': category,
      'schedule_type': scheduleType,
      'is_active': isActive,
    };

    if (memberUid != null && memberUid.trim().isNotEmpty) {
      body['member_uid'] = memberUid.trim();
    }
    if (subtitle != null && subtitle.trim().isNotEmpty) {
      body['subtitle'] = subtitle.trim();
    }
    if (scheduleDate != null && scheduleDate.trim().isNotEmpty) {
      body['schedule_date'] = scheduleDate.trim();
    }
    if (weekdays.isNotEmpty) {
      body['weekdays'] = weekdays;
    }
    if (voiceUrl != null && voiceUrl.trim().isNotEmpty) {
      body['voice_url'] = voiceUrl.trim();
    }

    final response = await _apiClient.post(
      ApiEndpoints.reminders,
      body: body,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return ReminderModel.fromJson(map);
  }

  @override
  Future<ReminderModel> updateReminder(
    int id, {
    String? title,
    String? subtitle,
    String? category,
    String? reminderTime,
    String? scheduleType,
    String? scheduleDate,
    List<int>? weekdays,
    bool? isActive,
    String? voiceUrl,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title.trim();
    if (subtitle != null) body['subtitle'] = subtitle.trim();
    if (category != null) body['category'] = category;
    if (reminderTime != null) body['reminder_time'] = reminderTime.trim();
    if (scheduleType != null) body['schedule_type'] = scheduleType;
    if (scheduleDate != null) body['schedule_date'] = scheduleDate.trim();
    if (weekdays != null) body['weekdays'] = weekdays;
    if (isActive != null) body['is_active'] = isActive;
    if (voiceUrl != null) body['voice_url'] = voiceUrl.trim();

    final response = await _apiClient.patch(
      ApiEndpoints.reminderById(id),
      body: body,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return ReminderModel.fromJson(map);
  }

  @override
  Future<void> toggleReminder(int id, bool isActive) async {
    await _apiClient.patch(
      ApiEndpoints.reminderById(id),
      body: {'is_active': isActive},
    );
  }

  @override
  Future<void> deleteReminder(int id) async {
    await _apiClient.delete(ApiEndpoints.reminderById(id));
  }

  @override
  Future<void> bulkDeleteReminders(List<int> ids) async {
    await _apiClient.post(
      ApiEndpoints.remindersBulkDelete,
      body: {'ids': ids},
    );
  }
}
