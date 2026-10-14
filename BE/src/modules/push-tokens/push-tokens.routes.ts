import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { PushTokensController } from './push-tokens.controller';

const router = Router();
const controller = new PushTokensController();

router.post('/devices/fcm-token', authMiddleware, controller.registerToken.bind(controller));

export default router;
