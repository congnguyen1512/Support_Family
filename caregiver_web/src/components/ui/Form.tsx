import React, { forwardRef, useState } from 'react';
import { Pressable, StyleSheet, TextInput, View, type TextInputProps, type ViewStyle } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { fontFamily, radius } from '../../theme/tokens';
import { transition, web, type WebPressState } from '../../theme/web';
import { Icon, T, type IconName } from './Text';
import { Avatar } from './Display';
import { WEEKDAYS } from '../../utils/constants';
import type { FamilyMember } from '../../api/types';

/* ── Field wrapper ─────────────────────────────────────────── */
export function Field({
  label,
  hint,
  error,
  required,
  children,
  style,
  right,
}: {
  label?: string;
  hint?: string;
  error?: string | null;
  required?: boolean;
  children: React.ReactNode;
  style?: ViewStyle;
  right?: React.ReactNode;
}) {
  return (
    <View style={[{ gap: 6 }, style]}>
      {label ? (
        <View style={styles.labelRow}>
          <T variant="small" color="textSoft" style={{ fontWeight: '600' }}>
            {label}
            {required ? <T variant="small" color="danger"> *</T> : null}
          </T>
          {right}
        </View>
      ) : null}
      {children}
      {error ? (
        <View style={styles.errorRow}>
          <Icon name="alert-circle" size={13} color="danger" />
          <T variant="caption" color="danger">
            {error}
          </T>
        </View>
      ) : hint ? (
        <T variant="caption" color="textMuted">
          {hint}
        </T>
      ) : null}
    </View>
  );
}

function useInputChrome(focused: boolean, error?: boolean) {
  const c = useTheme();
  return [
    styles.inputBox,
    {
      backgroundColor: focused ? c.surface : c.inputBg,
      borderColor: error ? c.danger : focused ? c.primary : c.border,
    },
    focused ? web({ boxShadow: `0 0 0 4px ${error ? c.dangerSoft : c.primarySoft}` }) : null,
    transition('border-color, box-shadow, background-color', 150),
  ];
}

/* ── TextField ─────────────────────────────────────────────── */
export interface TextFieldProps extends Omit<TextInputProps, 'style'> {
  icon?: IconName | string;
  right?: React.ReactNode;
  error?: boolean;
  style?: ViewStyle;
  height?: number;
}

export const TextField = forwardRef<TextInput, TextFieldProps>(function TextField(
  { icon, right, error, style, height = 42, multiline, onFocus, onBlur, ...rest },
  ref,
) {
  const c = useTheme();
  const [focused, setFocused] = useState(false);
  const chrome = useInputChrome(focused, error);
  return (
    <View style={[...chrome, { minHeight: height, alignItems: multiline ? 'flex-start' : 'center' }, style]}>
      {icon ? <Icon name={icon} size={17} color={focused ? 'primary' : 'textMuted'} style={{ marginTop: multiline ? 10 : 0 }} /> : null}
      <TextInput
        ref={ref}
        {...rest}
        multiline={multiline}
        placeholderTextColor={c.textMuted}
        onFocus={(e) => {
          setFocused(true);
          onFocus?.(e);
        }}
        onBlur={(e) => {
          setFocused(false);
          onBlur?.(e);
        }}
        style={[
          styles.input,
          { color: c.text, minHeight: multiline ? 84 : height - 2, paddingVertical: multiline ? 10 : 0 },
          web({ outlineStyle: 'none', resize: multiline ? 'vertical' : 'none' }),
        ]}
      />
      {right}
    </View>
  );
});

export function SearchInput({
  value,
  onChangeText,
  placeholder = 'Tìm kiếm...',
  style,
  autoFocus,
  nativeID,
}: {
  value: string;
  onChangeText: (v: string) => void;
  placeholder?: string;
  style?: ViewStyle;
  autoFocus?: boolean;
  nativeID?: string;
}) {
  return (
    <TextField
      nativeID={nativeID}
      icon="search"
      value={value}
      onChangeText={onChangeText}
      placeholder={placeholder}
      autoFocus={autoFocus}
      height={40}
      style={style}
      right={
        value ? (
          <Pressable onPress={() => onChangeText('')} accessibilityLabel="Xóa tìm kiếm" style={web({ cursor: 'pointer' })}>
            <Icon name="close-circle" size={17} color="textMuted" />
          </Pressable>
        ) : null
      }
    />
  );
}

