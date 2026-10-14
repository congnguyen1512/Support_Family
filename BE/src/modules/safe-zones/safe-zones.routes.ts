import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { SafeZonesController } from './safe-zones.controller';

const router = Router();
const controller = new SafeZonesController();

router.post('/safe-zones', authMiddleware, controller.create.bind(controller));
router.get('/safe-zones', authMiddleware, controller.list.bind(controller));
router.put('/safe-zones/:id', authMiddleware, controller.update.bind(controller));
router.delete('/safe-zones/:id', authMiddleware, controller.delete.bind(controller));

export default router;
