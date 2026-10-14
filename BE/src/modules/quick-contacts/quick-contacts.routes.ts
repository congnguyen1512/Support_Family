import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { QuickContactsController } from './quick-contacts.controller';

const router = Router();
const controller = new QuickContactsController();

router.get('/quick-contacts', authMiddleware, controller.get.bind(controller));
router.post('/quick-contacts', authMiddleware, controller.save.bind(controller));
router.put('/quick-contacts', authMiddleware, controller.save.bind(controller));
router.delete('/quick-contacts', authMiddleware, controller.delete.bind(controller));

export default router;
