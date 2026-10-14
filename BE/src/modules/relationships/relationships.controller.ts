import { Request, Response } from 'express';
import { RelationshipsService } from './relationships.service';
import {
  inviteRelationshipSchema,
  updateRelationshipSchema,
} from './relationships.validation';

const relationshipsService = new RelationshipsService();

export class RelationshipsController {
  async invite(req: Request, res: Response) {
    try {
      const parsed = inviteRelationshipSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await relationshipsService.invite(
        req.userId!,
        parsed.data.target_uid,
        parsed.data.relation_type,
        parsed.data.reverse_relation_type,
      );

      return res.status(200).json({
        message: 'Gửi lời mời thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không thể gửi lời mời',
        error,
      });
    }
  }

  async listMine(req: Request, res: Response) {
    try {
      const data = await relationshipsService.listMyRelationships(req.userId!);

      return res.status(200).json({ data });
    } catch (error) {
      return res.status(500).json({
        message: 'Không lấy được danh sách relationship',
        error,
      });
    }
  }

  async update(req: Request, res: Response) {
    try {
      const relationshipId = Number(req.params.id);

      if (Number.isNaN(relationshipId)) {
        return res.status(400).json({
          message: 'relationshipId không hợp lệ',
        });
      }

      const parsed = updateRelationshipSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await relationshipsService.updateRelationship(
        req.userId!,
        relationshipId,
        parsed.data.relation_type,
        parsed.data.reverse_relation_type,
      );

      return res.status(200).json({
        message: 'Sửa quan hệ thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không sửa được relationship',
        error,
      });
    }
  }

  async delete(req: Request, res: Response) {
    try {
      const relationshipId = Number(req.params.id);

      if (Number.isNaN(relationshipId)) {
        return res.status(400).json({
          message: 'relationshipId không hợp lệ',
        });
      }

      const data = await relationshipsService.deleteRelationship(
        req.userId!,
        relationshipId,
      );

      return res.status(200).json({
        message: 'Xóa thành viên thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error.message || 'Không xóa được relationship',
        error,
      });
    }
  }
}