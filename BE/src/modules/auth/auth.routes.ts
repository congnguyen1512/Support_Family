import { Router } from 'express';
import { AuthController } from './auth.controller';
import { authMiddleware } from '../../middlewares/auth.middleware';

const router = Router();
const controller = new AuthController();

router.post('/auth/login', controller.login.bind(controller));
router.post('/auth/logout', controller.logout.bind(controller));
router.get('/auth/me', authMiddleware, controller.me.bind(controller));

export default router;