import { create } from 'zustand';

export type ToastTone = 'success' | 'error' | 'info' | 'warning';

export interface ToastItem {
  id: number;
  tone: ToastTone;
  title: string;
  message?: string;
}

interface ToastState {
  items: ToastItem[];
  push: (tone: ToastTone, title: string, message?: string) => void;
  dismiss: (id: number) => void;
}

let seq = 1;

export const useToastStore = create<ToastState>((set, get) => ({
  items: [],
  push: (tone, title, message) => {
    const id = seq++;
    set({ items: [...get().items.slice(-4), { id, tone, title, message }] });
    setTimeout(() => get().dismiss(id), tone === 'error' ? 6000 : 3800);
  },
  dismiss: (id) => set({ items: get().items.filter((t) => t.id !== id) }),
}));

export const toast = {
  success: (title: string, message?: string) => useToastStore.getState().push('success', title, message),
  error: (title: string, message?: string) => useToastStore.getState().push('error', title, message),
  info: (title: string, message?: string) => useToastStore.getState().push('info', title, message),
  warning: (title: string, message?: string) => useToastStore.getState().push('warning', title, message),
};
