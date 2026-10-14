import { Request, Response } from 'express';
import { RemindersService } from './reminders.service';
import {
  createReminderSchema,
  updateReminderSchema,
  bulkDeleteRemindersSchema,
} from './reminders.validation';

const remindersService = new RemindersService();

export class RemindersController {
  async list(req: Request, res: Response) {
    try {
      const memberUid = req.query.member_uid ? String(req.query.member_uid).trim() : undefined;
      const data = await remindersService.list(req.userId!, memberUid);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy danh sách lịch nhắc',
        error,
      });
    }
  }

  async getById(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'id không hợp lệ' });
      }

      const data = await remindersService.getById(req.userId!, id);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy thông tin lịch nhắc',
        error,
      });
    }
  }

  async create(req: Request, res: Response) {
    try {
      const parsed = createReminderSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await remindersService.create(req.userId!, parsed.data);
      return res.status(201).json({
        message: 'Tạo lịch nhắc thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể tạo lịch nhắc',
        error,
      });
    }
  }

  async update(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'id không hợp lệ' });
      }

      const parsed = updateReminderSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await remindersService.update(req.userId!, id, parsed.data);
      return res.status(200).json({
        message: 'Cập nhật lịch nhắc thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể cập nhật lịch nhắc',
        error,
      });
    }
  }

  async delete(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'id không hợp lệ' });
      }

      const data = await remindersService.delete(req.userId!, id);
      return res.status(200).json({
        message: 'Xóa lịch nhắc thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể xóa lịch nhắc',
        error,
      });
    }
  }

  async bulkDelete(req: Request, res: Response) {
    try {
      const parsed = bulkDeleteRemindersSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await remindersService.bulkDelete(req.userId!, parsed.data.ids);
      return res.status(200).json({
        message: 'Xóa danh sách lịch nhắc thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể xóa các lịch nhắc đã chọn',
        error,
      });
    }
  }
}
