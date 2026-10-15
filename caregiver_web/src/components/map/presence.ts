import { minutesAgo } from '../../utils/format';

export const DEFAULT_CENTER: [number, number] = [10.7769, 106.7009]; // TP.HCM

/** Màu trạng thái theo thời gian cập nhật vị trí gần nhất. */
export function presenceColor(updatedAt?: string | null) {
  const m = minutesAgo(updatedAt);
  if (m === null) return '#94A3B8';
  if (m <= 10) return '#12B76A';
  if (m <= 60) return '#F59E0B';
  return '#94A3B8';
}

export function presenceLabel(updatedAt?: string | null) {
  const m = minutesAgo(updatedAt);
  if (m === null) return 'Chưa có vị trí';
  if (m <= 10) return 'Đang hoạt động';
  if (m <= 60) return 'Vừa hoạt động';
  return 'Ngoại tuyến';
}
