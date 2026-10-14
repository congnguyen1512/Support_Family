import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().min(1, 'Vui lòng nhập email hoặc số điện thoại'),
  password: z.string().min(6, 'Mật khẩu phải có ít nhất 6 ký tự'),
});

export const registerSchema = z
  .object({
    fullName: z.string().trim().min(1, 'Họ và tên không được để trống'),
    email: z.string().trim().optional().or(z.literal('')),
    phone: z.string().trim().optional().or(z.literal('')),
    password: z.string().min(6, 'Mật khẩu phải có ít nhất 6 ký tự'),
    birthday: z.string().trim().optional().or(z.literal('')),
    gender: z.string().trim().optional().or(z.literal('')),
    address: z.string().trim().optional().or(z.literal('')),
    role: z.enum(['nguoichamsoc', 'nguoiduocchamsoc']).optional(),
  })
  .refine(
    (data) =>
      (data.email && data.email.trim().length > 0) ||
      (data.phone && data.phone.trim().length > 0),
    {
      message: 'Vui lòng cung cấp ít nhất email hoặc số điện thoại',
      path: ['email'],
    },
  );

export type RegisterInput = z.infer<typeof registerSchema>;