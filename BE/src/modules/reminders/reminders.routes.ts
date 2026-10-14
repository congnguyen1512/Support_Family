import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { RemindersController } from './reminders.controller';

const router = Router();
const controller = new RemindersController();

router.get('/reminders', authMiddleware, controller.list.bind(controller));
router.get('/reminders/:id', authMiddleware, controller.getById.bind(controller));
router.post('/reminders', authMiddleware, controller.create.bind(controller));
router.patch('/reminders/:id', authMiddleware, controller.update.bind(controller));
router.delete('/reminders/:id', authMiddleware, controller.delete.bind(controller));
router.post('/reminders/bulk-delete', authMiddleware, controller.bulkDelete.bind(controller));

export default router;
