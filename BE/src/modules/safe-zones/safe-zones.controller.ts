import { Request, Response } from 'express';
import { createSafeZoneSchema, updateSafeZoneSchema } from './safe-zones.types';
import { safeZonesService } from './safe-zones.service';

export class SafeZonesController {
  async create(req: Request, res: Response) {
    try {
      const parsed = createSafeZoneSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          message: 'Du lieu khong hop le',
          errors: parsed.error.flatten(),
        });
      }

      const data = await safeZonesService.createSafeZone(req.userId!, parsed.data);
      return res.status(201).json({ message: 'Tao vung an toan thanh cong', data });
    } catch (error: any) {
      return res.status(400).json({
        message: error?.message || 'Khong tao duoc vung an toan',
      });
    }
  }

  async list(req: Request, res: Response) {
    try {
      const data = await safeZonesService.listSafeZones(req.userId!);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(500).json({
        message: error?.message || 'Khong lay duoc danh sach vung an toan',
      });
    }
  }

  async update(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'safeZoneId khong hop le' });
      }

      const parsed = updateSafeZoneSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          message: 'Du lieu khong hop le',
          errors: parsed.error.flatten(),
        });
      }

      if (Object.keys(parsed.data).length === 0) {
        return res.status(400).json({ message: 'Khong co truong nao de cap nhat' });
      }

      const data = await safeZonesService.updateSafeZone(req.userId!, id, parsed.data);
      return res.status(200).json({ message: 'Cap nhat vung an toan thanh cong', data });
    } catch (error: any) {
      return res.status(400).json({
        message: error?.message || 'Khong cap nhat duoc vung an toan',
      });
    }
  }

  async delete(req: Request, res: Response) {
    try {
      const id = Number(req.params.id);
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'safeZoneId khong hop le' });
      }

      const data = await safeZonesService.deleteSafeZone(req.userId!, id);
      return res.status(200).json({ message: 'Xoa vung an toan thanh cong', data });
    } catch (error: any) {
      return res.status(400).json({
        message: error?.message || 'Khong xoa duoc vung an toan',
      });
    }
  }
}
