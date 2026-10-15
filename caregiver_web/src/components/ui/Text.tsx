import React from 'react';
import { Text as RNText, type TextProps, type TextStyle, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../../theme/ThemeProvider';
import { fontFamily, fontSize } from '../../theme/tokens';
import type { Palette } from '../../theme/tokens';

type Variant = 'hero' | 'display' | 'h1' | 'h2' | 'h3' | 'title' | 'body' | 'bodyStrong' | 'small' | 'caption' | 'label' | 'mono';

const variants: Record<Variant, TextStyle> = {
  hero: { fontSize: fontSize.hero, fontWeight: '800', letterSpacing: -0.8, lineHeight: 44 },
  display: { fontSize: fontSize.display, fontWeight: '800', letterSpacing: -0.6, lineHeight: 38 },
  h1: { fontSize: fontSize.xxl, fontWeight: '700', letterSpacing: -0.4, lineHeight: 32 },
  h2: { fontSize: fontSize.xl, fontWeight: '700', letterSpacing: -0.2, lineHeight: 28 },
  h3: { fontSize: fontSize.lg, fontWeight: '700', lineHeight: 24 },
  title: { fontSize: fontSize.md, fontWeight: '600', lineHeight: 22 },
  body: { fontSize: fontSize.md, fontWeight: '400', lineHeight: 23 },
  bodyStrong: { fontSize: fontSize.md, fontWeight: '600', lineHeight: 23 },
  small: { fontSize: fontSize.sm, fontWeight: '500', lineHeight: 20 },
  caption: { fontSize: fontSize.xs, fontWeight: '500', lineHeight: 17 },
  label: { fontSize: fontSize.xs, fontWeight: '700', letterSpacing: 0.6, textTransform: 'uppercase', lineHeight: 17 },
  mono: { fontSize: fontSize.sm, fontWeight: '500', fontFamily: fontFamily.mono },
};

export interface TProps extends TextProps {
  variant?: Variant;
  color?: keyof Palette | (string & {});
  weight?: TextStyle['fontWeight'];
  align?: TextStyle['textAlign'];
  size?: number;
}

export function T({ variant = 'body', color = 'text', weight, align, size, style, ...rest }: TProps) {
  const c = useTheme();
  const resolved = (c as unknown as Record<string, string>)[color as string] ?? color;
  return (
    <RNText
      {...rest}
      style={[
        styles.base,
        variants[variant],
        { color: resolved },
        weight ? { fontWeight: weight } : null,
        align ? { textAlign: align } : null,
        size ? { fontSize: size, lineHeight: Math.round(size * 1.4) } : null,
        style,
      ]}
    />
  );
}

const styles = StyleSheet.create({
  base: { fontFamily: fontFamily.regular },
});

export type IconName = React.ComponentProps<typeof Ionicons>['name'];

export function Icon({
  name,
  size = 18,
  color = 'textSoft',
  style,
}: {
  name: IconName | string;
  size?: number;
  color?: keyof Palette | (string & {});
  style?: TextStyle;
}) {
  const c = useTheme();
  const resolved = (c as unknown as Record<string, string>)[color as string] ?? color;
  return <Ionicons name={name as IconName} size={size} color={resolved} style={style} />;
}
