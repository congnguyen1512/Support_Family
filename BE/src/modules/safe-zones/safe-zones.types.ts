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

export type SafeZoneEventType = 'enter' | 'leave';

export const listSafeZoneEventsSchema = z
  .object({
    member_uid: z.string().uuid('member_uid khong hop le'),
    from: z.string().datetime({ offset: true }).optional(),
    to: z.string().datetime({ offset: true }).optional(),
    type: z.enum(['enter', 'leave']).optional(),
    limit: z.coerce.number().int().min(1).max(1000).optional(),
  })
  .refine(
    (value) =>
      !value.from || !value.to || new Date(value.from) < new Date(value.to),
    { message: '`from` phai nho hon `to`', path: ['from'] },
  );

export type ListSafeZoneEventsQuery = z.infer<typeof listSafeZoneEventsSchema>;

export interface SafeZoneEventRecord {
  id: number;
  safe_zone_id: number | null;
  uid: string;
  owner_uid: string | null;
  event_type: SafeZoneEventType;
  zone_name: string;
  zone_latitude: number;
  zone_longitude: number;
  zone_radius_meters: number;
  latitude: number;
  longitude: number;
  distance_meters: number | null;
  address: string | null;
  occurred_at: string;
  stay_started_at: string | null;
  stay_ended_at: string | null;
  created_at: string;
}
