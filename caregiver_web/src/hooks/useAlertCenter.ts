import { useEffect, useMemo, useRef } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { qk, useNotifications } from '../api/hooks';
import type { AppNotification } from '../api/types';
import { getSupabase } from '../lib/supabase';
import { useAuthStore } from '../store/auth';
import { useUiStore } from '../store/ui';
import { toast } from '../store/toast';
import { classifyNotification, prettifyNotificationText } from '../utils/constants';

/** Âm báo động tạo bằng Web Audio (không cần file âm thanh). */
export function playAlarm(kind: 'fall' | 'soft' = 'fall') {
  try {
    const Ctx = (window as any).AudioContext || (window as any).webkitAudioContext;
    if (!Ctx) return;
    const ctx = new Ctx();
    const now = ctx.currentTime;
    const pattern = kind === 'fall' ? [0, 0.28, 0.56, 0.84, 1.12, 1.4] : [0, 0.18];
    pattern.forEach((t, i) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = kind === 'fall' ? 'square' : 'sine';
      osc.frequency.value = kind === 'fall' ? (i % 2 === 0 ? 880 : 660) : i === 0 ? 740 : 990;
      gain.gain.setValueAtTime(0.0001, now + t);
      gain.gain.exponentialRampToValueAtTime(kind === 'fall' ? 0.18 : 0.12, now + t + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + t + 0.24);
      osc.connect(gain).connect(ctx.destination);
      osc.start(now + t);
      osc.stop(now + t + 0.26);
    });
    setTimeout(() => ctx.close?.(), 2500);
  } catch {
    /* trình duyệt chặn audio khi chưa có tương tác — bỏ qua */
  }
}

function desktopNotify(title: string, body: string) {
  try {
    if (typeof Notification === 'undefined') return;
    if (Notification.permission === 'granted') {
      const n = new Notification(title, { body, icon: '/favicon.ico', tag: `fg-${title}` });
      n.onclick = () => window.focus();
    }
  } catch {
    /* noop */
  }
}

export function requestDesktopPermission() {
  if (typeof Notification !== 'undefined' && Notification.permission === 'default') {
    Notification.requestPermission().catch(() => undefined);
  }
}

/**
 * Trung tâm cảnh báo:
 *  - Lắng nghe Supabase Realtime (bảng notification) để làm mới ngay khi có sự kiện.
 *  - Polling dự phòng 20s (trong useNotifications).
 *  - Phát hiện thông báo MỚI → toast + âm báo + thông báo desktop.
 *  - Trả về danh sách cảnh báo té ngã chưa xác nhận để hiển thị popup khẩn cấp.
 */
export function useAlertCenter() {
  const client = useQueryClient();
  const session = useAuthStore((s) => s.session);
  const { data } = useNotifications();
  const soundEnabled = useUiStore((s) => s.soundEnabled);
  const desktop = useUiStore((s) => s.desktopNotify);
  const acknowledged = useUiStore((s) => s.acknowledgedAlertIds);
  const knownIds = useRef<Set<number> | null>(null);

  // Realtime subscription
  useEffect(() => {
    const supabase = getSupabase();
    const uid = session?.userId;
    const token = session?.accessToken;
    if (!supabase || !uid || !token) return;
    let disposed = false;
    supabase.realtime.setAuth(token);
    const channel = supabase
      .channel(`fg-web-notification-${uid}-${Date.now()}`)
      .on('postgres_changes', { event: '*', schema: 'public', table: 'notification', filter: `uid=eq.${uid}` }, () => {
        if (!disposed) client.invalidateQueries({ queryKey: qk.notifications });
      })
      .on('postgres_changes', { event: '*', schema: 'public', table: 'relationship', filter: `uid=eq.${uid}` }, () => {
        if (!disposed) client.invalidateQueries({ queryKey: qk.relationships });
      })
      .subscribe();
    return () => {
      disposed = true;
      supabase.removeChannel(channel);
    };
  }, [session?.userId, session?.accessToken, client]);

  // Phát hiện thông báo mới
  useEffect(() => {
    if (!data) return;
    if (knownIds.current === null) {
      knownIds.current = new Set(data.map((n) => n.id));
      return;
    }
    const fresh = data.filter((n) => !knownIds.current!.has(n.id));
    fresh.forEach((n) => knownIds.current!.add(n.id));
    if (fresh.length === 0) return;

    let hasFall = false;
    fresh.slice(0, 3).forEach((n) => {
      const kind = classifyNotification(n);
      const title = prettifyNotificationText(n.title);
      const body = prettifyNotificationText(n.content);
      if (kind === 'fall') {
        hasFall = true;
      } else if (kind === 'safezone_out') {
        toast.warning(title, body);
      } else {
        toast.info(title, body);
      }
      if (desktop) desktopNotify(kind === 'fall' ? `🚨 ${title}` : title, body);
    });
    if (soundEnabled) playAlarm(hasFall ? 'fall' : 'soft');
    // Làm mới vị trí khi có cảnh báo liên quan đến di chuyển
    client.invalidateQueries({ queryKey: qk.familyLocations });
  }, [data, soundEnabled, desktop, client]);

  const activeFallAlerts = useMemo<AppNotification[]>(() => {
    const ack = new Set(acknowledged);
    const sixHours = 6 * 60 * 60 * 1000;
    return (data ?? []).filter(
      (n) =>
        classifyNotification(n) === 'fall' &&
        !ack.has(n.id) &&
        Date.now() - new Date(n.created_at).getTime() < sixHours,
    );
  }, [data, acknowledged]);

  return { activeFallAlerts };
}

export function useUnreadCount() {
  const { data } = useNotifications();
  const seen = useUiStore((s) => s.seenNotificationIds);
  return useMemo(() => {
    const set = new Set(seen);
    return (data ?? []).filter((n) => !set.has(n.id)).length;
  }, [data, seen]);
}
