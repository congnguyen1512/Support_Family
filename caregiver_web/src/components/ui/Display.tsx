import React from 'react';
import { ActivityIndicator, Image, Pressable, StyleSheet, View, type ViewStyle } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { radius, type Palette } from '../../theme/tokens';
import { shadow, transition, web, type WebPressState } from '../../theme/web';
import { Icon, T, type IconName } from './Text';
import { initials } from '../../utils/format';

/* ── Card ──────────────────────────────────────────────────── */
export function Card({
  children,
  style,
  padding = 20,
  onPress,
  anim,
  delay,
  hoverable,
}: {
  children: React.ReactNode;
  style?: ViewStyle | (ViewStyle | null | false | undefined)[];
  padding?: number;
  onPress?: () => void;
  anim?: 'rise' | 'fade' | 'pop';
  delay?: number;
  hoverable?: boolean;
}) {
  const c = useTheme();
  const base = [
    styles.card,
    { backgroundColor: c.surface, borderColor: c.border, padding },
    shadow(1, c.shadow),
  ];
  const dataSet = anim ? { anim, delay: delay ? String(delay) : undefined } : undefined;
  if (onPress || hoverable) {
    return (
      <Pressable
        onPress={onPress}
        dataSet={dataSet}
        style={(state) => {
          const { hovered } = state as WebPressState;
          return [
            ...base,
            transition('transform, box-shadow, border-color', 200),
            hovered ? [shadow(3, c.shadow), { borderColor: c.borderStrong }, web({ transform: 'translateY(-2px)' })] : null,
            web({ cursor: onPress ? 'pointer' : 'default' }),
            style as ViewStyle,
          ];
        }}
      >
        {children}
      </Pressable>
    );
  }
  return (
    <View dataSet={dataSet} style={[...base, style as ViewStyle]}>
      {children}
    </View>
  );
}

export function CardHeader({
  title,
  subtitle,
  icon,
  iconColor = 'primary',
  right,
  style,
}: {
  title: string;
  subtitle?: string;
  icon?: IconName | string;
  iconColor?: keyof Palette;
  right?: React.ReactNode;
  style?: ViewStyle;
}) {
  const c = useTheme();
  const softKey = `${String(iconColor)}Soft` as keyof Palette;
  return (
    <View style={[styles.cardHeader, style]}>
      <View style={styles.rowCenter}>
        {icon ? (
          <View style={[styles.headerIcon, { backgroundColor: (c[softKey] as string) ?? c.primarySoft }]}>
            <Icon name={icon} size={17} color={iconColor} />
          </View>
        ) : null}
        <View style={{ flexShrink: 1 }}>
          <T variant="h3" numberOfLines={1}>
            {title}
          </T>
          {subtitle ? (
            <T variant="small" color="textMuted" numberOfLines={1}>
              {subtitle}
            </T>
          ) : null}
        </View>
      </View>
      {right}
    </View>
  );
}

/* ── Badge ─────────────────────────────────────────────────── */
export function Badge({
  label,
  color = 'primary',
  icon,
  size = 'md',
  dot,
  style,
}: {
  label: string;
  color?: keyof Palette;
  icon?: IconName | string;
  size?: 'sm' | 'md';
  dot?: boolean;
  style?: ViewStyle;
}) {
  const c = useTheme();
  const fg = c[color] as string;
  const softKey = (color === 'textMuted' ? 'surfaceAlt' : `${String(color)}Soft`) as keyof Palette;
  const bg = (c[softKey] as string) ?? c.surfaceAlt;
  return (
    <View
      style={[
        styles.badge,
        { backgroundColor: bg, paddingVertical: size === 'sm' ? 2 : 4, paddingHorizontal: size === 'sm' ? 7 : 9 },
        style,
      ]}
    >
      {dot ? <View style={[styles.dot, { backgroundColor: fg }]} /> : null}
      {icon ? <Icon name={icon} size={size === 'sm' ? 11 : 13} color={fg} /> : null}
      <T variant="caption" style={{ color: fg, fontWeight: '700', fontSize: size === 'sm' ? 11.5 : 12.5 }} numberOfLines={1}>
        {label}
      </T>
    </View>
  );
}

export function StatusDot({ color, size = 9, pulse }: { color: string; size?: number; pulse?: boolean }) {
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      {pulse ? (
        <View
          dataSet={{ anim: 'alarm' }}
          style={[StyleSheet.absoluteFill, { borderRadius: size, backgroundColor: color, opacity: 0.4 }]}
        />
      ) : null}
      <View style={{ width: size, height: size, borderRadius: size, backgroundColor: color }} />
    </View>
  );
}

