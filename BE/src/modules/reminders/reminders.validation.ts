import { z } from 'zod';

const categorySchema = z.enum(['medicine', 'food', 'health', 'other']);
const scheduleTypeSchema = z.enum(['daily', 'weekly', 'once', 'custom']);

export const createReminderSchema = z
  .object({
    member_uid: z.string().uuid().optional(),
    title: z.string().trim().min(1, 'Tiêu đề không được để trống'),
    subtitle: z.string().trim().nullable().optional(),
    category: categorySchema.default('other'),
    reminder_time: z.string().trim().min(1, 'Thời gian nhắc nhở không được để trống'),
    schedule_type: scheduleTypeSchema.default('daily'),
    schedule_date: z.string().trim().min(1).nullable().optional(),
    weekdays: z.array(z.number().int().min(0).max(7)).default([]),
    is_active: z.boolean().default(true),
    voice_url: z.string().trim().nullable().optional(),
  });

export const updateReminderSchema = z.object({
  title: z.string().trim().min(1).optional(),
  subtitle: z.string().trim().nullable().optional(),
  category: categorySchema.optional(),
  reminder_time: z.string().trim().min(1).optional(),
  schedule_type: scheduleTypeSchema.optional(),
  schedule_date: z.string().trim().min(1).nullable().optional(),
  weekdays: z.array(z.number().int().min(0).max(7)).optional(),
  is_active: z.boolean().optional(),
  voice_url: z.string().trim().nullable().optional(),
});

export const bulkDeleteRemindersSchema = z.object({
  ids: z.array(z.number().int().positive()).min(1, 'Danh sách id không được rỗng'),
});

export type CreateReminderInput = z.infer<typeof createReminderSchema>;
export type UpdateReminderInput = z.infer<typeof updateReminderSchema>;
export type BulkDeleteRemindersInput = z.infer<typeof bulkDeleteRemindersSchema>;
