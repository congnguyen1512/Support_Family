export interface ReminderRecord {
  id: number;
  owner_uid: string;
  member_uid: string;
  title: string;
  subtitle: string | null;
  category: 'medicine' | 'food' | 'health' | 'other';
  reminder_time: string;
  schedule_type: 'daily' | 'weekly' | 'once' | 'custom';
  schedule_date: string | null;
  weekdays: number[];
  is_active: boolean;
  voice_url: string | null;
  created_at: string;
  updated_at: string;
  member_user?: {
    uid: string;
    name: string;
    email: string;
    phone: string | null;
    avata: string | null;
    role: string;
  };
}
