import type { ViewStyle, TextStyle } from 'react-native';

/**
 * RN Web hỗ trợ các thuộc tính CSS chỉ có trên web (boxShadow, transition, cursor,
 * backgroundImage, backdropFilter...). Type của RN chưa khai báo nên ép kiểu tại đây.
 */
export const web = (style: Record<string, unknown>): ViewStyle & TextStyle => style as ViewStyle & TextStyle;

export const shadow = (level: 1 | 2 | 3 | 4, color = 'rgba(15, 40, 45, 0.10)') => {
  const map = {
    1: `0 1px 2px ${color}, 0 1px 1px rgba(0,0,0,0.02)`,
    2: `0 4px 14px ${color}, 0 1px 3px rgba(0,0,0,0.04)`,
    3: `0 12px 32px ${color}, 0 2px 6px rgba(0,0,0,0.05)`,
    4: `0 24px 60px ${color}, 0 6px 16px rgba(0,0,0,0.08)`,
  } as const;
  return web({ boxShadow: map[level] });
};

export const transition = (props = 'all', ms = 180) =>
  web({ transitionProperty: props, transitionDuration: `${ms}ms`, transitionTimingFunction: 'cubic-bezier(0.2, 0.8, 0.2, 1)' });

export const gradient = (from: string, to: string, angle = 135) =>
  web({ backgroundImage: `linear-gradient(${angle}deg, ${from}, ${to})` });

/** Pressable state trên web có thêm hovered/focused. */
export type WebPressState = { pressed: boolean; hovered?: boolean; focused?: boolean };
