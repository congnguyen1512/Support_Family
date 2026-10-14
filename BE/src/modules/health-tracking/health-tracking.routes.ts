import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { HealthTrackingController } from './health-tracking.controller';

const router = Router();
const controller = new HealthTrackingController();

router.get('/health-tracking/report', authMiddleware, controller.getReport.bind(controller));
router.get('/health-tracking/logs', authMiddleware, controller.listLogs.bind(controller));
router.post('/health-tracking/logs', authMiddleware, controller.createLog.bind(controller));
router.delete('/health-tracking/logs/:id', authMiddleware, controller.deleteLog.bind(controller));

export default router;
