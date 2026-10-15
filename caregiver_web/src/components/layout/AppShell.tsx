import React, { useEffect, useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { usePathname, useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { web } from '../../theme/web';
import { Sidebar } from './Sidebar';
import { Topbar } from './Topbar';
import { CommandPalette } from './CommandPalette';
import { FallAlertModal } from './FallAlertModal';
import { ALL_NAV } from './nav';
import { useBreakpoint, useHotkeys } from '../../hooks/common';
import { requestDesktopPermission, useAlertCenter } from '../../hooks/useAlertCenter';
import { useUiStore } from '../../store/ui';

/**
 * Khung ứng dụng: Sidebar (desktop / thu gọn trên tablet / ngăn kéo trên mobile),
 * Topbar, bảng lệnh (Ctrl+K), phím tắt toàn cục và popup cảnh báo té ngã.
 */
export function AppShell({ children }: { children: React.ReactNode }) {
  const c = useTheme();
  const router = useRouter();
  const pathname = usePathname();
  const { isMobile, isTablet } = useBreakpoint();
  const collapsedPref = useUiStore((s) => s.sidebarCollapsed);
  const themeMode = useUiStore((s) => s.themeMode);
  const setThemeMode = useUiStore((s) => s.setThemeMode);
  const toggleSidebar = useUiStore((s) => s.toggleSidebar);
  const [paletteOpen, setPaletteOpen] = useState(false);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const { activeFallAlerts } = useAlertCenter();

  // Đóng ngăn kéo khi chuyển trang
  useEffect(() => setDrawerOpen(false), [pathname]);

  // Xin quyền thông báo desktop ở lần tương tác đầu tiên
  useEffect(() => {
    const once = () => {
      requestDesktopPermission();
      window.removeEventListener('pointerdown', once);
    };
    window.addEventListener('pointerdown', once);
    return () => window.removeEventListener('pointerdown', once);
  }, []);

  // Cập nhật tiêu đề tab theo trang
  useEffect(() => {
    const nav = ALL_NAV.find((n) => (n.href === '/' ? pathname === '/' : pathname.startsWith(n.href)));
    const alert = activeFallAlerts.length ? '🚨 ' : '';
    document.title = `${alert}${nav ? nav.label : 'Support Family'} · Support Family Caregiver`;
  }, [pathname, activeFallAlerts.length]);

  const navHotkeys: Record<string, () => void> = {};
  ALL_NAV.forEach((n) => {
    if (n.shortcut) navHotkeys[`alt+${n.shortcut}`] = () => router.push(n.href as any);
  });

  useHotkeys({
    'mod+k': () => setPaletteOpen((v) => !v),
    '?': () => setPaletteOpen(true),
    'shift+d': () => setThemeMode(themeMode === 'dark' ? 'light' : 'dark'),
    'mod+b': () => toggleSidebar(),
    ...navHotkeys,
  }, [themeMode]);

  const collapsed = isTablet ? true : collapsedPref;

  return (
    <View style={[styles.root, { backgroundColor: c.bg }]}>
      {!isMobile ? <Sidebar collapsed={collapsed} /> : null}

      <View style={styles.main}>
        <Topbar onOpenPalette={() => setPaletteOpen(true)} onOpenMenu={() => setDrawerOpen(true)} />
        <View style={styles.content}>{children}</View>
      </View>

      {isMobile && drawerOpen ? (
        <View style={[StyleSheet.absoluteFill, { zIndex: 100, flexDirection: 'row' }]}>
          <View dataSet={{ anim: 'fade' }} style={[StyleSheet.absoluteFill, { backgroundColor: c.overlay }]}>
            <Pressable style={StyleSheet.absoluteFill} onPress={() => setDrawerOpen(false)} accessibilityLabel="Đóng menu" />
          </View>
          <View dataSet={{ anim: 'slide-left' }} style={[{ height: '100%' }, web({ boxShadow: '0 0 40px rgba(0,0,0,0.35)' })]}>
            <Sidebar collapsed={false} onNavigate={() => setDrawerOpen(false)} />
          </View>
        </View>
      ) : null}

      <CommandPalette open={paletteOpen} onClose={() => setPaletteOpen(false)} />
      <FallAlertModal alerts={activeFallAlerts} />
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, flexDirection: 'row', height: '100%', overflow: 'hidden' },
  main: { flex: 1, minWidth: 0, height: '100%' },
  content: { flex: 1, minHeight: 0 },
});
