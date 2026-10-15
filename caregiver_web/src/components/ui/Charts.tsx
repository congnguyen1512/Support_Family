import React from 'react';
import { StyleSheet, View, type ViewStyle } from 'react-native';
import Svg, { Circle, Defs, LinearGradient, Path, Stop } from 'react-native-svg';
import { useTheme } from '../../theme/ThemeProvider';
import { gradient, shadow, web } from '../../theme/web';
import { Card } from './Display';
import { Icon, T, type IconName } from './Text';
import type { Palette } from '../../theme/tokens';

/* ── Progress ring ─────────────────────────────────────────── */
export function ProgressRing({
  value,
  size = 120,
  stroke = 12,
  color,
  track,
  children,
}: {
  value: number;
  size?: number;
  stroke?: number;
  color?: string;
  track?: string;
  children?: React.ReactNode;
}) {
  const c = useTheme();
  const r = (size - stroke) / 2;
  const circ = 2 * Math.PI * r;
  const pct = Math.max(0, Math.min(1, value));
  const tint = color ?? c.primary;
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <Svg width={size} height={size} style={StyleSheet.absoluteFill as any}>
        <Circle cx={size / 2} cy={size / 2} r={r} stroke={track ?? c.surfaceAlt} strokeWidth={stroke} fill="none" />
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          stroke={tint}
          strokeWidth={stroke}
          fill="none"
          strokeLinecap="round"
          strokeDasharray={`${circ} ${circ}`}
          strokeDashoffset={circ * (1 - pct)}
          transform={`rotate(-90 ${size / 2} ${size / 2})`}
          {...({ style: { transition: 'stroke-dashoffset 0.8s cubic-bezier(.2,.8,.2,1)' } } as object)}
        />
      </Svg>
      {children}
    </View>
  );
}

/* ── Linear progress ───────────────────────────────────────── */
export function ProgressBar({ value, color, height = 8, style }: { value: number; color?: string; height?: number; style?: ViewStyle }) {
  const c = useTheme();
  const pct = Math.max(0, Math.min(1, value));
  return (
    <View style={[{ height, borderRadius: height, backgroundColor: c.surfaceAlt, overflow: 'hidden' }, style]}>
      <View
        style={[
          { height: '100%', width: `${pct * 100}%`, borderRadius: height, backgroundColor: color ?? c.primary },
          web({ transition: 'width 0.8s cubic-bezier(.2,.8,.2,1)' }),
        ]}
      />
    </View>
  );
}

/* ── Bar chart ─────────────────────────────────────────────── */
export function BarChart({
  data,
  height = 160,
  color,
  highlightLast,
  formatValue = (v) => String(v),
}: {
  data: { label: string; value: number; color?: string }[];
  height?: number;
  color?: string;
  highlightLast?: boolean;
  formatValue?: (v: number) => string;
}) {
  const c = useTheme();
  const max = Math.max(1, ...data.map((d) => d.value));
  return (
    <View style={{ height: height + 28, flexDirection: 'row', alignItems: 'flex-end', gap: 8 }}>
      {data.map((d, i) => {
        const h = Math.max(4, (d.value / max) * height);
        const active = highlightLast && i === data.length - 1;
        const tint = d.color ?? color ?? c.primary;
        return (
          <View key={`${d.label}-${i}`} style={{ flex: 1, alignItems: 'center', gap: 6 }}>
            <T variant="caption" color={active ? 'text' : 'textMuted'} style={{ fontWeight: '700', fontSize: 11.5 }}>
              {d.value > 0 ? formatValue(d.value) : ''}
            </T>
            <View
              style={[
                { width: '100%', maxWidth: 34, height: h, borderRadius: 8 },
                active || d.color ? gradient(tint, `${tint}AA`, 180) : { backgroundColor: `${tint}55` },
                web({ transition: 'height 0.6s cubic-bezier(.2,.8,.2,1)' }),
              ]}
            />
            <T variant="caption" color="textMuted" style={{ fontSize: 12 }} numberOfLines={1}>
              {d.label}
            </T>
          </View>
        );
      })}
    </View>
  );
}

