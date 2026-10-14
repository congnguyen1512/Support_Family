import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import authRoutes from './modules/auth/auth.routes';
import usersRoutes from './modules/users/users.routes';
import relationshipsRoutes from './modules/relationships/relationships.routes';
import notificationsRoutes from './modules/notifications/notifications.routes';
import locationsRoutes from './modules/locations/locations.routes';
import safeZonesRoutes from './modules/safe-zones/safe-zones.routes';
import pushTokensRoutes from './modules/push-tokens/push-tokens.routes';
import messagesRoutes from './modules/messages/messages.routes';
import kidRemindersRoutes from './modules/kid-reminders/kid-reminders.routes';
import remindersRoutes from './modules/reminders/reminders.routes';
import medicalAppointmentsRoutes from './modules/medical-appointments/medical-appointments.routes';
import physicalActivitiesRoutes from './modules/physical-activities/physical-activities.routes';
import healthTrackingRoutes from './modules/health-tracking/health-tracking.routes';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json({ limit: '12mb' }));

app.get('/', (_req, res) => {
  res.json({ message: 'FamilyGuard Backend is running' });
});

app.use('/api', authRoutes);
app.use('/api', usersRoutes);
app.use('/api', relationshipsRoutes);
app.use('/api', notificationsRoutes);
app.use('/api', locationsRoutes);
app.use('/api', safeZonesRoutes);
app.use('/api', pushTokensRoutes);
app.use('/api', messagesRoutes);
app.use('/api', kidRemindersRoutes);
app.use('/api', remindersRoutes);
app.use('/api', medicalAppointmentsRoutes);
app.use('/api', physicalActivitiesRoutes);
app.use('/api', healthTrackingRoutes);

export default app;
