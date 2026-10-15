import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';
import type { ThemeMode } from '../theme/tokens';

interface UiState {
  themeMode: ThemeMode | 'system';
  sidebarCollapsed: boolean;
  apiBaseUrlOverride: string;
  soundEnabled: boolean;
  desktopNotify: boolean;
  /** Danh sách id thông báo đã xem (đánh dấu đã đọc phía client). */
  seenNotificationIds: number[];
  /** Id cảnh báo té ngã đã được xác nhận (để không bật lại popup). */
  acknowledgedAlertIds: number[];
  setThemeMode: (mode: ThemeMode | 'system') => void;
  toggleSidebar: () => void;
  setApiBaseUrlOverride: (url: string) => void;
  setSoundEnabled: (value: boolean) => void;
  setDesktopNotify: (value: boolean) => void;
  markNotificationsSeen: (ids: number[]) => void;
  acknowledgeAlert: (id: number) => void;
}

const MAX_TRACKED = 600;

export const useUiStore = create<UiState>()(
  persist(
    (set, get) => ({
      themeMode: 'light',
      sidebarCollapsed: false,
      apiBaseUrlOverride: '',
      soundEnabled: true,
      desktopNotify: true,
      seenNotificationIds: [],
      acknowledgedAlertIds: [],
      setThemeMode: (themeMode) => set({ themeMode }),
      toggleSidebar: () => set({ sidebarCollapsed: !get().sidebarCollapsed }),
      setApiBaseUrlOverride: (apiBaseUrlOverride) => set({ apiBaseUrlOverride }),
      setSoundEnabled: (soundEnabled) => set({ soundEnabled }),
      setDesktopNotify: (desktopNotify) => set({ desktopNotify }),
      markNotificationsSeen: (ids) => {
        const merged = Array.from(new Set([...get().seenNotificationIds, ...ids]));
        set({ seenNotificationIds: merged.slice(-MAX_TRACKED) });
      },
      acknowledgeAlert: (id) => {
        const merged = Array.from(new Set([...get().acknowledgedAlertIds, id]));
        set({ acknowledgedAlertIds: merged.slice(-MAX_TRACKED) });
      },
    }),
    {
      name: 'fg-caregiver-ui',
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
