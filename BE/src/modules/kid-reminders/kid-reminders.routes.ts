import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { KidRemindersController } from './kid-reminders.controller';

const router = Router();
const controller = new KidRemindersController();

router.get('/kid-reminders', authMiddleware, controller.list.bind(controller));
router.post('/kid-reminders', authMiddleware, controller.create.bind(controller));
router.patch('/kid-reminders/:id', authMiddleware, controller.update.bind(controller));
router.delete('/kid-reminders/:id', authMiddleware, controller.delete.bind(controller));

export default router;
