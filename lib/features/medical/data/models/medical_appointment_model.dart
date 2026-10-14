class MedicalAppointmentModel {
  final int id;
  final String ownerUid;
  final String memberUid;
  final String clinic;
  final String doctor;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String notes;
  final String status; // 'upcoming' | 'done' | 'cancelled'
  final bool remindBefore1Day;
  final bool remindBefore2Hours;
  final String? memberName;
  final String? memberAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MedicalAppointmentModel({
    required this.id,
    required this.ownerUid,
    required this.memberUid,
    required this.clinic,
    required this.doctor,
    required this.appointmentDate,
    required this.appointmentTime,
    this.notes = '',
    this.status = 'upcoming',
    this.remindBefore1Day = true,
    this.remindBefore2Hours = true,
    this.memberName,
    this.memberAvatar,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicalAppointmentModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final rawDate = json['appointment_date']?.toString() ?? '';
      parsedDate = rawDate.isNotEmpty ? DateTime.parse(rawDate) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final memberMap = json['member_user'] is Map
        ? Map<String, dynamic>.from(json['member_user'] as Map)
        : null;

    return MedicalAppointmentModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      ownerUid: json['owner_uid']?.toString() ?? '',
      memberUid: json['member_uid']?.toString() ?? '',
      clinic: json['clinic']?.toString() ?? '',
      doctor: json['doctor']?.toString() ?? '',
      appointmentDate: parsedDate,
      appointmentTime: json['appointment_time']?.toString() ?? '09:00',
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? 'upcoming',
      remindBefore1Day: json['remind_before_1_day'] as bool? ?? true,
      remindBefore2Hours: json['remind_before_2_hours'] as bool? ?? true,
      memberName: memberMap?['name']?.toString(),
      memberAvatar: memberMap?['avata']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse('${json['updated_at']}') : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_uid': ownerUid,
      'member_uid': memberUid,
      'clinic': clinic,
      'doctor': doctor,
      'appointment_date': '${appointmentDate.year.toString().padLeft(4, '0')}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}',
      'appointment_time': appointmentTime,
      'notes': notes,
      'status': status,
      'remind_before_1_day': remindBefore1Day,
      'remind_before_2_hours': remindBefore2Hours,
    };
  }
}