/* ── Avatar ────────────────────────────────────────────────── */
const AVATAR_COLORS = ['#00ACB2', '#7C5CFF', '#F59E0B', '#EC4899', '#3B82F6', '#10B981', '#EF4444', '#0EA5E9'];

export function colorFor(seed: string) {
  let h = 0;
  for (let i = 0; i < seed.length; i++) h = (h * 31 + seed.charCodeAt(i)) >>> 0;
  return AVATAR_COLORS[h % AVATAR_COLORS.length];
}

export function Avatar({
  name,
  uri,
  size = 40,
  status,
  ring,
  style,
}: {
  name?: string | null;
  uri?: string | null;
  size?: number;
  status?: string;
  ring?: string;
  style?: ViewStyle;
}) {
  const c = useTheme();
  const [failed, setFailed] = React.useState(false);
  const bg = colorFor(name || '?');
  const showImg = Boolean(uri && uri.startsWith('http') && !failed);
  return (
    <View style={[{ width: size, height: size }, style]}>
      <View
        style={[
          styles.avatar,
          {
            width: size,
            height: size,
            borderRadius: size / 2,
            backgroundColor: showImg ? c.surfaceAlt : bg,
            borderWidth: ring ? 2 : 0,
            borderColor: ring,
          },
        ]}
      >
        {showImg ? (
          <Image source={{ uri: uri! }} style={{ width: '100%', height: '100%' }} onError={() => setFailed(true)} />
        ) : (
          <T style={{ color: '#fff', fontWeight: '700', fontSize: Math.max(11, size * 0.38) }}>{initials(name)}</T>
        )}
      </View>
      {status ? (
        <View
          style={[
            styles.avatarStatus,
            {
              width: Math.max(10, size * 0.28),
              height: Math.max(10, size * 0.28),
              borderRadius: size,
              backgroundColor: status,
              borderColor: c.surface,
            },
          ]}
        />
      ) : null}
    </View>
  );
}

/* ── Switch ────────────────────────────────────────────────── */
export function Switch({
  value,
  onChange,
  disabled,
  size = 'md',
  label,
}: {
  value: boolean;
  onChange: (next: boolean) => void;
  disabled?: boolean;
  size?: 'sm' | 'md';
  label?: string;
}) {
  const c = useTheme();
  const w = size === 'sm' ? 34 : 42;
  const h = size === 'sm' ? 20 : 24;
  const k = h - 6;
  return (
    <Pressable
      accessibilityRole="switch"
      accessibilityState={{ checked: value, disabled }}
      accessibilityLabel={label}
      disabled={disabled}
      onPress={() => onChange(!value)}
      style={[
        { width: w, height: h, borderRadius: h, padding: 3, backgroundColor: value ? c.primary : c.borderStrong, opacity: disabled ? 0.5 : 1 },
        transition('background-color', 180),
        web({ cursor: disabled ? 'not-allowed' : 'pointer' }),
      ]}
    >
      <View
        style={[
          { width: k, height: k, borderRadius: k, backgroundColor: '#fff' },
          shadow(1, 'rgba(0,0,0,0.25)'),
          transition('transform', 200),
          web({ transform: `translateX(${value ? w - k - 6 : 0}px)` }),
        ]}
      />
    </Pressable>
  );
}

/* ── Segmented ─────────────────────────────────────────────── */
export function Segmented<V extends string>({
  options,
  value,
  onChange,
  size = 'md',
  style,
}: {
  options: { value: V; label: string; icon?: IconName | string; count?: number }[];
  value: V;
  onChange: (v: V) => void;
  size?: 'sm' | 'md';
  style?: ViewStyle;
}) {
  const c = useTheme();
  return (
    <View style={[styles.segment, { backgroundColor: c.surfaceAlt, borderColor: c.border }, style]}>
      {options.map((o) => {
        const active = o.value === value;
        return (
          <Pressable
            key={o.value}
            onPress={() => onChange(o.value)}
            accessibilityRole="tab"
            accessibilityState={{ selected: active }}
            style={(state) => {
              const { hovered } = state as WebPressState;
              return [
                styles.segmentItem,
                { paddingVertical: size === 'sm' ? 5 : 7, paddingHorizontal: size === 'sm' ? 10 : 14 },
                active ? [{ backgroundColor: c.surface }, shadow(1, c.shadow)] : hovered ? { backgroundColor: c.surfaceHover } : null,
                transition('background-color', 150),
                web({ cursor: 'pointer' }),
              ];
            }}
          >
            {o.icon ? <Icon name={o.icon} size={14} color={active ? 'primary' : 'textMuted'} /> : null}
            <T variant="small" style={{ fontWeight: active ? '700' : '500' }} color={active ? 'text' : 'textMuted'}>
              {o.label}
            </T>
            {o.count !== undefined && o.count > 0 ? (
              <View style={[styles.segCount, { backgroundColor: active ? c.primary : c.borderStrong }]}>
                <T variant="caption" style={{ color: '#fff', fontSize: 11, fontWeight: '700' }}>
                  {o.count}
                </T>
              </View>
            ) : null}
          </Pressable>
        );
      })}
    </View>
  );
}

