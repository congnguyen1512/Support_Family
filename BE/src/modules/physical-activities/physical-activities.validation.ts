import { z } from 'zod';

const activityTypeSchema = z.enum([
  'walking',
  'running',
  'cycling',
  'yoga',
  'swimming',
  'other',
]);

export const createPhysicalActivitySchema = z.object({
  member_uid: z.string().uuid().optional(),
  name: z.string().trim().min(1, 'Tên hoạt động không được để trống'),
  activity_type: activityTypeSchema.default('walking'),
  duration_min: z.number().int().min(1, 'Thời lượng tối thiểu 1 phút').default(30),
  activity_time: z.string().trim().min(1, 'Thời gian tập không được để trống'),
  repeat_days: z.array(z.number().int().min(1).max(7)).default([1, 2, 3, 4, 5]),
  enabled: z.boolean().default(true),
});

export const updatePhysicalActivitySchema = z.object({
  member_uid: z.string().uuid().optional(),
  name: z.string().trim().min(1).optional(),
  activity_type: activityTypeSchema.optional(),
  duration_min: z.number().int().min(1).optional(),
  activity_time: z.string().trim().min(1).optional(),
  repeat_days: z.array(z.number().int().min(1).max(7)).optional(),
  enabled: z.boolean().optional(),
});

export const updatePhysicalMetricsSchema = z.object({
  member_uid: z.string().uuid().optional(),
  metric_date: z.string().trim().optional(), // YYYY-MM-DD
  steps: z.number().int().min(0).optional(),
  steps_goal: z.number().int().min(0).optional(),
  calories: z.number().int().min(0).optional(),
  calories_goal: z.number().int().min(0).optional(),
  active_minutes: z.number().int().min(0).optional(),
  minutes_goal: z.number().int().min(0).optional(),
});

export type CreatePhysicalActivityInput = z.infer<typeof createPhysicalActivitySchema>;
export type UpdatePhysicalActivityInput = z.infer<typeof updatePhysicalActivitySchema>;
export type UpdatePhysicalMetricsInput = z.infer<typeof updatePhysicalMetricsSchema>;
