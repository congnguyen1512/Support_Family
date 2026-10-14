import { Request, Response } from 'express';
import { MedicalAppointmentsService } from './medical-appointments.service';
import {
  createMedicalAppointmentSchema,
  updateMedicalAppointmentSchema,
} from './medical-appointments.validation';

const appointmentsService = new MedicalAppointmentsService();

export class MedicalAppointmentsController {
  async list(req: Request, res: Response) {
    try {
      const rawMemberUid = req.query.member_uid ?? req.query.memberUid;
      const memberUid = rawMemberUid ? String(rawMemberUid).trim() : undefined;
      const status = req.query.status ? String(req.query.status).trim() : undefined;
      const data = await appointmentsService.list(req.userId!, memberUid, status);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy danh sách lịch hẹn khám',
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

      const data = await appointmentsService.getById(req.userId!, id);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy thông tin lịch hẹn khám',
        error,
      });
    }
  }

  async create(req: Request, res: Response) {
    try {
      const parsed = createMedicalAppointmentSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await appointmentsService.create(req.userId!, parsed.data);
      return res.status(201).json({
        message: 'Tạo lịch hẹn khám thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể tạo lịch hẹn khám',
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

      const parsed = updateMedicalAppointmentSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu cập nhật không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await appointmentsService.update(req.userId!, id, parsed.data);
      return res.status(200).json({
        message: 'Cập nhật lịch hẹn khám thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể cập nhật lịch hẹn khám',
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

      await appointmentsService.delete(req.userId!, id);
      return res.status(200).json({
        message: 'Xóa lịch hẹn khám thành công',
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể xóa lịch hẹn khám',
        error,
      });
    }
  }
}
