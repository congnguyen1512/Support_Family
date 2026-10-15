import React from 'react';
import { Image, Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { usePathname, useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { gradient, transition, web, type WebPressState } from '../../theme/web';
import { Avatar, Icon, T } from '../ui';
import { NAV_GROUPS, SETTINGS_NAV, isActive, type NavItem } from './nav';
import { useAuthStore } from '../../store/auth';
import { useUiStore } from '../../store/ui';
import { useUnreadCount } from '../../hooks/useAlertCenter';
import { useThreads } from '../../api/hooks';

function NavLink({ item, collapsed, badge, onNavigate }: { item: NavItem; collapsed: boolean; badge?: number; onNavigate?: () => void }) {
  const c = useTheme();
  const router = useRouter();
  const pathname = usePathname();
  const active = isActive(pathname, item.href);
  return (
    <Pressable
      nativeID={`nav-${item.key}`}
      accessibilityRole="link"
      accessibilityLabel={item.label}
      onPress={() => {
        router.push(item.href as any);
        onNavigate?.();
      }}
      style={(state) => {
        const { hovered } = state as WebPressState;
        return [
          styles.link,
          collapsed ? { justifyContent: 'center', paddingHorizontal: 0 } : null,
          { backgroundColor: active ? c.sidebarActive : hovered ? 'rgba(255,255,255,0.06)' : 'transparent' },
          transition('background-color', 150),
          web({ cursor: 'pointer' }),
        ];
      }}
    >
      {active ? <View style={[styles.activeBar, { backgroundColor: c.primary }]} /> : null}
      <View>
        <Icon name={active ? item.iconActive : item.icon} size={19} color={active ? '#5EE6EA' : c.sidebarMuted} />
        {collapsed && badge ? <View style={[styles.dotBadge, { backgroundColor: c.danger }]} /> : null}
      </View>
      {!collapsed ? (
        <>
          <T variant="bodyStrong" style={{ flex: 1, color: active ? '#FFFFFF' : c.sidebarText, fontWeight: active ? '700' : '500' }} numberOfLines={1}>
            {item.label}
          </T>
          {badge ? (
            <View style={[styles.countBadge, { backgroundColor: item.key === 'notifications' ? c.danger : c.primary }]}>
              <T variant="caption" style={{ color: '#fff', fontWeight: '700', fontSize: 12 }}>
                {badge > 99 ? '99+' : badge}
              </T>
            </View>
          ) : item.shortcut ? (
            <T variant="caption" style={{ color: 'rgba(255,255,255,0.28)', fontSize: 11.5 }}>
              Alt+{item.shortcut}
            </T>
          ) : null}
        </>
      ) : null}
    </Pressable>
  );
}

export function Sidebar({ collapsed, onNavigate }: { collapsed: boolean; onNavigate?: () => void }) {
  const c = useTheme();
  const router = useRouter();
  const profile = useAuthStore((s) => s.session?.profile);
  const toggle = useUiStore((s) => s.toggleSidebar);
  const unread = useUnreadCount();
  const threads = useThreads();
  const unreadChats = (threads.data ?? []).filter((t) => t.has_unread).length;

  const badges: Record<string, number> = { notifications: unread, messages: unreadChats };

  return (
    <View style={[styles.root, { width: collapsed ? 80 : 280 }, gradient(c.sidebarFrom, c.sidebarTo, 180), transition('width', 220)]}>
      <View style={[styles.brand, collapsed ? { justifyContent: 'center', paddingHorizontal: 0 } : null]}>
        <View style={styles.logo}>
          <Image source={require('../../../assets/images/logo.png')} style={styles.logoImg} resizeMode="contain" accessibilityLabel="Logo Support Family" />
        </View>
        {!collapsed ? (
          <View style={{ flex: 1 }}>
            <T variant="h3" style={{ color: '#fff', letterSpacing: -0.2 }}>
              Support Family
            </T>
            <T variant="caption" style={{ color: c.sidebarMuted }}>
              Bảng điều khiển người chăm sóc
            </T>
          </View>
        ) : null}
      </View>

      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ paddingHorizontal: collapsed ? 12 : 14, paddingBottom: 16, gap: 18 }}>
        {NAV_GROUPS.map((g) => (
          <View key={g.title} style={{ gap: 2 }}>
            {!collapsed ? (
              <T variant="label" style={{ color: 'rgba(255,255,255,0.35)', paddingHorizontal: 12, marginBottom: 6 }}>
                {g.title}
              </T>
            ) : (
              <View style={{ height: 1, backgroundColor: 'rgba(255,255,255,0.08)', marginVertical: 6 }} />
            )}
            {g.items.map((item) => (
              <NavLink key={item.key} item={item} collapsed={collapsed} badge={badges[item.key]} onNavigate={onNavigate} />
            ))}
          </View>
        ))}
      </ScrollView>

      <View style={{ paddingHorizontal: collapsed ? 12 : 14, paddingBottom: 14, gap: 8 }}>
        <NavLink item={SETTINGS_NAV} collapsed={collapsed} onNavigate={onNavigate} />
        <Pressable
          onPress={() => {
            router.push('/settings');
            onNavigate?.();
          }}
          style={(state) => {
            const { hovered } = state as WebPressState;
            return [
              styles.profile,
              collapsed ? { justifyContent: 'center', padding: 6 } : null,
              { backgroundColor: hovered ? 'rgba(255,255,255,0.08)' : 'rgba(255,255,255,0.04)' },
              transition('background-color'),
              web({ cursor: 'pointer' }),
            ];
          }}
        >
          <Avatar name={profile?.name} uri={profile?.avata} size={36} status="#12B76A" />
          {!collapsed ? (
            <View style={{ flex: 1 }}>
              <T variant="bodyStrong" style={{ color: '#fff' }} numberOfLines={1}>
                {profile?.name || 'Người chăm sóc'}
              </T>
              <T variant="caption" style={{ color: c.sidebarMuted }} numberOfLines={1}>
                {profile?.email || profile?.phone || 'Người chăm sóc'}
              </T>
            </View>
          ) : null}
        </Pressable>
        <Pressable
          onPress={toggle}
          accessibilityLabel={collapsed ? 'Mở rộng thanh bên' : 'Thu gọn thanh bên'}
          style={(state) => {
            const { hovered } = state as WebPressState;
            return [
              styles.collapse,
              { backgroundColor: hovered ? 'rgba(255,255,255,0.08)' : 'transparent' },
              web({ cursor: 'pointer' }),
            ];
          }}
        >
          <Icon name={collapsed ? 'chevron-forward' : 'chevron-back'} size={16} color={c.sidebarMuted} />
          {!collapsed ? (
            <T variant="caption" style={{ color: c.sidebarMuted }}>
              Thu gọn
            </T>
          ) : null}
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { height: '100%', overflow: 'hidden' },
  brand: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 20, paddingTop: 22, paddingBottom: 22 },
  logo: { width: 44, height: 44, borderRadius: 14, alignItems: 'center', justifyContent: 'center', backgroundColor: '#FFFFFF' },
  logoImg: { width: 32, height: 32 },
  link: { flexDirection: 'row', alignItems: 'center', gap: 12, height: 44, borderRadius: 12, paddingHorizontal: 12, position: 'relative' },
  activeBar: { position: 'absolute', left: -14, top: 10, bottom: 10, width: 4, borderTopRightRadius: 4, borderBottomRightRadius: 4 },
  countBadge: { minWidth: 22, height: 22, borderRadius: 11, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 6 },
  dotBadge: { position: 'absolute', top: -2, right: -3, width: 8, height: 8, borderRadius: 4 },
  profile: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 10, borderRadius: 14 },
  collapse: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, height: 32, borderRadius: 10 },
});
