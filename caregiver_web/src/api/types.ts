/* Kiểu dữ liệu khớp 1-1 với payload của Backend (BE/src/modules/*) */

export type UserRole = 'nguoichamsoc' | 'nguoiduocchamsoc';
export type HomeType = 'adult' | 'child' | 'elderly';
export type MemberKind = 'child' | 'senior' | 'adult';

export interface UserProfile {
  uid: string;
  name: string;
  email: string | null;
  phone: string | null;
  birthday: string | null;
  sex: string | null;
  address: string | null;
  role: UserRole;
  avata: string | null;
  created_at?: string;
  age?: number | null;
  home_type?: HomeType;
}

export interface AuthSession {
  accessToken: string;
  refreshToken: string;
  expiresAt: number | null;
  userId: string;
  email: string | null;
  profile: UserProfile;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  expires_at: number | null;
  user: { id: string; email: string | null };
  profile: UserProfile;
  age: number | null;
  home_type: HomeType;
}

export type RelationshipStatus = 'chuachapnhan' | 'xacnhan' | 'huy' | 'daxoa';

export interface Relationship {
  id: number;
  uid: string;
  relation_id: string;
  relation_type: string | null;
  reverse_relation_type: string | null;
  processing: RelationshipStatus;
  created_at: string;
  relation_user: UserProfile | null;
}

export interface SearchUser {
  uid: string;
  name: string;
  email: string | null;
  phone: string | null;
  role: UserRole;
  avata: string | null;
}

export interface AppNotification {
  id: number;
  title: string;
  content: string;
  processing: 'dagui' | 'done' | string;
  uid: string;
  relationship_id: number | null;
  fall_latitude: number | null;
  fall_longitude: number | null;
  created_at: string;
  sender_name: string | null;
  sender_relation: string | null;
}

export interface FamilyLocation {
  uid: string;
  name: string;
  role: UserRole | null;
  user_type: string | null;
  avata: string | null;
  phone: string | null;
  email: string | null;
  latitude: number | null;
  longitude: number | null;
  accuracy: number | null;
  speed: number | null;
  address: string | null;
  street: string | null;
  ward: string | null;
  district: string | null;
  city: string | null;
  country: string | null;
  place_name: string | null;
  updated_at: string | null;
}

export interface LocationPoint {
  id: number;
  uid: string;
  latitude: number;
  longitude: number;
  accuracy: number | null;
  speed: number | null;
  address: string | null;
  place_name: string | null;
  created_at: string;
}

