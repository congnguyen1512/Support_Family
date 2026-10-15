import React, { useEffect } from 'react';
import { Modal as RNModal, Pressable, ScrollView, StyleSheet, View, useWindowDimensions } from 'react-native';
import { create } from 'zustand';
import { useTheme } from '../../theme/ThemeProvider';
import { radius } from '../../theme/tokens';
import { shadow, web } from '../../theme/web';
import { Button, IconButton } from './Button';
import { Icon, T, type IconName } from './Text';
import { useToastStore, type ToastTone } from '../../store/toast';

/* ── Modal ─────────────────────────────────────────────────── */
export function Modal({
  visible,
  onClose,
  title,
  subtitle,
  icon,
  children,
  footer,
  width = 560,
  side,
}: {
  visible: boolean;
  onClose: () => void;
  title?: string;
  subtitle?: string;
  icon?: IconName | string;
  children: React.ReactNode;
  footer?: React.ReactNode;
  width?: number;
  /** Hiển thị dạng ngăn kéo bên phải */
  side?: boolean;
}) {
  const c = useTheme();
  const { width: vw, height: vh } = useWindowDimensions();

  useEffect(() => {
    if (!visible) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [visible, onClose]);

  if (!visible) return null;
  const w = Math.min(width, vw - 24);

  return (
    <RNModal transparent visible={visible} onRequestClose={onClose} animationType="none">
      <View style={[styles.overlay, { backgroundColor: c.overlay }, side ? { alignItems: 'flex-end', justifyContent: 'stretch' as any, padding: 0 } : null]}>
        <Pressable style={StyleSheet.absoluteFill} onPress={onClose} accessibilityLabel="Đóng" />
        <View
          dataSet={{ anim: side ? 'slide-left' : 'pop' }}
          style={[
            styles.sheet,
            { width: w, backgroundColor: c.elevated, borderColor: c.border },
            side ? { height: vh, maxHeight: vh, borderRadius: 0, borderTopLeftRadius: 24, borderBottomLeftRadius: 24 } : { maxHeight: vh - 48 },
            shadow(4, 'rgba(0,0,0,0.25)'),
            web({ backdropFilter: 'blur(4px)' }),
          ]}
        >
          {title ? (
            <View style={[styles.header, { borderBottomColor: c.border }]}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, flex: 1 }}>
                {icon ? (
                  <View style={[styles.headerIcon, { backgroundColor: c.primarySoft }]}>
                    <Icon name={icon} size={19} color="primary" />
                  </View>
                ) : null}
                <View style={{ flex: 1 }}>
                  <T variant="h2" numberOfLines={1}>
                    {title}
                  </T>
                  {subtitle ? (
                    <T variant="small" color="textMuted" numberOfLines={2}>
                      {subtitle}
                    </T>
                  ) : null}
                </View>
              </View>
              <IconButton icon="close" label="Đóng" onPress={onClose} />
            </View>
          ) : null}
          <ScrollView style={{ flexGrow: 0, flexShrink: 1 }} contentContainerStyle={{ padding: 24, gap: 16 }} keyboardShouldPersistTaps="handled">
            {children}
          </ScrollView>
          {footer ? <View style={[styles.footer, { borderTopColor: c.border, backgroundColor: c.surfaceAlt }]}>{footer}</View> : null}
        </View>
      </View>
    </RNModal>
  );
}

/* ── Confirm dialog (promise-based) ────────────────────────── */
interface ConfirmOptions {
  title: string;
  message?: string;
  confirmLabel?: string;
  cancelLabel?: string;
  tone?: 'danger' | 'primary';
  icon?: IconName | string;
}

interface ConfirmState {
  options: ConfirmOptions | null;
  resolver: ((v: boolean) => void) | null;
  open: (o: ConfirmOptions) => Promise<boolean>;
  close: (v: boolean) => void;
}

const useConfirmStore = create<ConfirmState>((set, get) => ({
  options: null,
  resolver: null,
  open: (options) =>
    new Promise<boolean>((resolve) => {
      set({ options, resolver: resolve });
    }),
  close: (v) => {
    get().resolver?.(v);
    set({ options: null, resolver: null });
  },
}));

export const confirm = (o: ConfirmOptions) => useConfirmStore.getState().open(o);

