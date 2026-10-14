import { Router } from 'express';
import { UsersController } from './users.controller';
import { authMiddleware } from '../../middlewares/auth.middleware';

const router = Router();
const controller = new UsersController();

router.get('/me', authMiddleware, controller.getMe.bind(controller));
router.patch('/me', authMiddleware, controller.updateMe.bind(controller));
router.post('/me/avatar', authMiddleware, controller.uploadAvatar.bind(controller));
router.get('/users/search', authMiddleware, controller.searchUsers.bind(controller));

export default router;