/* ── Sparkline ─────────────────────────────────────────────── */
export function Sparkline({ values, width = 120, height = 36, color }: { values: number[]; width?: number; height?: number; color?: string }) {
  const c = useTheme();
  if (values.length < 2) return <View style={{ width, height }} />;
  const max = Math.max(...values);
  const min = Math.min(...values);
  const span = max - min || 1;
  const step = width / (values.length - 1);
  const pts = values.map((v, i) => [i * step, height - ((v - min) / span) * (height - 6) - 3]);
  const d = pts.map((p, i) => `${i === 0 ? 'M' : 'L'}${p[0].toFixed(1)},${p[1].toFixed(1)}`).join(' ');
  const area = `${d} L${width},${height} L0,${height} Z`;
  const tint = color ?? c.primary;
  const id = `sp-${Math.round(Math.random() * 1e6)}`;
  return (
    <Svg width={width} height={height}>
      <Defs>
        <LinearGradient id={id} x1="0" y1="0" x2="0" y2="1">
          <Stop offset="0" stopColor={tint} stopOpacity={0.35} />
          <Stop offset="1" stopColor={tint} stopOpacity={0} />
        </LinearGradient>
      </Defs>
      <Path d={area} fill={`url(#${id})`} />
      <Path d={d} stroke={tint} strokeWidth={2} fill="none" strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

/* ── Stat card ─────────────────────────────────────────────── */
export function StatCard({
  label,
  value,
  icon,
  tone = 'primary',
  hint,
  trend,
  onPress,
  delay,
}: {
  label: string;
  value: string | number;
  icon: IconName | string;
  tone?: keyof Palette;
  hint?: string;
  trend?: React.ReactNode;
  onPress?: () => void;
  delay?: number;
}) {
  const c = useTheme();
  const tint = c[tone] as string;
  const soft = (c[`${String(tone)}Soft` as keyof Palette] as string) ?? c.primarySoft;
  return (
    <Card onPress={onPress} hoverable anim="rise" delay={delay} style={{ flex: 1, minWidth: 210, overflow: 'hidden' }} padding={18}>
      <View style={[styles.statGlow, { backgroundColor: soft }]} />
      <View style={styles.statTop}>
        <View style={[styles.statIcon, { backgroundColor: soft }]}>
          <Icon name={icon} size={20} color={tint} />
        </View>
        {trend}
      </View>
      <T variant="display" style={{ marginTop: 14 }}>
        {value}
      </T>
      <T variant="small" color="textMuted" style={{ fontWeight: '600' }}>
        {label}
      </T>
      {hint ? (
        <T variant="caption" color="textMuted" style={{ marginTop: 6 }} numberOfLines={1}>
          {hint}
        </T>
      ) : null}
    </Card>
  );
}

export function HeroGradient({ children, style }: { children: React.ReactNode; style?: ViewStyle }) {
  const c = useTheme();
  return (
    <View
      dataSet={{ anim: 'rise' }}
      style={[
        styles.hero,
        gradient(c.mode === 'dark' ? '#0E3A40' : '#00ACB2', c.mode === 'dark' ? '#1B2B5A' : '#4F7CFF', 120),
        shadow(3, c.primaryGlow),
        style,
      ]}
    >
      <View style={[styles.heroOrb, { right: -60, top: -80, width: 260, height: 260 }]} />
      <View style={[styles.heroOrb, { right: 140, bottom: -120, width: 220, height: 220, opacity: 0.08 }]} />
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  statTop: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  statIcon: { width: 42, height: 42, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
  statGlow: { position: 'absolute', right: -40, top: -40, width: 120, height: 120, borderRadius: 60, opacity: 0.6 },
  hero: { borderRadius: 24, padding: 26, overflow: 'hidden' },
  heroOrb: { position: 'absolute', borderRadius: 999, backgroundColor: '#FFFFFF', opacity: 0.12 },
});