export interface SafeZone {
  id: number;
  owner_uid: string;
  target_uid: string;
  name: string;
  center_latitude: number;
  center_longitude: number;
  radius_meters: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface SafeZoneInput {
  target_uid: string;
  name: string;
  center_latitude: number;
  center_longitude: number;
  radius_meters: number;
  is_active?: boolean;
}

export interface MemberUserLite {
  uid: string;
  name: string;
  email: string | null;
  phone: string | null;
  avata: string | null;
  role: UserRole;
}

export type ReminderCategory = 'medicine' | 'food' | 'health' | 'other';
export type ReminderSchedule = 'daily' | 'weekly' | 'once' | 'custom';

export interface Reminder {
  id: number;
  owner_uid: string;
  member_uid: string;
  title: string;
  subtitle: string | null;
  category: ReminderCategory;
  reminder_time: string;
  schedule_type: ReminderSchedule;
  schedule_date: string | null;
  weekdays: number[];
  is_active: boolean;
  voice_url: string | null;
  created_at: string;
  updated_at: string;
  member_user?: MemberUserLite;
}

export interface ReminderInput {
  member_uid?: string;
  title: string;
  subtitle?: string | null;
  category: ReminderCategory;
  reminder_time: string;
  schedule_type: ReminderSchedule;
  schedule_date?: string | null;
  weekdays?: number[];
  is_active?: boolean;
}

export interface KidReminder {
  id: number;
  owner_uid: string;
  member_uid: string;
  title: string;
  reminder_time: string;
  schedule_type: 'daily' | 'weekly' | 'once';
  schedule_date: string | null;
  weekdays: number[];
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface KidReminderInput {
  member_uid: string;
  title: string;
  reminder_time: string;
  schedule_type: 'daily' | 'weekly' | 'once';
  schedule_date?: string | null;
  weekdays?: number[];
}

export type AppointmentStatus = 'upcoming' | 'done' | 'cancelled';

export interface MedicalAppointment {
  id: number;
  owner_uid: string;
  member_uid: string;
  clinic: string;
  doctor: string;
  appointment_date: string;
  appointment_time: string;
  notes: string;
  status: AppointmentStatus;
  remind_before_1_day: boolean;
  remind_before_2_hours: boolean;
  created_at?: string;
  updated_at?: string;
  member_user?: MemberUserLite;
}

export interface MedicalAppointmentInput {
  member_uid?: string;
  clinic: string;
  doctor: string;
  appointment_date: string;
  appointment_time: string;
  notes?: string;
  status?: AppointmentStatus;
  remind_before_1_day?: boolean;
  remind_before_2_hours?: boolean;
}

export type ActivityType = 'walking' | 'running' | 'cycling' | 'yoga' | 'swimming' | 'other';

export interface PhysicalActivity {
  id: number;
  owner_uid: string;
  member_uid: string;
  name: string;
  activity_type: ActivityType;
  duration_min: number;
  activity_time: string;
  repeat_days: number[];
  enabled: boolean;
  created_at?: string;
  updated_at?: string;
  member_user?: MemberUserLite;
}

export interface PhysicalActivityInput {
  member_uid?: string;
  name: string;
  activity_type: ActivityType;
  duration_min: number;
  activity_time: string;
  repeat_days: number[];
  enabled?: boolean;
}

export interface PhysicalMetrics {
  id: number;
  member_uid: string;
  metric_date: string;
  steps: number;
  steps_goal: number;
  calories: number;
  calories_goal: number;
  active_minutes: number;
  minutes_goal: number;
}

export type HealthCategory = 'medicine' | 'checkup' | 'activity' | 'vitals' | 'other';
export type HealthStatus = 'completed' | 'late' | 'missed' | 'pending';

export interface HealthLog {
  id: number;
  member_uid: string;
  title: string;
  category: HealthCategory;
  status: HealthStatus;
  detail: string;
  scheduled_at: string;
  completed_at: string | null;
  created_at: string;
  member_user?: MemberUserLite;
}

export interface HealthLogInput {
  member_uid?: string;
  title: string;
  category: HealthCategory;
  status: HealthStatus;
  detail?: string;
  scheduled_at?: string;
  completed_at?: string | null;
}

export interface HealthReport {
  member: { uid: string; name: string };
  period: 'today' | 'week' | 'month';
  total_reminders: number;
  completion_rate: number;
  on_time_rate: number;
  late_rate: number;
  missed_rate: number;
  on_time_change: string;
  late_change: string;
  missed_change: string;
  recent_logs: HealthLog[];
}

export interface ChatThread {
  peer_uid: string;
  relationship_id: number;
  peer_name: string;
  peer_role: string;
  peer_avatar: string;
  relation_type: string | null;
  reverse_relation_type: string | null;
  latest_message: string;
  latest_at: string | null;
  has_unread: boolean;
}

export interface ChatMessage {
  id: number;
  sender_uid: string;
  receiver_uid: string;
  content: string;
  is_read: boolean;
  created_at: string;
  pending?: boolean;
}

export interface QuickContact {
  id: number;
  owner_uid: string;
  name: string;
  phone: string;
  avatar_url: string | null;
  member_uid: string | null;
  created_at: string;
  updated_at: string;
}

/** Thành viên đã gộp: quan hệ + hồ sơ + vị trí hiện tại. */
export interface FamilyMember {
  uid: string;
  relationshipId: number;
  name: string;
  relation: string;
  reverseRelation: string;
  avatar: string | null;
  phone: string | null;
  email: string | null;
  birthday: string | null;
  sex: string | null;
  address: string | null;
  role: UserRole | null;
  age: number | null;
  kind: MemberKind;
  location: FamilyLocation | null;
}
