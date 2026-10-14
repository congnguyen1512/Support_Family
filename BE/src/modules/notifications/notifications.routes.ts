import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { NotificationsController } from './notifications.controller';

const router = Router();
const controller = new NotificationsController();

router.post('/notifications/fall', authMiddleware, controller.createFall.bind(controller));
router.get('/notifications', authMiddleware, controller.listMine.bind(controller));
router.post('/notifications/:id/respond', authMiddleware, controller.respond.bind(controller));

export default router;