export function ConfirmHost() {
  const c = useTheme();
  const { options, close } = useConfirmStore();
  useEffect(() => {
    if (!options) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') close(false);
      if (e.key === 'Enter') close(true);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [options, close]);
  if (!options) return null;
  const danger = options.tone !== 'primary';
  return (
    <RNModal transparent visible animationType="none" onRequestClose={() => close(false)}>
      <View style={[styles.overlay, { backgroundColor: c.overlay }]}>
        <Pressable style={StyleSheet.absoluteFill} onPress={() => close(false)} />
        <View dataSet={{ anim: 'pop' }} style={[styles.confirm, { backgroundColor: c.elevated, borderColor: c.border }, shadow(4, 'rgba(0,0,0,0.3)')]}>
          <View style={[styles.confirmIcon, { backgroundColor: danger ? c.dangerSoft : c.primarySoft }]}>
            <Icon name={options.icon ?? (danger ? 'trash-outline' : 'help-circle-outline')} size={26} color={danger ? 'danger' : 'primary'} />
          </View>
          <T variant="h2" align="center">
            {options.title}
          </T>
          {options.message ? (
            <T variant="body" color="textMuted" align="center">
              {options.message}
            </T>
          ) : null}
          <View style={{ flexDirection: 'row', gap: 10, marginTop: 10, alignSelf: 'stretch' }}>
            <Button label={options.cancelLabel ?? 'Hủy'} variant="secondary" onPress={() => close(false)} style={{ flex: 1 }} full />
            <Button
              label={options.confirmLabel ?? 'Xác nhận'}
              variant={danger ? 'danger' : 'primary'}
              onPress={() => close(true)}
              style={{ flex: 1 }}
              full
              hint="Enter"
            />
          </View>
        </View>
      </View>
    </RNModal>
  );
}

/* ── Toaster ───────────────────────────────────────────────── */
const toneMeta: Record<ToastTone, { icon: string; color: 'success' | 'danger' | 'info' | 'warning' }> = {
  success: { icon: 'checkmark-circle', color: 'success' },
  error: { icon: 'close-circle', color: 'danger' },
  info: { icon: 'information-circle', color: 'info' },
  warning: { icon: 'warning', color: 'warning' },
};

export function Toaster() {
  const c = useTheme();
  const { items, dismiss } = useToastStore();
  return (
    <View pointerEvents="box-none" style={styles.toaster}>
      {items.map((t) => {
        const meta = toneMeta[t.tone];
        return (
          <View
            key={t.id}
            dataSet={{ anim: 'slide-left' }}
            style={[styles.toast, { backgroundColor: c.elevated, borderColor: c.border, borderLeftColor: c[meta.color] }, shadow(3, c.shadow)]}
          >
            <Icon name={meta.icon} size={20} color={meta.color} />
            <View style={{ flex: 1, gap: 2 }}>
              <T variant="bodyStrong">{t.title}</T>
              {t.message ? (
                <T variant="small" color="textMuted">
                  {t.message}
                </T>
              ) : null}
            </View>
            <Pressable onPress={() => dismiss(t.id)} style={web({ cursor: 'pointer' })} accessibilityLabel="Đóng thông báo">
              <Icon name="close" size={16} color="textMuted" />
            </Pressable>
          </View>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  overlay: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 },
  sheet: { borderRadius: radius.xxl, borderWidth: 1, overflow: 'hidden' },
  header: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 24, paddingVertical: 18, borderBottomWidth: 1 },
  headerIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  footer: { flexDirection: 'row', justifyContent: 'flex-end', gap: 10, paddingHorizontal: 24, paddingVertical: 14, borderTopWidth: 1 },
  confirm: { width: 400, maxWidth: '100%', borderRadius: radius.xxl, borderWidth: 1, padding: 28, alignItems: 'center', gap: 8 },
  confirmIcon: { width: 60, height: 60, borderRadius: 30, alignItems: 'center', justifyContent: 'center', marginBottom: 6 },
  toaster: { position: 'absolute', right: 20, bottom: 20, gap: 10, width: 360, maxWidth: '90%', zIndex: 9999 },
  toast: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
    padding: 14,
    borderRadius: 14,
    borderWidth: 1,
    borderLeftWidth: 4,
  },
});
