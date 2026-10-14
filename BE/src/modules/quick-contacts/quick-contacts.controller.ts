import { Request, Response } from 'express';
import { QuickContactsService } from './quick-contacts.service';
import { SaveQuickContactSchema } from './quick-contacts.validation';

export class QuickContactsController {
  private service = new QuickContactsService();

  async get(req: Request, res: Response) {
    try {
      const contact = await this.service.get(req.userId!);
      return res.status(200).json({ data: contact });
    } catch (error: any) {
      return res.status(500).json({
        message: 'Lỗi lấy thông tin liên hệ nhanh',
        error: error.message || error,
      });
    }
  }

  async save(req: Request, res: Response) {
    try {
      const parsed = SaveQuickContactSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.issues,
        });
      }

      const contact = await this.service.save(req.userId!, parsed.data);
      return res.status(200).json({
        message: 'Lưu liên hệ nhanh thành công',
        data: contact,
      });
    } catch (error: any) {
      return res.status(500).json({
        message: 'Lỗi lưu liên hệ nhanh',
        error: error.message || error,
      });
    }
  }

  async delete(req: Request, res: Response) {
    try {
      await this.service.delete(req.userId!);
      return res.status(200).json({ message: 'Xóa liên hệ nhanh thành công' });
    } catch (error: any) {
      return res.status(500).json({
        message: 'Lỗi xóa liên hệ nhanh',
        error: error.message || error,
      });
    }
  }
}
