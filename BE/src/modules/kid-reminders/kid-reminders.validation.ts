import { z } from 'zod';

const scheduleTypeSchema = z.enum(['daily', 'weekly', 'once']);

export const createKidReminderSchema = z
  .object({
    member_uid: z.string().uuid(),
    title: z.string().trim().min(1),
    reminder_time: z.string().trim().min(1),
    schedule_type: scheduleTypeSchema.default('daily'),
    schedule_date: z.string().trim().min(1).nullable().optional(),
    weekdays: z.array(z.number().int().min(1).max(7)).default([]),
  })
  .refine(
    (value) =>
      value.schedule_type !== 'weekly' || (value.weekdays?.length ?? 0) > 0,
    { path: ['weekdays'], message: 'Vui lòng chọn ít nhất một thứ' },
  )
  .refine(
    (value) => value.schedule_type !== 'once' || !!value.schedule_date,
    { path: ['schedule_date'], message: 'Vui lòng chọn ngày nhắc' },
  );

export const updateKidReminderSchema = z.object({
  title: z.string().trim().min(1).optional(),
  reminder_time: z.string().trim().min(1).optional(),
  is_active: z.boolean().optional(),
  schedule_type: scheduleTypeSchema.optional(),
  schedule_date: z.string().trim().min(1).nullable().optional(),
  weekdays: z.array(z.number().int().min(1).max(7)).optional(),
});

export type CreateKidReminderInput = z.infer<typeof createKidReminderSchema>;
export type UpdateKidReminderInput = z.infer<typeof updateKidReminderSchema>;
