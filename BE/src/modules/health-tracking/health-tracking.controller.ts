import { Request, Response } from 'express';
import { HealthTrackingService } from './health-tracking.service';
import {
  createHealthLogSchema,
} from './health-tracking.validation';

const healthService = new HealthTrackingService();

export class HealthTrackingController {
  async getReport(req: Request, res: Response) {
    try {
      const rawMemberUid = req.query.member_uid ?? req.query.memberUid;
      const memberUid = rawMemberUid ? String(rawMemberUid).trim() : undefined;
      const periodParam = req.query.period ? String(req.query.period).trim().toLowerCase() : 'month';
      const period = ['today', 'week', 'month'].includes(periodParam)
        ? (periodParam as 'today' | 'week' | 'month')
        : 'month';

      const data = await healthService.getReport(req.userId!, memberUid, period);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy báo cáo sức khỏe',
        error,
      });
    }
  }

  async listLogs(req: Request, res: Response) {
    try {
      const rawMemberUid = req.query.member_uid ?? req.query.memberUid;
      const memberUid = rawMemberUid ? String(rawMemberUid).trim() : undefined;
      const data = await healthService.listLogs(req.userId!, memberUid);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy lịch sử hoạt động',
        error,
      });
    }
  }

  async createLog(req: Request, res: Response) {
    try {
      const parsed = createHealthLogSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await healthService.createLog(req.userId!, parsed.data);
      return res.status(201).json({
        message: 'Ghi nhận hoạt động thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể ghi nhận hoạt động',
        error,
      });
    }
  }

  async deleteLog(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'id không hợp lệ' });
      }

      await healthService.deleteLog(req.userId!, id);
      return res.status(200).json({
        message: 'Xóa bản ghi thành công',
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể xóa bản ghi',
        error,
      });
    }
  }
}
