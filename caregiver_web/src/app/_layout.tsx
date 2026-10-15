import '../global.css';
import React from 'react';
import { View } from 'react-native';
import { Slot } from 'expo-router';
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from '../api/hooks';
import { ThemeProvider, useTheme } from '../theme/ThemeProvider';
import { ConfirmHost, Loader, Toaster } from '../components/ui';
import { useAuthStore } from '../store/auth';

function Root() {
  const c = useTheme();
  const hydrated = useAuthStore((s) => s.hydrated);
  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <Slot />
      {!hydrated ? (
        <View style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, alignItems: 'center', justifyContent: 'center', backgroundColor: c.bg }}>
          <Loader label="Đang khởi động..." />
        </View>
      ) : null}
      <Toaster />
      <ConfirmHost />
    </View>
  );
}

export default function RootLayout() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <Root />
      </ThemeProvider>
    </QueryClientProvider>
  );
}
