import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { LocationsController } from './locations.controller';

const router = Router();
const controller = new LocationsController();

router.post('/locations/me', authMiddleware, controller.updateMe.bind(controller));
router.get('/locations/me', authMiddleware, controller.getMe.bind(controller));
router.get('/locations/family', authMiddleware, controller.getFamily.bind(controller));

export default router;
