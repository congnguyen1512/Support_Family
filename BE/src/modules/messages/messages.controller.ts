import { Request, Response } from 'express';
import { MessagesService } from './messages.service';

const messagesService = new MessagesService();

export class MessagesController {
  async listThreads(req: Request, res: Response) {
    try {
      const data = await messagesService.listThreads(req.userId!);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể tải danh sách đoạn chat',
        error,
      });
    }
  }

  async listMessages(req: Request, res: Response) {
    try {
      const peerUid = String(req.params.peerUid ?? '').trim();
      if (!peerUid) {
        return res.status(400).json({ message: 'Thiếu peerUid' });
      }

      const data = await messagesService.listMessages(req.userId!, peerUid);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể tải nội dung chat',
        error,
      });
    }
  }

  async sendMessage(req: Request, res: Response) {
    try {
      const peerUid = String(req.params.peerUid ?? '').trim();
      const content = String(req.body?.content ?? '');

      if (!peerUid) {
        return res.status(400).json({ message: 'Thiếu peerUid' });
      }

      const data = await messagesService.sendMessage(req.userId!, peerUid, content);
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể gửi tin nhắn',
        error,
      });
    }
  }

  async updatePresence(req: Request, res: Response) {
    try {
      const activePeerUidRaw = req.body?.active_peer_uid;
      const activePeerUid =
        activePeerUidRaw == null ? null : String(activePeerUidRaw).trim();

      const data = await messagesService.updatePresence(
        req.userId!,
        activePeerUid ? activePeerUid : null,
      );
      return res.status(200).json({ data });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể cập nhật trạng thái chat',
        error,
      });
    }
  }
}
