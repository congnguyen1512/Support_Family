import { z } from 'zod';

export const updateMyLocationSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  accuracy: z.number().nonnegative().optional(),
  speed: z.number().nullable().optional(),
  address: z.string().nullable().optional(),
  street: z.string().nullable().optional(),
  ward: z.string().nullable().optional(),
  district: z.string().nullable().optional(),
  city: z.string().nullable().optional(),
  country: z.string().nullable().optional(),
  place_name: z.string().nullable().optional(),
  timestamp: z.string().datetime().nullable().optional(),
});

export type UpdateMyLocationInput = z.infer<typeof updateMyLocationSchema>;

export interface UserLocationRecord {
  uid: string;
  latitude: number;
  longitude: number;
  accuracy: number | null;
  speed: number | null;
  address: string | null;
  street: string | null;
  ward: string | null;
  district: string | null;
  city: string | null;
  country: string | null;
  place_name: string | null;
  updated_at: string;
  created_at: string;
  role?: string | null;
  user_type?: string | null;
  name?: string | null;
  email?: string | null;
  phone?: string | null;
  avata?: string | null;
}
