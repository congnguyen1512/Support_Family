import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { MessagesController } from './messages.controller';

const router = Router();
const controller = new MessagesController();

router.get('/messages/threads', authMiddleware, controller.listThreads.bind(controller));
router.post('/messages/presence', authMiddleware, controller.updatePresence.bind(controller));
router.get('/messages/:peerUid', authMiddleware, controller.listMessages.bind(controller));
router.post('/messages/:peerUid', authMiddleware, controller.sendMessage.bind(controller));

export default router;
