import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';
import type { AuthSession, UserProfile } from '../api/types';

interface AuthState {
  session: AuthSession | null;
  hydrated: boolean;
  setSession: (session: AuthSession | null) => void;
  updateTokens: (accessToken: string, refreshToken: string, expiresAt?: number | null) => void;
  updateProfile: (profile: Partial<UserProfile>) => void;
  logout: () => void;
  setHydrated: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      session: null,
      hydrated: false,
      setSession: (session) => set({ session }),
      updateTokens: (accessToken, refreshToken, expiresAt) => {
        const current = get().session;
        if (!current) return;
        set({
          session: {
            ...current,
            accessToken,
            refreshToken,
            expiresAt: expiresAt ?? current.expiresAt,
          },
        });
      },
      updateProfile: (profile) => {
        const current = get().session;
        if (!current) return;
        set({ session: { ...current, profile: { ...current.profile, ...profile } } });
      },
      logout: () => set({ session: null }),
      setHydrated: () => set({ hydrated: true }),
    }),
    {
      name: 'fg-caregiver-auth',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ session: state.session }),
      onRehydrateStorage: () => (state) => {
        state?.setHydrated();
      },
    },
  ),
);

/** Lấy nhanh session hiện tại ngoài React (dùng trong api client). */
export const getSession = () => useAuthStore.getState().session;
