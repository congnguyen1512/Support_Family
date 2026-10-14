import { Request, Response } from 'express';
import { PhysicalActivitiesService } from './physical-activities.service';
import {
  createPhysicalActivitySchema,
  updatePhysicalActivitySchema,
  updatePhysicalMetricsSchema,
} from './physical-activities.validation';

const activitiesService = new PhysicalActivitiesService();

export class PhysicalActivitiesController {
  async list(req: Request, res: Response) {
    try {
      const rawMemberUid = req.query.member_uid ?? req.query.memberUid;
      const memberUid = rawMemberUid ? String(rawMemberUid).trim() : undefined;
      const data = await activitiesService.list(req.userId!, memberUid);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy danh sách hoạt động thể chất',
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

      const data = await activitiesService.getById(req.userId!, id);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy thông tin hoạt động',
        error,
      });
    }
  }

  async create(req: Request, res: Response) {
    try {
      const parsed = createPhysicalActivitySchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await activitiesService.create(req.userId!, parsed.data);
      return res.status(201).json({
        message: 'Tạo hoạt động thể chất thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể tạo hoạt động thể chất',
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

      const parsed = updatePhysicalActivitySchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await activitiesService.update(req.userId!, id, parsed.data);
      return res.status(200).json({
        message: 'Cập nhật hoạt động thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể cập nhật hoạt động',
        error,
      });
    }
  }

  async toggle(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'id không hợp lệ' });
      }

      const enabled = Boolean(req.body.enabled);
      const data = await activitiesService.toggle(req.userId!, id, enabled);
      return res.status(200).json({
        message: 'Chuyển trạng thái hoạt động thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể thay đổi trạng thái hoạt động',
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

      await activitiesService.delete(req.userId!, id);
      return res.status(200).json({
        message: 'Xóa hoạt động thành công',
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể xóa hoạt động',
        error,
      });
    }
  }

  // ── Metrics endpoints ─────────────────────────────────────────────
  async getMetrics(req: Request, res: Response) {
    try {
      const rawMemberUid = req.query.member_uid ?? req.query.memberUid;
      const memberUid = rawMemberUid ? String(rawMemberUid).trim() : undefined;
      const date = req.query.date ? String(req.query.date).trim() : undefined;
      const data = await activitiesService.getMetrics(req.userId!, memberUid, date);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể lấy dữ liệu thống kê vận động',
        error,
      });
    }
  }

  async upsertMetrics(req: Request, res: Response) {
    try {
      const parsed = updatePhysicalMetricsSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await activitiesService.upsertMetrics(req.userId!, parsed.data);
      return res.status(200).json({
        message: 'Cập nhật chỉ số vận động thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể cập nhật chỉ số vận động',
        error,
      });
    }
  }
}
