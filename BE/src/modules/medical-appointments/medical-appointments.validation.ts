import { z } from 'zod';

const appointmentStatusSchema = z.enum(['upcoming', 'done', 'cancelled']);

export const createMedicalAppointmentSchema = z.object({
  member_uid: z.string().uuid().optional(),
  clinic: z.string().trim().min(1, 'Tên nơi khám không được để trống'),
  doctor: z.string().trim().min(1, 'Tên bác sĩ không được để trống'),
  appointment_date: z.string().trim().min(1, 'Ngày khám không được để trống'),
  appointment_time: z.string().trim().min(1, 'Giờ khám không được để trống'),
  notes: z.string().trim().optional().default(''),
  status: appointmentStatusSchema.default('upcoming'),
  remind_before_1_day: z.boolean().default(true),
  remind_before_2_hours: z.boolean().default(true),
});

export const updateMedicalAppointmentSchema = z.object({
  member_uid: z.string().uuid().optional(),
  clinic: z.string().trim().min(1).optional(),
  doctor: z.string().trim().min(1).optional(),
  appointment_date: z.string().trim().min(1).optional(),
  appointment_time: z.string().trim().min(1).optional(),
  notes: z.string().trim().optional(),
  status: appointmentStatusSchema.optional(),
  remind_before_1_day: z.boolean().optional(),
  remind_before_2_hours: z.boolean().optional(),
});

export type CreateMedicalAppointmentInput = z.infer<typeof createMedicalAppointmentSchema>;
export type UpdateMedicalAppointmentInput = z.infer<typeof updateMedicalAppointmentSchema>;
