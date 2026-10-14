export interface KidReminderRecord {
  id: number;
  owner_uid: string;
  member_uid: string;
  title: string;
  reminder_time: string;
  schedule_type: 'daily' | 'weekly' | 'once';
  schedule_date: string | null;
  weekdays: number[] | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
