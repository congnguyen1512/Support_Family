import { Request, Response } from 'express';
import { PushTokensService } from './push-tokens.service';

const pushTokensService = new PushTokensService();

export class PushTokensController {
  async registerToken(req: Request, res: Response) {
    try {
      const token = String(req.body?.token ?? '').trim();
      const platform = req.body?.platform
        ? String(req.body.platform).trim()
        : null;
      const deviceId = req.body?.device_id
        ? String(req.body.device_id).trim()
        : null;

      if (!token) {
        return res.status(400).json({ message: 'Thiếu FCM token' });
      }

      const data = await pushTokensService.upsertToken({
        uid: req.userId!,
        token,
        platform,
        deviceId,
      });

      return res.status(200).json({
        message: 'Đăng ký FCM token thành công',
        data,
      });
    } catch (error: any) {
      return res.status(500).json({
        message: error.message || 'Không đăng ký được FCM token',
        error,
      });
    }
  }
}
