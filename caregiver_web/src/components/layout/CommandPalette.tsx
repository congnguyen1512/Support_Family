import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Modal as RNModal, Pressable, ScrollView, StyleSheet, TextInput, View } from 'react-native';
import { useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { fontFamily } from '../../theme/tokens';
import { shadow, web } from '../../theme/web';
import { Avatar, Icon, Kbd, T } from '../ui';
import { ALL_NAV } from './nav';
import { QUICK_ACTIONS } from './Topbar';
import { useFamilyMembers } from '../../api/hooks';
import { normalizeSearch } from '../../utils/format';
import { MEMBER_KIND_META } from '../../utils/constants';
import { useUiStore } from '../../store/ui';

interface Command {
  id: string;
  section: string;
  label: string;
  hint?: string;
  icon?: string;
  avatar?: { name: string; uri?: string | null };
  shortcut?: string;
  run: () => void;
}

const SHORTCUTS: [string, string][] = [
  ['Ctrl K', 'Mở bảng lệnh / tìm kiếm'],
  ['Alt 1 → 9', 'Chuyển nhanh giữa các trang'],
  ['Alt 0', 'Mở trang thông báo'],
  ['N', 'Tạo mới trên trang hiện tại'],
  ['/', 'Tìm kiếm trong trang'],
  ['Shift D', 'Đổi giao diện sáng / tối'],
  ['Esc', 'Đóng hộp thoại'],
];

export function CommandPalette({ open, onClose }: { open: boolean; onClose: () => void }) {
  const c = useTheme();
  const router = useRouter();
  const { members } = useFamilyMembers();
  const setThemeMode = useUiStore((s) => s.setThemeMode);
  const [query, setQuery] = useState('');
  const [index, setIndex] = useState(0);
  const inputRef = useRef<TextInput>(null);

  useEffect(() => {
    if (open) {
      setQuery('');
      setIndex(0);
      setTimeout(() => inputRef.current?.focus(), 50);
    }
  }, [open]);

  const commands = useMemo<Command[]>(() => {
    const go = (href: string) => () => {
      onClose();
      router.push(href as any);
    };
    return [
      ...QUICK_ACTIONS.map((a) => ({ id: `qa-${a.key}`, section: 'Thao tác nhanh', label: a.label, hint: a.hint, icon: a.icon, run: go(a.href) })),
      ...ALL_NAV.map((n) => ({
        id: `nav-${n.key}`,
        section: 'Đi tới trang',
        label: n.label,
        hint: n.description,
        icon: n.icon,
        shortcut: n.shortcut ? `Alt ${n.shortcut}` : undefined,
        run: go(n.href),
      })),
      ...members.flatMap((m) => [
        {
          id: `mem-${m.uid}`,
          section: 'Thành viên',
          label: m.name,
          hint: `${m.relation} · ${MEMBER_KIND_META[m.kind].label}${m.location?.address ? ` · ${m.location.address}` : ''}`,
          avatar: { name: m.name, uri: m.avatar },
          run: go(`/members?uid=${m.uid}`),
        },
        {
          id: `map-${m.uid}`,
          section: 'Thành viên',
          label: `Xem vị trí của ${m.name}`,
          hint: 'Mở trên bản đồ trực tiếp',
          icon: 'location-outline',
          run: go(`/map?uid=${m.uid}`),
        },
        {
          id: `chat-${m.uid}`,
          section: 'Thành viên',
          label: `Nhắn tin cho ${m.name}`,
          icon: 'chatbubble-ellipses-outline',
          run: go(`/messages?peer=${m.uid}`),
        },
      ]),
      { id: 'theme-light', section: 'Giao diện', label: 'Chuyển sang giao diện sáng', icon: 'sunny-outline', run: () => { setThemeMode('light'); onClose(); } },
      { id: 'theme-dark', section: 'Giao diện', label: 'Chuyển sang giao diện tối', icon: 'moon-outline', run: () => { setThemeMode('dark'); onClose(); } },
      { id: 'theme-system', section: 'Giao diện', label: 'Theo giao diện hệ thống', icon: 'contrast-outline', run: () => { setThemeMode('system'); onClose(); } },
    ];
  }, [members, router, onClose, setThemeMode]);

  const filtered = useMemo(() => {
    const q = normalizeSearch(query);
    if (!q) return commands.filter((cmd) => cmd.section !== 'Thành viên' || cmd.id.startsWith('mem-')).slice(0, 40);
    return commands.filter((cmd) => normalizeSearch(`${cmd.label} ${cmd.hint ?? ''}`).includes(q)).slice(0, 50);
  }, [commands, query]);

  useEffect(() => setIndex(0), [query]);

  const onKeyPress = (e: any) => {
    const key = e.nativeEvent?.key ?? e.key;
    if (key === 'ArrowDown') {
      e.preventDefault?.();
      setIndex((i) => Math.min(filtered.length - 1, i + 1));
    } else if (key === 'ArrowUp') {
      e.preventDefault?.();
      setIndex((i) => Math.max(0, i - 1));
    } else if (key === 'Enter') {
      e.preventDefault?.();
      filtered[index]?.run();
    } else if (key === 'Escape') {
      onClose();
    }
  };

  if (!open) return null;
  const showHelp = query.trim() === '?';
  let lastSection = '';

  return (
    <RNModal transparent visible animationType="none" onRequestClose={onClose}>
      <View style={[styles.overlay, { backgroundColor: c.overlay }]}>
        <Pressable style={StyleSheet.absoluteFill} onPress={onClose} />
        <View dataSet={{ anim: 'pop' }} style={[styles.panel, { backgroundColor: c.elevated, borderColor: c.border }, shadow(4, 'rgba(0,0,0,0.3)')]}>
          <View style={[styles.inputRow, { borderBottomColor: c.border }]}>
            <Icon name="search" size={20} color="primary" />
            <TextInput
              ref={inputRef}
              value={query}
              onChangeText={setQuery}
              onKeyPress={onKeyPress}
              placeholder="Gõ để tìm thành viên, trang, thao tác...  (gõ ? để xem phím tắt)"
              placeholderTextColor={c.textMuted}
              style={[styles.input, { color: c.text }, web({ outlineStyle: 'none' })]}
            />
            <Kbd>Esc</Kbd>
          </View>
          <ScrollView style={{ maxHeight: 440 }} contentContainerStyle={{ padding: 8 }}>
            {showHelp ? (
              <View style={{ padding: 8, gap: 6 }}>
                <T variant="label" color="textMuted" style={{ marginBottom: 6 }}>
                  Phím tắt bàn phím
                </T>
                {SHORTCUTS.map(([k, d]) => (
                  <View key={k} style={styles.helpRow}>
                    <T variant="body" color="textSoft" style={{ flex: 1 }}>
                      {d}
                    </T>
                    <Kbd>{k}</Kbd>
                  </View>
                ))}
              </View>
            ) : filtered.length === 0 ? (
              <View style={{ padding: 32, alignItems: 'center', gap: 6 }}>
                <Icon name="search-outline" size={28} color="textMuted" />
                <T variant="body" color="textMuted">
                  Không tìm thấy kết quả cho “{query}”
                </T>
              </View>
            ) : (
              filtered.map((cmd, i) => {
                const header = cmd.section !== lastSection ? cmd.section : null;
                lastSection = cmd.section;
                const active = i === index;
                return (
                  <React.Fragment key={cmd.id}>
                    {header ? (
                      <T variant="label" color="textMuted" style={{ paddingHorizontal: 10, paddingTop: i === 0 ? 4 : 12, paddingBottom: 6 }}>
                        {header}
                      </T>
                    ) : null}
                    <Pressable
                      onPress={cmd.run}
                      onHoverIn={() => setIndex(i)}
                      style={[styles.item, { backgroundColor: active ? c.primarySoft : 'transparent' }, web({ cursor: 'pointer' })]}
                    >
                      {cmd.avatar ? (
                        <Avatar name={cmd.avatar.name} uri={cmd.avatar.uri} size={30} />
                      ) : (
                        <View style={[styles.itemIcon, { backgroundColor: active ? c.primary : c.surfaceAlt }]}>
                          <Icon name={cmd.icon ?? 'arrow-forward'} size={16} color={active ? '#fff' : 'textSoft'} />
                        </View>
                      )}
                      <View style={{ flex: 1 }}>
                        <T variant="bodyStrong" numberOfLines={1}>
                          {cmd.label}
                        </T>
                        {cmd.hint ? (
                          <T variant="caption" color="textMuted" numberOfLines={1}>
                            {cmd.hint}
                          </T>
                        ) : null}
                      </View>
                      {cmd.shortcut ? <Kbd>{cmd.shortcut}</Kbd> : active ? <Icon name="return-down-back" size={16} color="primary" /> : null}
                    </Pressable>
                  </React.Fragment>
                );
              })
            )}
          </ScrollView>
          <View style={[styles.footer, { borderTopColor: c.border, backgroundColor: c.surfaceAlt }]}>
            <View style={styles.footerHint}>
              <Kbd>↑↓</Kbd>
              <T variant="caption" color="textMuted">di chuyển</T>
            </View>
            <View style={styles.footerHint}>
              <Kbd>Enter</Kbd>
              <T variant="caption" color="textMuted">chọn</T>
            </View>
            <View style={styles.footerHint}>
              <Kbd>?</Kbd>
              <T variant="caption" color="textMuted">phím tắt</T>
            </View>
          </View>
        </View>
      </View>
    </RNModal>
  );
}

const styles = StyleSheet.create({
  overlay: { flex: 1, alignItems: 'center', paddingTop: '12vh' as any, paddingHorizontal: 16 },
  panel: { width: 640, maxWidth: '100%', borderRadius: 20, borderWidth: 1, overflow: 'hidden' },
  inputRow: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 18, height: 60, borderBottomWidth: 1 },
  input: { flex: 1, fontSize: 16, fontFamily: fontFamily.regular, height: '100%' },
  item: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 10, paddingVertical: 8, borderRadius: 12 },
  itemIcon: { width: 30, height: 30, borderRadius: 9, alignItems: 'center', justifyContent: 'center' },
  helpRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 6, paddingHorizontal: 4 },
  footer: { flexDirection: 'row', gap: 16, paddingHorizontal: 16, paddingVertical: 10, borderTopWidth: 1 },
  footerHint: { flexDirection: 'row', alignItems: 'center', gap: 6 },
});
