import { Request, Response } from 'express';
import { UsersService } from './users.service';
import { updateMeSchema, uploadAvatarSchema } from './users.validation';

const usersService = new UsersService();

function resolveStatusCode(error: unknown): number {
  if (
    typeof error === 'object' &&
    error !== null &&
    'statusCode' in error &&
    typeof (error as { statusCode?: unknown }).statusCode === 'number'
  ) {
    return (error as { statusCode: number }).statusCode;
  }

  return 500;
}

function resolveErrorMessage(error: unknown, fallback: string): string {
  if (error instanceof Error && error.message.trim().length > 0) {
    return error.message.trim();
  }

  return fallback;
}

export class UsersController {
  async getMe(req: Request, res: Response) {
    try {
      const data = await usersService.getMe(req.userId!);
      return res.json({ data });
    } catch (error) {
      return res.status(500).json({ message: 'Không lấy được thông tin user', error });
    }
  }

  async updateMe(req: Request, res: Response) {
    try {
      const parsed = updateMeSchema.safeParse(req.body);
      if (!parsed.success) {
        return res
          .status(400)
          .json({ message: 'Dữ liệu không hợp lệ', errors: parsed.error.flatten() });
      }

      const data = await usersService.updateMe(req.userId!, parsed.data);
      return res.json({ message: 'Cập nhật thành công', data });
    } catch (error) {
      return res.status(resolveStatusCode(error)).json({
        message: resolveErrorMessage(error, 'Không cập nhật được user'),
        error,
      });
    }
  }

  async uploadAvatar(req: Request, res: Response) {
    try {
      const parsed = uploadAvatarSchema.safeParse(req.body);
      if (!parsed.success) {
        return res
          .status(400)
          .json({ message: 'Dữ liệu upload không hợp lệ', errors: parsed.error.flatten() });
      }

      const data = await usersService.uploadAvatar(req.userId!, parsed.data);
      return res.json({ message: 'Cập nhật ảnh đại diện thành công', data });
    } catch (error) {
      return res.status(resolveStatusCode(error)).json({
        message: resolveErrorMessage(error, 'Không tải lên được ảnh đại diện'),
        error,
      });
    }
  }

  async searchUsers(req: Request, res: Response) {
    try {
      const q = String(req.query.q ?? '').trim();
      if (!q) {
        return res.status(400).json({ message: 'Thiếu từ khóa tìm kiếm' });
      }

      const data = await usersService.searchUsers(req.userId!, q);
      return res.json({ data });
    } catch (error) {
      return res.status(500).json({ message: 'Không tìm được user', error });
    }
  }
}
