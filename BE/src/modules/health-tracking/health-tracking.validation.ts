import { z } from 'zod';

const healthCategorySchema = z.enum([
  'medicine',
  'checkup',
  'activity',
  'vitals',
  'other',
]);

const healthStatusSchema = z.enum([
  'completed',
  'late',
  'missed',
  'pending',
]);

export const createHealthLogSchema = z.object({
  member_uid: z.string().uuid().optional(),
  title: z.string().trim().min(1, 'Tiêu đề không được để trống'),
  category: healthCategorySchema.default('medicine'),
  status: healthStatusSchema.default('completed'),
  detail: z.string().trim().optional().default(''),
  scheduled_at: z.string().trim().optional(),
  completed_at: z.string().trim().nullable().optional(),
});

export const updateHealthLogSchema = z.object({
  title: z.string().trim().min(1).optional(),
  category: healthCategorySchema.optional(),
  status: healthStatusSchema.optional(),
  detail: z.string().trim().optional(),
  scheduled_at: z.string().trim().optional(),
  completed_at: z.string().trim().nullable().optional(),
});

export type CreateHealthLogInput = z.infer<typeof createHealthLogSchema>;
export type UpdateHealthLogInput = z.infer<typeof updateHealthLogSchema>;
