export interface PhysicalActivityRecord {
  id: number;
  owner_uid: string;
  member_uid: string;
  name: string;
  activity_type: 'walking' | 'running' | 'cycling' | 'yoga' | 'swimming' | 'other';
  duration_min: number;
  activity_time: string;
  repeat_days: number[];
  enabled: boolean;
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

export interface PhysicalMetricsRecord {
  id: number;
  member_uid: string;
  metric_date: string;
  steps: number;
  steps_goal: number;
  calories: number;
  calories_goal: number;
  active_minutes: number;
  minutes_goal: number;
  created_at: string;
  updated_at: string;
}
