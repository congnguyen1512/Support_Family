import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { MedicalAppointmentsController } from './medical-appointments.controller';

const router = Router();
const controller = new MedicalAppointmentsController();

router.get('/medical-appointments', authMiddleware, controller.list.bind(controller));
router.get('/medical-appointments/:id', authMiddleware, controller.getById.bind(controller));
router.post('/medical-appointments', authMiddleware, controller.create.bind(controller));
router.patch('/medical-appointments/:id', authMiddleware, controller.update.bind(controller));
router.delete('/medical-appointments/:id', authMiddleware, controller.delete.bind(controller));

export default router;
