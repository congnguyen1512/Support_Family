import { Request, Response } from 'express';
import { KidRemindersService } from './kid-reminders.service';
import {
  createKidReminderSchema,
  updateKidReminderSchema,
} from './kid-reminders.validation';

const kidRemindersService = new KidRemindersService();

export class KidRemindersController {
  async list(req: Request, res: Response) {
    try {
      const memberUid = (req.query.member_uid ?? '').toString().trim();
      if (!memberUid) {
        return res.status(400).json({
          message: 'member_uid không hợp lệ',
        });
      }

      const data = await kidRemindersService.listByMember(req.userId!, memberUid);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy danh sách nhắc nhỏ',
        error,
      });
    }
  }

  async create(req: Request, res: Response) {
    try {
      const parsed = createKidReminderSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await kidRemindersService.create(req.userId!, parsed.data);
      return res.status(200).json({
        message: 'Tạo nhắc nhỏ thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể tạo nhắc nhỏ',
        error,
      });
    }
  }

  async update(req: Request, res: Response) {
    try {
      const reminderId = Number(req.params.id);
      if (Number.isNaN(reminderId)) {
        return res.status(400).json({
          message: 'reminderId không hợp lệ',
        });
      }

      const parsed = updateKidReminderSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await kidRemindersService.update(
        req.userId!,
        reminderId,
        parsed.data,
      );

      return res.status(200).json({
        message: 'Cập nhật nhắc nhỏ thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể cập nhật nhắc nhỏ',
        error,
      });
    }
  }

  async delete(req: Request, res: Response) {
    try {
      const reminderId = Number(req.params.id);
      if (Number.isNaN(reminderId)) {
        return res.status(400).json({
          message: 'reminderId không hợp lệ',
        });
      }

      const data = await kidRemindersService.delete(req.userId!, reminderId);
      return res.status(200).json({
        message: 'Xóa nhắc nhỏ thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể xóa nhắc nhỏ',
        error,
      });
    }
  }
}
