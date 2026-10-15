import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { darkPalette, lightPalette, type Palette } from './tokens';
import { useUiStore } from '../store/ui';

const ThemeContext = createContext<Palette>(lightPalette);

function useSystemDark() {
  const [dark, setDark] = useState(
    () => typeof window !== 'undefined' && window.matchMedia?.('(prefers-color-scheme: dark)').matches,
  );
  useEffect(() => {
    if (typeof window === 'undefined' || !window.matchMedia) return;
    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    const handler = (e: MediaQueryListEvent) => setDark(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);
  return dark;
}

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const mode = useUiStore((s) => s.themeMode);
  const systemDark = useSystemDark();
  const palette = useMemo(() => {
    const isDark = mode === 'dark' || (mode === 'system' && systemDark);
    return isDark ? darkPalette : lightPalette;
  }, [mode, systemDark]);

  useEffect(() => {
    if (typeof document === 'undefined') return;
    document.documentElement.setAttribute('data-theme', palette.mode);
    document.documentElement.style.colorScheme = palette.mode;
    document.body.style.backgroundColor = palette.bg;
    const meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', palette.mode === 'dark' ? '#0A1114' : '#00ACB2');
  }, [palette]);

  return <ThemeContext.Provider value={palette}>{children}</ThemeContext.Provider>;
}

export const useTheme = () => useContext(ThemeContext);
