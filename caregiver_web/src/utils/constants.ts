import type {
  ActivityType,
  AppNotification,
  AppointmentStatus,
  HealthCategory,
  HealthStatus,
  MemberKind,
  ReminderCategory,
  ReminderSchedule,
} from '../api/types';
import type { Palette } from '../theme/tokens';

export const RELATION_OPTIONS = [
  'Chồng', 'Vợ', 'Bố', 'Mẹ', 'Con', 'Ông', 'Bà', 'Anh', 'Chị', 'Em', 'Cô', 'Chú', 'Bác', 'Cháu', 'Người thân khác',
];

/** Suy ra quan hệ ngược (giống RelationDirectionHelper trên mobile). */
export function resolveReverseRelation(relation: string): string {
  const n = relation.trim().toLowerCase();
  switch (n) {
    case 'vợ': case 'vo': return 'Chồng';
    case 'chồng': case 'chong': return 'Vợ';
    case 'bố': case 'bo': case 'cha': case 'ba': case 'mẹ': case 'me': return 'Con';
    case 'con': return 'Bố/Mẹ';
    case 'ông': case 'ong': case 'bà': case 'ba noi': case 'ba ngoai': case 'bà nội': case 'bà ngoại': return 'Cháu';
    case 'cháu': case 'chau': return 'Ông/Bà';
    case 'anh': case 'chị': case 'chi': return 'Em';
    case 'em': return 'Anh/Chị';
    case 'cô': case 'chú': case 'bác': return 'Cháu';
    default: return 'Người thân';
  }
}

export const MEMBER_KIND_META: Record<MemberKind, { label: string; icon: string; color: keyof Palette; soft: keyof Palette }> = {
  child: { label: 'Trẻ em', icon: 'happy-outline', color: 'info', soft: 'infoSoft' },
  senior: { label: 'Người cao tuổi', icon: 'heart-outline', color: 'pink', soft: 'pinkSoft' },
  adult: { label: 'Người lớn', icon: 'person-outline', color: 'accent', soft: 'accentSoft' },
};

export const REMINDER_CATEGORY_META: Record<ReminderCategory, { label: string; icon: string; color: keyof Palette; soft: keyof Palette }> = {
  medicine: { label: 'Uống thuốc', icon: 'medkit-outline', color: 'pink', soft: 'pinkSoft' },
  food: { label: 'Ăn uống', icon: 'restaurant-outline', color: 'warning', soft: 'warningSoft' },
  health: { label: 'Sức khỏe', icon: 'heart-outline', color: 'info', soft: 'infoSoft' },
  other: { label: 'Khác', icon: 'alarm-outline', color: 'primary', soft: 'primarySoft' },
};

export const SCHEDULE_LABEL: Record<ReminderSchedule, string> = {
  daily: 'Mỗi ngày',
  weekly: 'Hàng tuần',
  once: 'Một lần',
  custom: 'Tùy chỉnh',
};

/** Thứ trong tuần: 1 = Thứ 2 ... 7 = Chủ nhật (khớp mobile/BE) */
export const WEEKDAYS = [
  { value: 1, short: 'T2', label: 'Thứ 2' },
  { value: 2, short: 'T3', label: 'Thứ 3' },
  { value: 3, short: 'T4', label: 'Thứ 4' },
  { value: 4, short: 'T5', label: 'Thứ 5' },
  { value: 5, short: 'T6', label: 'Thứ 6' },
  { value: 6, short: 'T7', label: 'Thứ 7' },
  { value: 7, short: 'CN', label: 'Chủ nhật' },
];

export function weekdaysLabel(days?: number[] | null): string {
  if (!days || days.length === 0) return 'Chưa chọn ngày';
  const sorted = [...new Set(days.map((d) => (d === 0 ? 7 : d)))].sort((a, b) => a - b);
  if (sorted.length === 7) return 'Cả tuần';
  if (sorted.join(',') === '1,2,3,4,5') return 'Thứ 2 - Thứ 6';
  if (sorted.join(',') === '6,7') return 'Cuối tuần';
  return sorted.map((d) => WEEKDAYS.find((w) => w.value === d)?.short ?? d).join(', ');
}

/** Thứ hôm nay theo quy ước 1..7 */
export function todayWeekday(date = new Date()): number {
  const d = date.getDay();
  return d === 0 ? 7 : d;
}

