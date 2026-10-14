import { z } from 'zod';

export const createSafeZoneSchema = z.object({
  target_uid: z.string().uuid(),
  name: z.string().trim().min(1, 'name khong duoc de trong'),
  center_latitude: z.number().min(-90).max(90),
  center_longitude: z.number().min(-180).max(180),
  radius_meters: z.number().int().positive(),
  is_active: z.boolean().optional(),
});

export const updateSafeZoneSchema = z.object({
  name: z.string().trim().min(1, 'name khong duoc de trong').optional(),
  center_latitude: z.number().min(-90).max(90).optional(),
  center_longitude: z.number().min(-180).max(180).optional(),
  radius_meters: z.number().int().positive().optional(),
  is_active: z.boolean().optional(),
});

export type CreateSafeZoneInput = z.infer<typeof createSafeZoneSchema>;
export type UpdateSafeZoneInput = z.infer<typeof updateSafeZoneSchema>;

export interface SafeZoneRecord {
  id: number;
  owner_uid: string;
  target_uid: string;
  name: string;
  center_latitude: number;
  center_longitude: number;
  radius_meters: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
