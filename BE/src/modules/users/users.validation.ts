import { z } from 'zod';

export const updateMeSchema = z.object({
  name: z.string().min(1).optional(),
  email: z.string().email().optional(),
  phone: z.string().min(8).max(20).optional(),
  birthday: z.string().optional(),
  sex: z.string().optional(),
  address: z.string().optional(),
  role: z.enum(['nguoichamsoc', 'nguoiduocchamsoc']).optional(),
  avata: z.string().optional(),
});

export const uploadAvatarSchema = z.object({
  fileName: z.string().min(1),
  mimeType: z
    .string()
    .regex(/^image\/[a-zA-Z0-9.+-]+$/)
    .optional(),
  base64Data: z.string().min(1),
});
