/* Tiện ích định dạng ngày giờ / số liệu (tiếng Việt) */

const pad = (n: number) => String(n).padStart(2, '0');

export function toDate(value?: string | Date | null): Date | null {
  if (!value) return null;
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
}

/** yyyy-MM-dd theo giờ địa phương */
export function toISODate(date: Date = new Date()): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

/** Parse 'yyyy-MM-dd' thành Date (giờ địa phương, tránh lệch múi giờ). */
export function parseISODate(value?: string | null): Date | null {
  if (!value) return null;
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(value);
  if (!m) return toDate(value);
  return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]));
}

export function formatDate(value?: string | Date | null, opts: Intl.DateTimeFormatOptions = {}): string {
  const d = typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value) ? parseISODate(value) : toDate(value);
  if (!d) return '—';
  return d.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric', ...opts });
}

export function formatDateLong(value?: string | Date | null): string {
  const d = typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value) ? parseISODate(value) : toDate(value);
  if (!d) return '—';
  const s = d.toLocaleDateString('vi-VN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
  return s.charAt(0).toUpperCase() + s.slice(1);
}

export function formatTime(value?: string | Date | null): string {
  const d = toDate(value);
  if (!d) return '—';
  return `${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export function formatDateTime(value?: string | Date | null): string {
  const d = toDate(value);
  if (!d) return '—';
  return `${formatTime(d)} · ${formatDate(d)}`;
}

/** Chuẩn hóa '08:00:00' -> '08:00' */
export function shortTime(value?: string | null): string {
  if (!value) return '--:--';
  const m = /^(\d{1,2}):(\d{2})/.exec(value.trim());
  return m ? `${pad(Number(m[1]))}:${m[2]}` : value;
}

export function timeToMinutes(value?: string | null): number {
  const m = /^(\d{1,2}):(\d{2})/.exec(value ?? '');
  return m ? Number(m[1]) * 60 + Number(m[2]) : 0;
}

export function relativeTime(value?: string | Date | null): string {
  const d = toDate(value);
  if (!d) return 'Chưa có dữ liệu';
  const diff = Date.now() - d.getTime();
  const sec = Math.round(diff / 1000);
  if (sec < 0) return 'Vừa xong';
  if (sec < 45) return 'Vừa xong';
  const min = Math.round(sec / 60);
  if (min < 60) return `${min} phút trước`;
  const hour = Math.round(min / 60);
  if (hour < 24) return `${hour} giờ trước`;
  const day = Math.round(hour / 24);
  if (day < 7) return `${day} ngày trước`;
  return formatDate(d);
}

export function isToday(value?: string | Date | null): boolean {
  const d = typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value) ? parseISODate(value) : toDate(value);
  if (!d) return false;
  const n = new Date();
  return d.getFullYear() === n.getFullYear() && d.getMonth() === n.getMonth() && d.getDate() === n.getDate();
}

export function daysUntil(isoDate?: string | null): number | null {
  const d = parseISODate(isoDate);
  if (!d) return null;
  const today = parseISODate(toISODate())!;
  return Math.round((d.getTime() - today.getTime()) / 86400000);
}

export function greeting(date = new Date()): string {
  const h = date.getHours();
  if (h < 11) return 'Chào buổi sáng';
  if (h < 14) return 'Chào buổi trưa';
  if (h < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}

export function formatNumber(value?: number | null): string {
  if (value === null || value === undefined || Number.isNaN(value)) return '0';
  return value.toLocaleString('vi-VN');
}

export function formatDistance(meters?: number | null): string {
  if (meters === null || meters === undefined) return '—';
  if (meters < 1000) return `${Math.round(meters)} m`;
  return `${(meters / 1000).toFixed(meters < 10000 ? 2 : 1)} km`;
}

export function haversineMeters(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const toRad = (v: number) => (v * Math.PI) / 180;
  const R = 6371000;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export function initials(name?: string | null): string {
  const parts = (name ?? '').trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '?';
  if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
  return (parts[parts.length - 2].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
}

export function calcAge(birthday?: string | null): number | null {
  const d = parseISODate(birthday);
  if (!d) return null;
  const now = new Date();
  let age = now.getFullYear() - d.getFullYear();
  const m = now.getMonth() - d.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < d.getDate())) age--;
  return age;
}

/** Bỏ dấu tiếng Việt để tìm kiếm không phân biệt dấu. */
export function normalizeSearch(value?: string | null): string {
  return (value ?? '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase()
    .trim();
}

export function minutesAgo(value?: string | null): number | null {
  const d = toDate(value);
  if (!d) return null;
  return (Date.now() - d.getTime()) / 60000;
}