export const APPOINTMENT_STATUS_META: Record<AppointmentStatus, { label: string; color: keyof Palette; soft: keyof Palette; icon: string }> = {
  upcoming: { label: 'Sắp tới', color: 'info', soft: 'infoSoft', icon: 'time-outline' },
  done: { label: 'Đã khám', color: 'success', soft: 'successSoft', icon: 'checkmark-circle-outline' },
  cancelled: { label: 'Đã hủy', color: 'textMuted', soft: 'surfaceAlt', icon: 'close-circle-outline' },
};

export const ACTIVITY_TYPE_META: Record<ActivityType, { label: string; icon: string; color: keyof Palette; soft: keyof Palette }> = {
  walking: { label: 'Đi bộ', icon: 'walk-outline', color: 'primary', soft: 'primarySoft' },
  running: { label: 'Chạy bộ', icon: 'speedometer-outline', color: 'danger', soft: 'dangerSoft' },
  cycling: { label: 'Đạp xe', icon: 'bicycle-outline', color: 'info', soft: 'infoSoft' },
  yoga: { label: 'Yoga', icon: 'body-outline', color: 'accent', soft: 'accentSoft' },
  swimming: { label: 'Bơi lội', icon: 'water-outline', color: 'info', soft: 'infoSoft' },
  other: { label: 'Khác', icon: 'fitness-outline', color: 'warning', soft: 'warningSoft' },
};

export const HEALTH_CATEGORY_META: Record<HealthCategory, { label: string; icon: string }> = {
  medicine: { label: 'Uống thuốc', icon: 'medkit-outline' },
  checkup: { label: 'Khám bệnh', icon: 'medical-outline' },
  activity: { label: 'Vận động', icon: 'walk-outline' },
  vitals: { label: 'Chỉ số', icon: 'pulse-outline' },
  other: { label: 'Khác', icon: 'ellipsis-horizontal-circle-outline' },
};

export const HEALTH_STATUS_META: Record<HealthStatus, { label: string; color: keyof Palette; soft: keyof Palette }> = {
  completed: { label: 'Đúng giờ', color: 'success', soft: 'successSoft' },
  late: { label: 'Trễ giờ', color: 'warning', soft: 'warningSoft' },
  missed: { label: 'Bỏ lỡ', color: 'danger', soft: 'dangerSoft' },
  pending: { label: 'Chờ', color: 'info', soft: 'infoSoft' },
};

export type NotificationKind = 'fall' | 'invite' | 'safezone_in' | 'safezone_out' | 'relationship' | 'other';

export function classifyNotification(n: AppNotification): NotificationKind {
  const t = (n.title || '').toLowerCase();
  if (t.includes('té ngã') || t.includes('te nga') || n.fall_latitude != null) return 'fall';
  if (t.includes('xác nhận mối quan hệ')) return 'invite';
  if (t.includes('roi khoi') || t.includes('rời khỏi')) return 'safezone_out';
  if (t.includes('vao vung') || t.includes('vào vùng')) return 'safezone_in';
  if (t.includes('quan hệ') || t.includes('mối quan hệ')) return 'relationship';
  return 'other';
}

export const NOTIFICATION_META: Record<NotificationKind, { label: string; icon: string; color: keyof Palette; soft: keyof Palette }> = {
  fall: { label: 'Té ngã', icon: 'warning', color: 'danger', soft: 'dangerSoft' },
  invite: { label: 'Lời mời', icon: 'person-add', color: 'accent', soft: 'accentSoft' },
  safezone_in: { label: 'Vào vùng an toàn', icon: 'shield-checkmark', color: 'success', soft: 'successSoft' },
  safezone_out: { label: 'Rời vùng an toàn', icon: 'exit', color: 'warning', soft: 'warningSoft' },
  relationship: { label: 'Gia đình', icon: 'people', color: 'info', soft: 'infoSoft' },
  other: { label: 'Hệ thống', icon: 'notifications', color: 'primary', soft: 'primarySoft' },
};

/** Thêm dấu cho nội dung vùng an toàn (BE trả về không dấu). */
export function prettifyNotificationText(text: string): string {
  return text
    .replace(/Da vao vung an toan/g, 'Đã vào vùng an toàn')
    .replace(/Da roi khoi vung an toan/g, 'Đã rời khỏi vùng an toàn')
    .replace(/ da vao vung an toan /g, ' đã vào vùng an toàn ')
    .replace(/ da roi khoi vung an toan /g, ' đã rời khỏi vùng an toàn ');
}
