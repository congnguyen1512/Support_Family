import { Router } from 'express';
import { AuthController } from './auth.controller';
import { authMiddleware } from '../../middlewares/auth.middleware';

const router = Router();
const controller = new AuthController();

router.post('/auth/register', controller.register.bind(controller));
router.post('/auth/login', controller.login.bind(controller));
router.post('/auth/logout', controller.logout.bind(controller));
router.get('/auth/me', authMiddleware, controller.me.bind(controller));
router.post(
  '/auth/change-password',
  authMiddleware,
  controller.changePassword.bind(controller),
);
router.post(
  '/auth/forgot-password',
  controller.forgotPassword.bind(controller),
);
router.delete(
  '/auth/delete-account',
  authMiddleware,
  controller.deleteAccount.bind(controller),
);

export default router;