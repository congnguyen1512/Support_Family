import React from 'react';
import { ActivityIndicator, Pressable, StyleSheet, View, type ViewStyle } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { radius } from '../../theme/tokens';
import { shadow, transition, web, type WebPressState } from '../../theme/web';
import { Icon, T, type IconName } from './Text';

type Variant = 'primary' | 'secondary' | 'ghost' | 'danger' | 'soft' | 'dangerSoft';
type Size = 'sm' | 'md' | 'lg';

export interface ButtonProps {
  label?: string;
  onPress?: () => void;
  variant?: Variant;
  size?: Size;
  icon?: IconName | string;
  iconRight?: IconName | string;
  loading?: boolean;
  disabled?: boolean;
  full?: boolean;
  style?: ViewStyle;
  hint?: string;
  testID?: string;
  nativeID?: string;
}

const heights: Record<Size, number> = { sm: 32, md: 40, lg: 48 };
const paddings: Record<Size, number> = { sm: 12, md: 16, lg: 22 };

export function Button({
  label,
  onPress,
  variant = 'primary',
  size = 'md',
  icon,
  iconRight,
  loading,
  disabled,
  full,
  style,
  hint,
  testID,
  nativeID,
}: ButtonProps) {
  const c = useTheme();
  const isDisabled = disabled || loading;

  const palette = {
    primary: { bg: c.primary, bgHover: c.primaryHover, fg: '#FFFFFF', border: 'transparent' },
    secondary: { bg: c.surface, bgHover: c.surfaceHover, fg: c.text, border: c.border },
    ghost: { bg: 'transparent', bgHover: c.surfaceHover, fg: c.textSoft, border: 'transparent' },
    danger: { bg: c.danger, bgHover: '#DC2626', fg: '#FFFFFF', border: 'transparent' },
    soft: { bg: c.primarySoft, bgHover: c.primarySoft, fg: c.primary, border: 'transparent' },
    dangerSoft: { bg: c.dangerSoft, bgHover: c.dangerSoft, fg: c.danger, border: 'transparent' },
  }[variant];

  return (
    <Pressable
      testID={testID}
      nativeID={nativeID}
      onPress={onPress}
      disabled={isDisabled}
      accessibilityRole="button"
      accessibilityLabel={label}
      style={(state) => {
        const { hovered, pressed } = state as WebPressState;
        return [
          styles.base,
          transition('background-color, transform, box-shadow, border-color', 160),
          {
            height: heights[size],
            paddingHorizontal: label ? paddings[size] : 0,
            width: label ? undefined : heights[size],
            backgroundColor: hovered ? palette.bgHover : palette.bg,
            borderColor: hovered && variant === 'secondary' ? c.borderStrong : palette.border,
            opacity: isDisabled ? 0.55 : 1,
            alignSelf: full ? 'stretch' : 'flex-start',
          },
          variant === 'primary' && !isDisabled ? shadow(hovered ? 3 : 2, c.primaryGlow) : null,
          variant === 'danger' && !isDisabled ? shadow(2, 'rgba(239,68,68,0.3)') : null,
          web({
            cursor: isDisabled ? 'not-allowed' : 'pointer',
            transform: pressed ? 'scale(0.97)' : hovered && variant === 'primary' ? 'translateY(-1px)' : 'none',
            userSelect: 'none',
          }),
          style,
        ];
      }}
    >
      {loading ? (
        <ActivityIndicator size="small" color={palette.fg} />
      ) : (
        <View style={styles.row}>
          {icon ? <Icon name={icon} size={size === 'sm' ? 15 : 17} color={palette.fg} /> : null}
          {label ? (
            <T variant="bodyStrong" style={{ color: palette.fg, fontSize: size === 'sm' ? 14 : 15.5 }} numberOfLines={1}>
              {label}
            </T>
          ) : null}
          {iconRight ? <Icon name={iconRight} size={size === 'sm' ? 15 : 17} color={palette.fg} /> : null}
          {hint ? (
            <View style={[styles.hint, { borderColor: variant === 'primary' ? 'rgba(255,255,255,0.35)' : c.border }]}>
              <T variant="caption" style={{ color: palette.fg, opacity: 0.85 }}>
                {hint}
              </T>
            </View>
          ) : null}
        </View>
      )}
    </Pressable>
  );
}

export function IconButton({
  icon,
  onPress,
  label,
  size = 36,
  variant = 'ghost',
  color,
  badge,
  active,
  style,
}: {
  icon: IconName | string;
  onPress?: () => void;
  label: string;
  size?: number;
  variant?: 'ghost' | 'secondary' | 'soft' | 'dangerSoft';
  color?: string;
  badge?: number | boolean;
  active?: boolean;
  style?: ViewStyle;
}) {
  const c = useTheme();
  const base = {
    ghost: { bg: 'transparent', hover: c.surfaceHover, fg: c.textSoft, border: 'transparent' },
    secondary: { bg: c.surface, hover: c.surfaceHover, fg: c.textSoft, border: c.border },
    soft: { bg: c.primarySoft, hover: c.primarySoft, fg: c.primary, border: 'transparent' },
    dangerSoft: { bg: c.dangerSoft, hover: c.dangerSoft, fg: c.danger, border: 'transparent' },
  }[variant];
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={label}
      style={(state) => {
        const { hovered, pressed } = state as WebPressState;
        return [
          styles.iconBtn,
          transition('background-color, transform', 140),
          {
            width: size,
            height: size,
            borderRadius: size / 3.2,
            backgroundColor: active ? c.primarySoft : hovered ? base.hover : base.bg,
            borderColor: base.border,
          },
          web({ cursor: 'pointer', transform: pressed ? 'scale(0.92)' : 'none' }),
          style,
        ];
      }}
    >
      <Icon name={icon} size={Math.round(size * 0.5)} color={color ?? (active ? c.primary : base.fg)} />
      {badge ? (
        <View
          style={[
            styles.badge,
            { backgroundColor: c.danger, borderColor: c.surface },
            typeof badge === 'number' ? null : { minWidth: 10, height: 10, paddingHorizontal: 0, top: 6, right: 6 },
          ]}
        >
          {typeof badge === 'number' ? (
            <T variant="caption" style={{ color: '#fff', fontSize: 11, fontWeight: '700', lineHeight: 14 }}>
              {badge > 99 ? '99+' : badge}
            </T>
          ) : null}
        </View>
      ) : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: radius.md,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  },
  row: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  hint: {
    borderWidth: 1,
    borderRadius: 6,
    paddingHorizontal: 5,
    paddingVertical: 1,
    marginLeft: 2,
  },
  iconBtn: {
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
  },
  badge: {
    position: 'absolute',
    top: 2,
    right: 2,
    minWidth: 17,
    height: 17,
    borderRadius: 9,
    paddingHorizontal: 4,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
  },
});
