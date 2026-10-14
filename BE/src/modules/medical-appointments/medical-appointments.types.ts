export interface MedicalAppointmentRecord {
  id: number;
  owner_uid: string;
  member_uid: string;
  clinic: string;
  doctor: string;
  appointment_date: string;
  appointment_time: string;
  notes: string;
  status: 'upcoming' | 'done' | 'cancelled';
  remind_before_1_day: boolean;
  remind_before_2_hours: boolean;
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