/* ── Native HTML controls (web) ────────────────────────────── */
function nativeStyle(c: ReturnType<typeof useTheme>, focused: boolean, error?: boolean): React.CSSProperties {
  return {
    height: 42,
    width: '100%',
    boxSizing: 'border-box',
    borderRadius: radius.md,
    border: `1px solid ${error ? c.danger : focused ? c.primary : c.border}`,
    background: focused ? c.surface : c.inputBg,
    color: c.text,
    padding: '0 12px',
    fontSize: 15.5,
    fontFamily: fontFamily.regular,
    boxShadow: focused ? `0 0 0 4px ${error ? c.dangerSoft : c.primarySoft}` : 'none',
    transition: 'border-color .15s, box-shadow .15s, background-color .15s',
    colorScheme: c.mode,
  };
}

export function SelectField<V extends string>({
  value,
  onChange,
  options,
  placeholder,
  error,
  disabled,
  id,
}: {
  value: V | '';
  onChange: (v: V) => void;
  options: { value: V; label: string }[];
  placeholder?: string;
  error?: boolean;
  disabled?: boolean;
  id?: string;
}) {
  const c = useTheme();
  const [focused, setFocused] = useState(false);
  const chevron = `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='${encodeURIComponent(
    c.textMuted,
  )}' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E")`;
  return (
    <select
      id={id}
      value={value ?? ''}
      disabled={disabled}
      onChange={(e) => onChange(e.target.value as V)}
      onFocus={() => setFocused(true)}
      onBlur={() => setFocused(false)}
      style={{
        ...nativeStyle(c, focused, error),
        appearance: 'none',
        WebkitAppearance: 'none',
        backgroundImage: chevron,
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'right 12px center',
        paddingRight: 34,
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.6 : 1,
      }}
    >
      {placeholder ? (
        <option value="" disabled>
          {placeholder}
        </option>
      ) : null}
      {options.map((o) => (
        <option key={o.value} value={o.value}>
          {o.label}
        </option>
      ))}
    </select>
  );
}

export function DateField({
  value,
  onChange,
  type = 'date',
  error,
  min,
  max,
  id,
}: {
  value: string;
  onChange: (v: string) => void;
  type?: 'date' | 'time' | 'datetime-local';
  error?: boolean;
  min?: string;
  max?: string;
  id?: string;
}) {
  const c = useTheme();
  const [focused, setFocused] = useState(false);
  return (
    <input
      id={id}
      type={type}
      value={value}
      min={min}
      max={max}
      onChange={(e) => onChange(e.target.value)}
      onFocus={() => setFocused(true)}
      onBlur={() => setFocused(false)}
      style={nativeStyle(c, focused, error)}
    />
  );
}

export function RangeField({
  value,
  onChange,
  min,
  max,
  step = 1,
}: {
  value: number;
  onChange: (v: number) => void;
  min: number;
  max: number;
  step?: number;
}) {
  return (
    <input
      type="range"
      value={value}
      min={min}
      max={max}
      step={step}
      onChange={(e) => onChange(Number(e.target.value))}
      style={{ width: '100%', height: 22 }}
    />
  );
}

/* ── Weekday picker ────────────────────────────────────────── */
export function WeekdayPicker({ value, onChange }: { value: number[]; onChange: (v: number[]) => void }) {
  const c = useTheme();
  const toggle = (d: number) => onChange(value.includes(d) ? value.filter((x) => x !== d) : [...value, d].sort());
  return (
    <View style={{ gap: 8 }}>
      <View style={styles.weekRow}>
        {WEEKDAYS.map((w) => {
          const active = value.includes(w.value);
          return (
            <Pressable
              key={w.value}
              onPress={() => toggle(w.value)}
              accessibilityLabel={w.label}
              accessibilityState={{ selected: active }}
              style={(state) => {
                const { hovered } = state as WebPressState;
                return [
                  styles.weekItem,
                  {
                    backgroundColor: active ? c.primary : hovered ? c.surfaceHover : c.inputBg,
                    borderColor: active ? c.primary : c.border,
                  },
                  transition('background-color, border-color', 140),
                  web({ cursor: 'pointer' }),
                ];
              }}
            >
              <T variant="small" style={{ fontWeight: '700', color: active ? '#fff' : c.textSoft }}>
                {w.short}
              </T>
            </Pressable>
          );
        })}
      </View>
      <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap' }}>
        {[
          { label: 'Ngày thường', days: [1, 2, 3, 4, 5] },
          { label: 'Cuối tuần', days: [6, 7] },
          { label: 'Cả tuần', days: [1, 2, 3, 4, 5, 6, 7] },
        ].map((p) => (
          <Pressable key={p.label} onPress={() => onChange(p.days)} style={web({ cursor: 'pointer' })}>
            <T variant="caption" color="primary" style={{ fontWeight: '600' }}>
              {p.label}
            </T>
          </Pressable>
        ))}
      </View>
    </View>
  );
}

