import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { PhysicalActivitiesController } from './physical-activities.controller';

const router = Router();
const controller = new PhysicalActivitiesController();

// Metrics
router.get('/physical-activities/metrics', authMiddleware, controller.getMetrics.bind(controller));
router.post('/physical-activities/metrics', authMiddleware, controller.upsertMetrics.bind(controller));

// Activities
router.get('/physical-activities', authMiddleware, controller.list.bind(controller));
router.get('/physical-activities/:id', authMiddleware, controller.getById.bind(controller));
router.post('/physical-activities', authMiddleware, controller.create.bind(controller));
router.patch('/physical-activities/:id', authMiddleware, controller.update.bind(controller));
router.patch('/physical-activities/:id/toggle', authMiddleware, controller.toggle.bind(controller));
router.delete('/physical-activities/:id', authMiddleware, controller.delete.bind(controller));

export default router;