/* ── Empty / Loading ───────────────────────────────────────── */
export function EmptyState({
  icon = 'file-tray-outline',
  title,
  description,
  action,
  compact,
}: {
  icon?: IconName | string;
  title: string;
  description?: string;
  action?: React.ReactNode;
  compact?: boolean;
}) {
  const c = useTheme();
  return (
    <View dataSet={{ anim: 'fade' }} style={[styles.empty, { paddingVertical: compact ? 24 : 48 }]}>
      <View style={[styles.emptyIcon, { backgroundColor: c.primarySoft, width: compact ? 52 : 72, height: compact ? 52 : 72 }]}>
        <Icon name={icon} size={compact ? 24 : 32} color="primary" />
      </View>
      <T variant="h3" align="center">
        {title}
      </T>
      {description ? (
        <T variant="small" color="textMuted" align="center" style={{ maxWidth: 380 }}>
          {description}
        </T>
      ) : null}
      {action ? <View style={{ marginTop: 8 }}>{action}</View> : null}
    </View>
  );
}

export function Skeleton({ height = 16, width = '100%', radius: r = 8, style }: { height?: number; width?: number | `${number}%`; radius?: number; style?: ViewStyle }) {
  const c = useTheme();
  return (
    <View
      dataSet={{ anim: 'shimmer' }}
      style={[{ height, width, borderRadius: r, backgroundColor: c.surfaceAlt }, style]}
    />
  );
}

export function SkeletonList({ rows = 4, height = 56 }: { rows?: number; height?: number }) {
  return (
    <View style={{ gap: 10 }}>
      {Array.from({ length: rows }).map((_, i) => (
        <Skeleton key={i} height={height} radius={12} />
      ))}
    </View>
  );
}

export function Loader({ label }: { label?: string }) {
  const c = useTheme();
  return (
    <View style={styles.loader}>
      <ActivityIndicator color={c.primary} />
      {label ? (
        <T variant="small" color="textMuted">
          {label}
        </T>
      ) : null}
    </View>
  );
}

export function Divider({ vertical, style }: { vertical?: boolean; style?: ViewStyle }) {
  const c = useTheme();
  return (
    <View
      style={[vertical ? { width: 1, alignSelf: 'stretch' } : { height: 1, alignSelf: 'stretch' }, { backgroundColor: c.border }, style]}
    />
  );
}

export function Kbd({ children }: { children: string }) {
  const c = useTheme();
  return (
    <View style={[styles.kbd, { borderColor: c.border, backgroundColor: c.surfaceAlt }]}>
      <T variant="caption" color="textMuted" style={{ fontWeight: '700', fontSize: 11.5 }}>
        {children}
      </T>
    </View>
  );
}

const styles = StyleSheet.create({
  card: { borderRadius: radius.xl, borderWidth: 1 },
  cardHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 12, marginBottom: 16 },
  rowCenter: { flexDirection: 'row', alignItems: 'center', gap: 12, flexShrink: 1 },
  headerIcon: { width: 36, height: 36, borderRadius: 11, alignItems: 'center', justifyContent: 'center' },
  badge: { flexDirection: 'row', alignItems: 'center', gap: 4, borderRadius: radius.pill, alignSelf: 'flex-start' },
  dot: { width: 6, height: 6, borderRadius: 3 },
  avatar: { alignItems: 'center', justifyContent: 'center', overflow: 'hidden' },
  avatarStatus: { position: 'absolute', right: -1, bottom: -1, borderWidth: 2 },
  segment: { flexDirection: 'row', padding: 3, borderRadius: radius.md, borderWidth: 1, alignSelf: 'flex-start', gap: 2 },
  segmentItem: { flexDirection: 'row', alignItems: 'center', gap: 6, borderRadius: 9 },
  segCount: { minWidth: 18, height: 18, borderRadius: 9, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 5 },
  empty: { alignItems: 'center', justifyContent: 'center', gap: 8, paddingHorizontal: 24 },
  emptyIcon: { borderRadius: 999, alignItems: 'center', justifyContent: 'center', marginBottom: 6 },
  loader: { alignItems: 'center', justifyContent: 'center', padding: 32, gap: 10 },
  kbd: { borderWidth: 1, borderRadius: 6, paddingHorizontal: 6, paddingVertical: 1, borderBottomWidth: 2 },
});
