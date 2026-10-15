import { Request, Response } from 'express';
import { updateMyLocationSchema } from './locations.types';
import { LocationsService } from './locations.service';

const locationsService = new LocationsService();

export class LocationsController {
  async updateMe(req: Request, res: Response) {
    try {
      const parsed = updateMyLocationSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          message: 'Du lieu khong hop le',
          errors: parsed.error.flatten(),
        });
      }

      const data = await locationsService.updateMyLocation(req.userId!, parsed.data);
      return res.status(200).json({ message: 'Cap nhat vi tri thanh cong', data });
    } catch (error: any) {
      return res.status(400).json({
        message: error?.message || 'Khong cap nhat duoc vi tri',
      });
    }
  }

  async getMe(req: Request, res: Response) {
    try {
      const data = await locationsService.getMyLocation(req.userId!);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(500).json({
        message: error?.message || 'Khong lay duoc vi tri hien tai',
      });
    }
  }

  async getFamily(req: Request, res: Response) {
    try {
      const data = await locationsService.getFamilyLocations(req.userId!);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(500).json({
        message: error?.message || 'Khong lay duoc vi tri gia dinh',
      });
    }
  }

  async getHistory(req: Request, res: Response) {
    try {
      const memberUid = String(req.query.member_uid ?? req.userId ?? '').trim();
      if (!memberUid) {
        return res.status(400).json({ message: 'Thieu member_uid' });
      }
      const from = req.query.from ? String(req.query.from) : undefined;
      const to = req.query.to ? String(req.query.to) : undefined;
      const limit = req.query.limit ? Number(req.query.limit) : undefined;

      const data = await locationsService.getLocationHistory(
        req.userId!,
        memberUid,
        from,
        to,
        Number.isFinite(limit) ? limit : undefined,
      );
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error?.message || 'Khong lay duoc lich su di chuyen',
      });
    }
  }
}
