import 'package:family_guard/core/di/app_dependencies.dart';
import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_endpoints.dart';
import 'package:family_guard/features/medical/data/models/medical_appointment_model.dart';

abstract class MedicalAppointmentRemoteDataSource {
  Future<List<MedicalAppointmentModel>> getAppointments({String? memberUid, String? status});
  Future<MedicalAppointmentModel> getAppointment(int id);
  Future<MedicalAppointmentModel> createAppointment({
    required String clinic,
    required String doctor,
    required DateTime appointmentDate,
    required String appointmentTime,
    String? memberUid,
    String notes = '',
    String status = 'upcoming',
    bool remindBefore1Day = true,
    bool remindBefore2Hours = true,
  });
  Future<MedicalAppointmentModel> updateAppointment(
    int id, {
    String? clinic,
    String? doctor,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? memberUid,
    String? notes,
    String? status,
    bool? remindBefore1Day,
    bool? remindBefore2Hours,
  });
  Future<void> deleteAppointment(int id);
}

class MedicalAppointmentRemoteDataSourceImpl
    implements MedicalAppointmentRemoteDataSource {
  MedicalAppointmentRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? AppDependencies.instance.apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<MedicalAppointmentModel>> getAppointments({
    String? memberUid,
    String? status,
  }) async {
    final query = <String, String>{};
    if (memberUid != null && memberUid.trim().isNotEmpty) {
      query['member_uid'] = memberUid.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      query['status'] = status.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.medicalAppointments,
      queryParameters: query.isNotEmpty ? query : null,
    );

    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) =>
              MedicalAppointmentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return const <MedicalAppointmentModel>[];
  }

  @override
  Future<MedicalAppointmentModel> getAppointment(int id) async {
    final response = await _apiClient.get(ApiEndpoints.medicalAppointmentById(id));
    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return MedicalAppointmentModel.fromJson(map);
  }

  @override
  Future<MedicalAppointmentModel> createAppointment({
    required String clinic,
    required String doctor,
    required DateTime appointmentDate,
    required String appointmentTime,
    String? memberUid,
    String notes = '',
    String status = 'upcoming',
    bool remindBefore1Day = true,
    bool remindBefore2Hours = true,
  }) async {
    final dateStr =
        '${appointmentDate.year.toString().padLeft(4, '0')}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}';

    final body = <String, dynamic>{
      'clinic': clinic.trim(),
      'doctor': doctor.trim(),
      'appointment_date': dateStr,
      'appointment_time': appointmentTime.trim(),
      'notes': notes.trim(),
      'status': status,
      'remind_before_1_day': remindBefore1Day,
      'remind_before_2_hours': remindBefore2Hours,
    };

    if (memberUid != null && memberUid.trim().isNotEmpty) {
      body['member_uid'] = memberUid.trim();
    }

    final response = await _apiClient.post(
      ApiEndpoints.medicalAppointments,
      body: body,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return MedicalAppointmentModel.fromJson(map);
  }

  @override
  Future<MedicalAppointmentModel> updateAppointment(
    int id, {
    String? clinic,
    String? doctor,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? memberUid,
    String? notes,
    String? status,
    bool? remindBefore1Day,
    bool? remindBefore2Hours,
  }) async {
    final body = <String, dynamic>{};
    if (clinic != null) body['clinic'] = clinic.trim();
    if (doctor != null) body['doctor'] = doctor.trim();
    if (appointmentDate != null) {
      body['appointment_date'] =
          '${appointmentDate.year.toString().padLeft(4, '0')}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}';
    }
    if (appointmentTime != null) body['appointment_time'] = appointmentTime.trim();
    if (memberUid != null) body['member_uid'] = memberUid.trim();
    if (notes != null) body['notes'] = notes.trim();
    if (status != null) body['status'] = status;
    if (remindBefore1Day != null) body['remind_before_1_day'] = remindBefore1Day;
    if (remindBefore2Hours != null) body['remind_before_2_hours'] = remindBefore2Hours;

    final response = await _apiClient.patch(
      ApiEndpoints.medicalAppointmentById(id),
      body: body,
    );

    final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
    return MedicalAppointmentModel.fromJson(map);
  }

  @override
  Future<void> deleteAppointment(int id) async {
    await _apiClient.delete(ApiEndpoints.medicalAppointmentById(id));
  }
}
