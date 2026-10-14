import { z } from 'zod';

export const SaveQuickContactSchema = z.object({
  name: z.string().trim().min(1, 'Tên người liên hệ không được để trống'),
  phone: z.string().trim().min(3, 'Số điện thoại không hợp lệ'),
  avatar_url: z.string().trim().optional().nullable(),
  member_uid: z.string().uuid().optional().nullable(),
});

export type SaveQuickContactInput = z.infer<typeof SaveQuickContactSchema>;
