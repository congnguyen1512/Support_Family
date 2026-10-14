import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { RelationshipsController } from './relationships.controller';

const router = Router();
const controller = new RelationshipsController();

router.post('/relationships/invite', authMiddleware, controller.invite.bind(controller));
router.get('/relationships', authMiddleware, controller.listMine.bind(controller));
router.patch('/relationships/:id', authMiddleware, controller.update.bind(controller));
router.delete('/relationships/:id', authMiddleware, controller.delete.bind(controller));

export default router;