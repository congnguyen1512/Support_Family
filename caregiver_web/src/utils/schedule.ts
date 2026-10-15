import type { KidReminder, PhysicalActivity, Reminder } from '../api/types';
import { toISODate, timeToMinutes } from './format';
import { todayWeekday } from './constants';

const normDays = (days?: number[] | null) => (days ?? []).map((d) => (d === 0 ? 7 : d));

/** Nhắc nhở có diễn ra vào ngày `date` không. */
export function occursOn(r: Pick<Reminder | KidReminder, 'schedule_type' | 'schedule_date' | 'weekdays'>, date = new Date()): boolean {
  const wd = todayWeekday(date);
  switch (r.schedule_type) {
    case 'daily':
      return true;
    case 'once':
      return (r.schedule_date ?? '').slice(0, 10) === toISODate(date);
    case 'weekly':
    case 'custom':
    default: {
      const days = normDays(r.weekdays);
      return days.length === 0 ? r.schedule_type !== 'weekly' : days.includes(wd);
    }
  }
}

export function activityOccursOn(a: Pick<PhysicalActivity, 'repeat_days'>, date = new Date()) {
  const days = normDays(a.repeat_days);
  return days.length === 0 || days.includes(todayWeekday(date));
}

export type SlotState = 'done' | 'now' | 'upcoming';

/** Trạng thái theo giờ hiện tại: đã qua / sắp tới trong 30 phút / còn lại. */
export function slotState(time: string, now = new Date()): SlotState {
  const diff = timeToMinutes(time) - (now.getHours() * 60 + now.getMinutes());
  if (diff < -5) return 'done';
  if (diff <= 30) return 'now';
  return 'upcoming';
}

/** Lịch nhắc nhở hôm nay, sắp xếp theo giờ. */
export function todaysReminders<T extends Reminder>(list: T[] | undefined, date = new Date()): T[] {
  return (list ?? [])
    .filter((r) => r.is_active && occursOn(r, date))
    .sort((a, b) => timeToMinutes(a.reminder_time) - timeToMinutes(b.reminder_time));
}
