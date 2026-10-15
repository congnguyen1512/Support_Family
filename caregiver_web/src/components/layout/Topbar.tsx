import React, { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { shadow, transition, web, type WebPressState } from '../../theme/web';
import { Avatar, Button, Icon, IconButton, Kbd, T } from '../ui';
import { useAuthStore } from '../../store/auth';
import { useUiStore } from '../../store/ui';
import { useUnreadCount } from '../../hooks/useAlertCenter';
import { useBreakpoint, useNow } from '../../hooks/common';
import { authApi } from '../../api/endpoints';
import { queryClient } from '../../api/hooks';
import { confirm } from '../ui/Overlay';

export const QUICK_ACTIONS = [
  { key: 'reminder', label: 'Tạo nhắc nhở', icon: 'alarm-outline', href: '/reminders?new=1', hint: 'Uống thuốc, ăn uống...' },
  { key: 'appointment', label: 'Đặt lịch khám', icon: 'medkit-outline', href: '/appointments?new=1', hint: 'Lịch tái khám, bác sĩ' },
  { key: 'zone', label: 'Thêm vùng an toàn', icon: 'shield-checkmark-outline', href: '/safe-zones?new=1', hint: 'Geofence cho thành viên' },
  { key: 'activity', label: 'Thêm bài vận động', icon: 'walk-outline', href: '/activities?new=1', hint: 'Đi bộ, yoga, đạp xe' },
  { key: 'invite', label: 'Mời thành viên', icon: 'person-add-outline', href: '/members?invite=1', hint: 'Tìm qua email / SĐT' },
];

function Dropdown({ open, onClose, children, width = 260 }: { open: boolean; onClose: () => void; children: React.ReactNode; width?: number }) {
  const c = useTheme();
  if (!open) return null;
  return (
    <>
      <Pressable onPress={onClose} style={[web({ position: 'fixed', inset: 0, zIndex: 50 })]} accessibilityLabel="Đóng menu" />
      <View
        dataSet={{ anim: 'pop' }}
        style={[styles.dropdown, { width, backgroundColor: c.elevated, borderColor: c.border }, shadow(4, c.shadow), web({ zIndex: 60 })]}
      >
        {children}
      </View>
    </>
  );
}

function MenuItem({ icon, label, hint, onPress, danger }: { icon: string; label: string; hint?: string; onPress: () => void; danger?: boolean }) {
  const c = useTheme();
  return (
    <Pressable
      onPress={onPress}
      style={(state) => {
        const { hovered } = state as WebPressState;
        return [styles.menuItem, { backgroundColor: hovered ? c.surfaceHover : 'transparent' }, transition('background-color', 120), web({ cursor: 'pointer' })];
      }}
    >
      <View style={[styles.menuIcon, { backgroundColor: danger ? c.dangerSoft : c.primarySoft }]}>
        <Icon name={icon} size={16} color={danger ? 'danger' : 'primary'} />
      </View>
      <View style={{ flex: 1 }}>
        <T variant="bodyStrong" color={danger ? 'danger' : 'text'}>
          {label}
        </T>
        {hint ? (
          <T variant="caption" color="textMuted">
            {hint}
          </T>
        ) : null}
      </View>
    </Pressable>
  );
}

export function Topbar({ onOpenPalette, onOpenMenu }: { onOpenPalette: () => void; onOpenMenu: () => void }) {
  const c = useTheme();
  const router = useRouter();
  const { isMobile, isDesktop } = useBreakpoint();
  const session = useAuthStore((s) => s.session);
  const logout = useAuthStore((s) => s.logout);
  const themeMode = useUiStore((s) => s.themeMode);
  const setThemeMode = useUiStore((s) => s.setThemeMode);
  const unread = useUnreadCount();
  const now = useNow(30_000);
  const [createOpen, setCreateOpen] = useState(false);
  const [profileOpen, setProfileOpen] = useState(false);

  const isDark = themeMode === 'dark' || (themeMode === 'system' && c.mode === 'dark');

  const doLogout = async () => {
    setProfileOpen(false);
    const ok = await confirm({ title: 'Đăng xuất?', message: 'Bạn sẽ cần đăng nhập lại để tiếp tục theo dõi gia đình.', confirmLabel: 'Đăng xuất', icon: 'log-out-outline' });
    if (!ok) return;
    authApi.logout().catch(() => undefined);
    queryClient.clear();
    logout();
    router.replace('/login');
  };

  const dateLabel = now.toLocaleDateString('vi-VN', { weekday: 'long', day: '2-digit', month: '2-digit' });

  return (
    <View style={[styles.root, { borderBottomColor: c.border, backgroundColor: c.mode === 'dark' ? 'rgba(10,17,20,0.75)' : 'rgba(255,255,255,0.72)' }, web({ backdropFilter: 'saturate(180%) blur(14px)' })]}>
      {!isDesktop ? <IconButton icon="menu" label="Mở menu" onPress={onOpenMenu} variant="secondary" /> : null}

      <Pressable
        nativeID="topbar-search"
        onPress={onOpenPalette}
        accessibilityLabel="Tìm kiếm và lệnh nhanh"
        style={(state) => {
          const { hovered } = state as WebPressState;
          return [
            styles.search,
            { backgroundColor: hovered ? c.surfaceHover : c.surfaceAlt, borderColor: hovered ? c.borderStrong : c.border, maxWidth: isMobile ? undefined : 460 },
            transition('background-color, border-color'),
            web({ cursor: 'text' }),
          ];
        }}
      >
        <Icon name="search" size={17} color="textMuted" />
        <T variant="body" color="textMuted" style={{ flex: 1 }} numberOfLines={1}>
          {isMobile ? 'Tìm kiếm...' : 'Tìm thành viên, trang hoặc thao tác nhanh...'}
        </T>
        {!isMobile ? <Kbd>Ctrl K</Kbd> : null}
      </Pressable>

      <View style={{ flex: 1 }} />

      {isDesktop ? (
        <View style={styles.clock}>
          <T variant="bodyStrong">{now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}</T>
          <T variant="caption" color="textMuted" style={{ textTransform: 'capitalize' }}>
            {dateLabel}
          </T>
        </View>
      ) : null}

      <View>
        {isMobile ? (
          <IconButton icon="add" label="Tạo nhanh" variant="soft" onPress={() => setCreateOpen((v) => !v)} />
        ) : (
          <Button nativeID="topbar-quick-create" label="Tạo nhanh" icon="add" onPress={() => setCreateOpen((v) => !v)} size="md" />
        )}
        <Dropdown open={createOpen} onClose={() => setCreateOpen(false)} width={280}>
          <T variant="label" color="textMuted" style={{ paddingHorizontal: 10, paddingVertical: 6 }}>
            Thao tác nhanh
          </T>
          {QUICK_ACTIONS.map((a) => (
            <MenuItem
              key={a.key}
              icon={a.icon}
              label={a.label}
              hint={a.hint}
              onPress={() => {
                setCreateOpen(false);
                router.push(a.href as any);
              }}
            />
          ))}
        </Dropdown>
      </View>

      <IconButton
        icon={isDark ? 'sunny-outline' : 'moon-outline'}
        label={isDark ? 'Chế độ sáng' : 'Chế độ tối'}
        variant="secondary"
        onPress={() => setThemeMode(isDark ? 'light' : 'dark')}
      />
      <IconButton
        icon="notifications-outline"
        label="Thông báo"
        variant="secondary"
        badge={unread > 0 ? unread : undefined}
        onPress={() => router.push('/notifications')}
      />

      <View>
        <Pressable onPress={() => setProfileOpen((v) => !v)} accessibilityLabel="Tài khoản" style={web({ cursor: 'pointer' })}>
          <Avatar name={session?.profile?.name} uri={session?.profile?.avata} size={38} ring={c.primarySoft} />
        </Pressable>
        <Dropdown open={profileOpen} onClose={() => setProfileOpen(false)}>
          <View style={{ padding: 10, flexDirection: 'row', gap: 10, alignItems: 'center' }}>
            <Avatar name={session?.profile?.name} uri={session?.profile?.avata} size={42} />
            <View style={{ flex: 1 }}>
              <T variant="bodyStrong" numberOfLines={1}>
                {session?.profile?.name || 'Người chăm sóc'}
              </T>
              <T variant="caption" color="textMuted" numberOfLines={1}>
                {session?.profile?.email || session?.profile?.phone}
              </T>
            </View>
          </View>
          <View style={{ height: 1, backgroundColor: c.border, marginVertical: 4 }} />
          <MenuItem icon="person-circle-outline" label="Hồ sơ cá nhân" onPress={() => { setProfileOpen(false); router.push('/settings'); }} />
          <MenuItem icon="keypad-outline" label="Phím tắt" hint="Nhấn ? để xem" onPress={() => { setProfileOpen(false); onOpenPalette(); }} />
          <MenuItem icon="log-out-outline" label="Đăng xuất" danger onPress={doLogout} />
        </Dropdown>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { height: 68, flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 20, borderBottomWidth: 1, zIndex: 20 },
  search: { flex: 1, height: 42, flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 14, borderRadius: 12, borderWidth: 1 },
  clock: { alignItems: 'flex-end', marginRight: 6 },
  dropdown: { position: 'absolute', top: 48, right: 0, borderRadius: 16, borderWidth: 1, padding: 6 },
  menuItem: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 8, borderRadius: 10 },
  menuIcon: { width: 32, height: 32, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
});
