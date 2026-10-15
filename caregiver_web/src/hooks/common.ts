import { useEffect, useRef, useState } from 'react';
import { useWindowDimensions } from 'react-native';
import { breakpoints } from '../theme/tokens';

export function useBreakpoint() {
  const { width } = useWindowDimensions();
  return {
    width,
    isMobile: width < breakpoints.mobile,
    isTablet: width >= breakpoints.mobile && width < breakpoints.tablet,
    isDesktop: width >= breakpoints.tablet,
    isWide: width >= breakpoints.wide,
  };
}

export function useDebounce<T>(value: T, delay = 300): T {
  const [v, setV] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setV(value), delay);
    return () => clearTimeout(t);
  }, [value, delay]);
  return v;
}

function isTypingTarget(target: EventTarget | null) {
  const el = target as HTMLElement | null;
  if (!el) return false;
  const tag = el.tagName;
  return tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || el.isContentEditable;
}

type Handler = (e: KeyboardEvent) => void;

/**
 * Đăng ký phím tắt. Cú pháp: 'mod+k' (Ctrl/Cmd), 'alt+1', 'n', '/', 'shift+?'.
 * Phím đơn (không có modifier) bị bỏ qua khi đang gõ trong ô nhập liệu.
 */
export function useHotkeys(map: Record<string, Handler>, deps: unknown[] = []) {
  const ref = useRef(map);
  ref.current = map;
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      const key = e.key.toLowerCase();
      for (const combo of Object.keys(ref.current)) {
        const parts = combo.toLowerCase().split('+');
        const main = parts[parts.length - 1];
        const needMod = parts.includes('mod');
        const needAlt = parts.includes('alt');
        const needShift = parts.includes('shift');
        const modPressed = e.ctrlKey || e.metaKey;
        const keyMatch = key === main || e.code.toLowerCase() === `digit${main}` || e.code.toLowerCase() === `key${main}`;
        if (!keyMatch) continue;
        if (needMod !== modPressed) continue;
        if (needAlt !== e.altKey) continue;
        if (needShift && !e.shiftKey) continue;
        if (!needMod && !needAlt && isTypingTarget(e.target)) continue;
        e.preventDefault();
        ref.current[combo](e);
        return;
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
}

export function useNow(intervalMs = 30_000) {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    const t = setInterval(() => setNow(new Date()), intervalMs);
    return () => clearInterval(t);
  }, [intervalMs]);
  return now;
}
