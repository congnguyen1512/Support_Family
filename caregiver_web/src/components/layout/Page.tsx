import React from 'react';
import { RefreshControl, ScrollView, StyleSheet, View, type ViewStyle } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { useBreakpoint } from '../../hooks/common';
import { T } from '../ui';

/** Khung trang chuẩn: tiêu đề + mô tả + hành động, nội dung cuộn. */
export function Page({
  title,
  subtitle,
  actions,
  children,
  scroll = true,
  maxWidth = 1480,
  onRefresh,
  refreshing,
  contentStyle,
}: {
  title?: string;
  subtitle?: string;
  actions?: React.ReactNode;
  children: React.ReactNode;
  scroll?: boolean;
  maxWidth?: number;
  onRefresh?: () => void;
  refreshing?: boolean;
  contentStyle?: ViewStyle;
}) {
  const c = useTheme();
  const { isMobile } = useBreakpoint();
  const pad = isMobile ? 16 : 28;

  const header = title ? (
    <View dataSet={{ anim: 'fade' }} style={[styles.header, isMobile ? { flexDirection: 'column', alignItems: 'flex-start' } : null]}>
      <View style={{ flex: 1, gap: 4 }}>
        <T variant="h1">{title}</T>
        {subtitle ? (
          <T variant="body" color="textMuted">
            {subtitle}
          </T>
        ) : null}
      </View>
      {actions ? <View style={styles.actions}>{actions}</View> : null}
    </View>
  ) : null;

  if (!scroll) {
    return (
      <View style={[styles.fill, { padding: pad, gap: 20 }, contentStyle]}>
        {header}
        {children}
      </View>
    );
  }

  return (
    <ScrollView
      style={[styles.fill, { backgroundColor: c.bg }]}
      contentContainerStyle={[{ padding: pad, paddingBottom: 48, width: '100%', maxWidth, alignSelf: 'center', gap: 20 }, contentStyle]}
      refreshControl={onRefresh ? <RefreshControl refreshing={Boolean(refreshing)} onRefresh={onRefresh} /> : undefined}
    >
      {header}
      {children}
    </ScrollView>
  );
}

/** Lưới responsive: tự xuống dòng theo minWidth của từng cột. */
export function Grid({ children, gap = 20, style }: { children: React.ReactNode; gap?: number; style?: ViewStyle }) {
  return <View style={[{ flexDirection: 'row', flexWrap: 'wrap', gap, alignItems: 'stretch' }, style]}>{children}</View>;
}

export function Col({ children, flex = 1, minWidth = 320, style }: { children: React.ReactNode; flex?: number; minWidth?: number; style?: ViewStyle }) {
  return <View style={[{ flexGrow: flex, flexShrink: 1, flexBasis: minWidth, minWidth: Math.min(minWidth, 280), gap: 20 }, style]}>{children}</View>;
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  header: { flexDirection: 'row', alignItems: 'flex-end', gap: 16, flexWrap: 'wrap' },
  actions: { flexDirection: 'row', alignItems: 'center', gap: 10, flexWrap: 'wrap' },
});