/* ── Member chips picker ───────────────────────────────────── */
export function MemberChips({
  members,
  value,
  onChange,
  allowAll,
  allLabel = 'Tất cả',
}: {
  members: FamilyMember[];
  value: string | undefined;
  onChange: (uid: string | undefined) => void;
  allowAll?: boolean;
  allLabel?: string;
}) {
  const c = useTheme();
  const items: { uid: string | undefined; name: string; avatar?: string | null }[] = [
    ...(allowAll ? [{ uid: undefined, name: allLabel }] : []),
    ...members.map((m) => ({ uid: m.uid, name: m.name, avatar: m.avatar })),
  ];
  return (
    <View style={styles.chipsRow}>
      {items.map((m) => {
        const active = m.uid === value;
        return (
          <Pressable
            key={m.uid ?? 'all'}
            onPress={() => onChange(m.uid)}
            accessibilityState={{ selected: active }}
            style={(state) => {
              const { hovered } = state as WebPressState;
              return [
                styles.chip,
                {
                  backgroundColor: active ? c.primarySoft : hovered ? c.surfaceHover : c.surface,
                  borderColor: active ? c.primary : c.border,
                },
                transition('background-color, border-color', 140),
                web({ cursor: 'pointer' }),
              ];
            }}
          >
            {m.uid ? (
              <Avatar name={m.name} uri={m.avatar} size={22} />
            ) : (
              <View style={[styles.allIcon, { backgroundColor: c.primary }]}>
                <Icon name="people" size={12} color="#fff" />
              </View>
            )}
            <T variant="small" style={{ fontWeight: active ? '700' : '500' }} color={active ? 'primary' : 'textSoft'} numberOfLines={1}>
              {m.name}
            </T>
          </Pressable>
        );
      })}
    </View>
  );
}

/** Lựa chọn dạng thẻ (radio cards) */
export function ChoiceCards<V extends string>({
  options,
  value,
  onChange,
  columns = 4,
}: {
  options: { value: V; label: string; icon: IconName | string; color?: string }[];
  value: V;
  onChange: (v: V) => void;
  columns?: number;
}) {
  const c = useTheme();
  return (
    <View style={styles.choiceGrid}>
      {options.map((o) => {
        const active = o.value === value;
        const tint = o.color ?? c.primary;
        return (
          <Pressable
            key={o.value}
            onPress={() => onChange(o.value)}
            accessibilityState={{ selected: active }}
            style={(state) => {
              const { hovered } = state as WebPressState;
              return [
                styles.choice,
                web({ flexBasis: `calc(${100 / columns}% - 8px)` }),
                {
                  borderColor: active ? tint : c.border,
                  backgroundColor: active ? `${tint}14` : hovered ? c.surfaceHover : c.surface,
                },
                transition('background-color, border-color, transform', 140),
                web({ cursor: 'pointer', transform: hovered && !active ? 'translateY(-1px)' : 'none' }),
              ];
            }}
          >
            <Icon name={o.icon} size={20} color={active ? tint : c.textMuted} />
            <T variant="small" style={{ fontWeight: active ? '700' : '500' }} color={active ? 'text' : 'textSoft'} numberOfLines={1}>
              {o.label}
            </T>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  labelRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  errorRow: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  inputBox: {
    flexDirection: 'row',
    gap: 8,
    borderWidth: 1,
    borderRadius: radius.md,
    paddingHorizontal: 12,
  },
  input: { flex: 1, fontSize: 15.5, fontFamily: fontFamily.regular, minWidth: 0 },
  weekRow: { flexDirection: 'row', gap: 6, flexWrap: 'wrap' },
  weekItem: { width: 42, height: 38, borderRadius: 10, borderWidth: 1, alignItems: 'center', justifyContent: 'center' },
  chipsRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingLeft: 4,
    paddingRight: 12,
    paddingVertical: 4,
    borderRadius: 999,
    borderWidth: 1,
    maxWidth: 220,
  },
  allIcon: { width: 22, height: 22, borderRadius: 11, alignItems: 'center', justifyContent: 'center' },
  choiceGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  choice: {
    flexGrow: 1,
    minWidth: 92,
    borderWidth: 1.5,
    borderRadius: 14,
    paddingVertical: 12,
    paddingHorizontal: 10,
    alignItems: 'center',
    gap: 6,
  },
});
