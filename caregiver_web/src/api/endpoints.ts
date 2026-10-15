import { api, apiRequest } from './client';
import type {
  AppNotification,
  ChatMessage,
  ChatThread,
  FamilyLocation,
  HealthLog,
  HealthLogInput,
  HealthReport,
  KidReminder,
  KidReminderInput,
  LocationPoint,
  LoginResponse,
  MedicalAppointment,
  MedicalAppointmentInput,
  PhysicalActivity,
  PhysicalActivityInput,
  PhysicalMetrics,
  QuickContact,
  Relationship,
  Reminder,
  ReminderInput,
  SafeZone,
  SafeZoneInput,
  SearchUser,
  UserProfile,
} from './types';

/* ── Auth & hồ sơ ─────────────────────────────────────────── */
export const authApi = {
  login: (identifier: string, password: string) =>
    apiRequest<LoginResponse>('/auth/login', {
      method: 'POST',
      body: { email: identifier, password },
      auth: false,
    }),
  logout: () => api.post('/auth/logout'),
  me: () => api.get<UserProfile>('/auth/me'),
};

export const profileApi = {
  get: () => api.get<UserProfile>('/me'),
  update: (payload: Partial<Pick<UserProfile, 'name' | 'email' | 'phone' | 'birthday' | 'sex' | 'address'>>) =>
    api.patch<UserProfile>('/me', payload),
  uploadAvatar: (payload: { fileName: string; mimeType?: string; base64Data: string }) =>
    api.post<UserProfile>('/me/avatar', payload),
  searchUsers: (q: string) => api.get<SearchUser[]>('/users/search', { q }),
};

/* ── Thành viên / quan hệ ─────────────────────────────────── */
export const relationshipApi = {
  list: () => api.get<Relationship[]>('/relationships'),
  invite: (payload: { target_uid: string; relation_type: string; reverse_relation_type: string }) =>
    api.post('/relationships/invite', payload),
  update: (id: number, payload: { relation_type: string; reverse_relation_type?: string }) =>
    api.patch<Relationship>(`/relationships/${id}`, payload),
  remove: (id: number) => api.delete(`/relationships/${id}`),
};

/* ── Thông báo ────────────────────────────────────────────── */
export const notificationApi = {
  list: () => api.get<AppNotification[]>('/notifications'),
  respond: (id: number, action: 'xacnhan' | 'huy') =>
    api.post(`/notifications/${id}/respond`, { action }),
};

/* ── Vị trí ───────────────────────────────────────────────── */
export const locationApi = {
  family: () => api.get<FamilyLocation[]>('/locations/family'),
  history: (memberUid: string, from?: string, to?: string) =>
    api.get<LocationPoint[]>('/locations/history', { member_uid: memberUid, from, to, limit: 3000 }),
};

/* ── Vùng an toàn ─────────────────────────────────────────── */
export const safeZoneApi = {
  list: () => api.get<SafeZone[]>('/safe-zones'),
  create: (payload: SafeZoneInput) => api.post<SafeZone>('/safe-zones', payload),
  update: (id: number, payload: Partial<SafeZoneInput>) => api.put<SafeZone>(`/safe-zones/${id}`, payload),
  remove: (id: number) => api.delete(`/safe-zones/${id}`),
};

/* ── Nhắc nhở ─────────────────────────────────────────────── */
export const reminderApi = {
  list: (memberUid?: string) => api.get<Reminder[]>('/reminders', { member_uid: memberUid }),
  create: (payload: ReminderInput) => api.post<Reminder>('/reminders', payload),
  update: (id: number, payload: Partial<ReminderInput>) => api.patch<Reminder>(`/reminders/${id}`, payload),
  remove: (id: number) => api.delete(`/reminders/${id}`),
  bulkRemove: (ids: number[]) => api.post('/reminders/bulk-delete', { ids }),
};

export const kidReminderApi = {
  list: (memberUid: string) => api.get<KidReminder[]>('/kid-reminders', { member_uid: memberUid }),
  create: (payload: KidReminderInput) => api.post<KidReminder>('/kid-reminders', payload),
  update: (id: number, payload: Partial<KidReminderInput> & { is_active?: boolean }) =>
    api.patch<KidReminder>(`/kid-reminders/${id}`, payload),
  remove: (id: number) => api.delete(`/kid-reminders/${id}`),
};

/* ── Lịch khám ────────────────────────────────────────────── */
export const appointmentApi = {
  list: (memberUid?: string, status?: string) =>
    api.get<MedicalAppointment[]>('/medical-appointments', { member_uid: memberUid, status }),
  create: (payload: MedicalAppointmentInput) => api.post<MedicalAppointment>('/medical-appointments', payload),
  update: (id: number, payload: Partial<MedicalAppointmentInput>) =>
    api.patch<MedicalAppointment>(`/medical-appointments/${id}`, payload),
  remove: (id: number) => api.delete(`/medical-appointments/${id}`),
};

/* ── Vận động ─────────────────────────────────────────────── */
export const activityApi = {
  list: (memberUid?: string) => api.get<PhysicalActivity[]>('/physical-activities', { member_uid: memberUid }),
  create: (payload: PhysicalActivityInput) => api.post<PhysicalActivity>('/physical-activities', payload),
  update: (id: number, payload: Partial<PhysicalActivityInput>) =>
    api.patch<PhysicalActivity>(`/physical-activities/${id}`, payload),
  toggle: (id: number, enabled: boolean) =>
    api.patch<PhysicalActivity>(`/physical-activities/${id}/toggle`, { enabled }),
  remove: (id: number) => api.delete(`/physical-activities/${id}`),
  metrics: (memberUid?: string, date?: string) =>
    api.get<PhysicalMetrics>('/physical-activities/metrics', { member_uid: memberUid, date }),
  saveMetrics: (payload: Partial<PhysicalMetrics> & { member_uid?: string; metric_date?: string }) =>
    api.post<PhysicalMetrics>('/physical-activities/metrics', payload),
};

/* ── Sức khỏe ─────────────────────────────────────────────── */
export const healthApi = {
  report: (memberUid?: string, period: 'today' | 'week' | 'month' = 'week') =>
    api.get<HealthReport>('/health-tracking/report', { member_uid: memberUid, period }),
  logs: (memberUid?: string) => api.get<HealthLog[]>('/health-tracking/logs', { member_uid: memberUid }),
  createLog: (payload: HealthLogInput) => api.post<HealthLog>('/health-tracking/logs', payload),
  removeLog: (id: number) => api.delete(`/health-tracking/logs/${id}`),
};

/* ── Tin nhắn ─────────────────────────────────────────────── */
export const chatApi = {
  threads: () => api.get<ChatThread[]>('/messages/threads'),
  messages: (peerUid: string) => api.get<ChatMessage[]>(`/messages/${peerUid}`),
  send: (peerUid: string, content: string) => api.post<ChatMessage>(`/messages/${peerUid}`, { content }),
  presence: (activePeerUid: string | null) => api.post('/messages/presence', { active_peer_uid: activePeerUid }),
};

/* ── Liên hệ nhanh ────────────────────────────────────────── */
export const quickContactApi = {
  get: () => api.get<QuickContact | null>('/quick-contacts'),
  save: (payload: { name: string; phone: string; avatar_url?: string | null; member_uid?: string | null }) =>
    api.post<QuickContact>('/quick-contacts', payload),
  remove: () => api.delete('/quick-contacts'),
};
