export interface HealthActivityLogRecord {
  id: number;
  member_uid: string;
  title: string;
  category: 'medicine' | 'checkup' | 'activity' | 'vitals' | 'other';
  status: 'completed' | 'late' | 'missed' | 'pending';
  detail: string;
  scheduled_at: string;
  completed_at: string | null;
  created_at: string;
  member_user?: {
    uid: string;
    name: string;
    email: string;
    phone: string | null;
    avata: string | null;
    role: string;
  };
}

export interface HealthReportSummary {
  member: {
    uid: string;
    name: string;
  };
  period: 'today' | 'week' | 'month';
  total_reminders: number;
  completion_rate: number;
  on_time_rate: number;
  late_rate: number;
  missed_rate: number;
  on_time_change: string;
  late_change: string;
  missed_change: string;
  recent_logs: HealthActivityLogRecord[];
}
